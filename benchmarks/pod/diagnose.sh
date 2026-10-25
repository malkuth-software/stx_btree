#!/usr/bin/env bash
# Diagnosis job for the x86-64 gap against bbtree (docs/MEASUREMENTS.md):
# the same C++ bench built by GCC 13 and by Clang 18, the reference bench, the
# count kernels' assembly from both compilers, and interleaved runs of the
# worst cells. Clang is unpacked from Ubuntu's packages inside this job
# directory; nothing is installed on the pod. Submitted by
# tools/prepare_pod_job.sh with this script as run.sh.
set -euo pipefail
job="$(pwd)"
out="$job/results"
mkdir -p "$out"
# The toolchains and build trees go however the job ends: the pod's disk is
# 5 GB, temporary and shared.
remove_scratch() {
    rm -rf "$job/stx_btree_lane_loop" "$job/toolchain" "$job/clang" "$job/clang-debs" "$job/stx_btree/.build" "$job/stx_btree/benchmarks/rust/vendor"
}
trap remove_scratch EXIT
export RUSTUP_HOME="$job/toolchain/rustup"
export CARGO_HOME="$job/toolchain/cargo"
export PATH="$CARGO_HOME/bin:$PATH"

echo "== toolchains"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init.sh
sh rustup-init.sh -y --profile minimal --default-toolchain stable --no-modify-path
mkdir -p "$job/clang-debs" "$job/clang"
(cd "$job/clang-debs" && apt-get download clang-18 libclang-cpp18 libllvm18 libclang-common-18-dev llvm-18-linker-tools libclang1-18)
for deb in "$job"/clang-debs/*.deb; do dpkg -x "$deb" "$job/clang"; done
export LD_LIBRARY_PATH="$job/clang/usr/lib/x86_64-linux-gnu:$job/clang/usr/lib/llvm-18/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
clang="$job/clang/usr/lib/llvm-18/bin/clang++"
if ! "$clang" --version > /dev/null 2>&1; then
    echo "clang does not start; missing libraries:"
    ldd "$job/clang/usr/lib/llvm-18/bin/clang" | grep "not found" || true
    exit 1
fi
{
    g++ --version | head -1
    "$clang" --version | head -1
    rustc --version
    command -v perf || echo "perf: not available"
    grep -m1 "model name" /proc/cpuinfo
    grep -m1 flags /proc/cpuinfo | tr ' ' '\n' | grep -E "^(avx2|avx512f|avx512bw|avx512vl|avx512_vbmi2)$" | tr '\n' ' '; echo
    cat /proc/loadavg
} | tee "$out/toolchains.txt"
echo "gcc native: $(g++ -march=native -Q --help=target 2>/dev/null | grep -E '^\s+-march=' | head -1)" >> "$out/toolchains.txt"

cd "$job/stx_btree"
echo "== count kernel assembly"
for compiler in g++ "$clang"; do
    name="$(basename "$compiler" | tr -d '+')"
    "$compiler" -std=c++20 -O3 -DNDEBUG -march=native -Iinclude -S -o "$out/count_probe.$name.s" benchmarks/pod/count_probe.cpp
    "$compiler" -std=c++20 -O3 -DNDEBUG -march=native -Iinclude -S -o "$out/find_probe.$name.s" benchmarks/pod/find_probe.cpp
done

echo "== stx_btree benches"
# One bench per build: compiler, flags and source tree. The lane_loop tree
# is this tree with the count from before the shuffle reduction
# (benchmarks/pod/overlay_lane_loop), for an A/B in one job.
lane_loop_tree="$job/stx_btree_lane_loop"
mkdir -p "$lane_loop_tree"
tar -C "$job/stx_btree" --exclude=./.build --exclude=./benchmarks/rust -cf - . | tar -C "$lane_loop_tree" -xf -
cp benchmarks/pod/overlay_lane_loop/stx_btree/detail/vector_count.hpp "$lane_loop_tree/include/stx_btree/detail/vector_count.hpp"
build_bench() {
    local name="$1" compiler="$2" flags="$3" tree="$4"
    cmake -S "$tree" -B ".build/$name" -DCMAKE_BUILD_TYPE=Release "-DCMAKE_CXX_COMPILER=$compiler" "-DCMAKE_CXX_FLAGS=$flags" \
        -DSTX_BTREE_WARNINGS_AS_ERRORS=OFF -DSTX_BTREE_BUILD_TESTS=OFF > /dev/null
    if ! cmake --build ".build/$name" --parallel 4 --target stx_btree_bench > "$out/build-$name.log" 2>&1; then
        echo "$name: build failed (results/build-$name.log)"
        grep -m 5 "error" "$out/build-$name.log" || true
        return 0
    fi
    echo "$name: $(objdump -d ".build/$name/stx_btree_bench" | grep -c vpextrw) vpextrw in the binary" >> "$out/toolchains.txt"
    built="$built $name"
}
built=""
build_bench gcc g++ "-march=native" "$job/stx_btree"
build_bench gcc_lane_loop g++ "-march=native" "$lane_loop_tree"
build_bench clang "$clang" "-march=native" "$job/stx_btree"
build_bench clang_lane_loop "$clang" "-march=native" "$lane_loop_tree"
runnable=""
for name in $built; do
    if "./.build/$name/stx_btree_bench" unsync str16 1000 1000 > /dev/null; then
        runnable="$runnable $name"
    else
        echo "$name: bench does not run"
    fi
done
echo "builds measured:$runnable" | tee -a "$out/toolchains.txt"
(cd benchmarks/rust && RUSTFLAGS="-C target-cpu=native" CARGO_TARGET_DIR="$job/stx_btree/.build/rust-bench" \
    cargo build --release --offline --locked 2>&1 | tail -1)
rust="$job/stx_btree/.build/rust-bench/release/bbtree-reference-bench"

echo "== interleaved cells"
# Implementations alternate within each repetition, so load on the shared
# host falls on all three alike.
raw="$out/raw.csv"
echo "build,implementation,map,key,size,threads,workload,operations,ns_per_op,checksum,repetition" > "$raw"
for cell in "unsync u64 10000000" "unsync str16 1000000" "shared u64 10000000"; do
    for repetition in 1 2 3; do
        for build in $runnable rust; do
            program="./.build/$build/stx_btree_bench"
            if [ "$build" = rust ]; then
                program="$rust"
            fi
            # shellcheck disable=SC2086
            "$program" $cell 1000000 | awk -v b="$build" -v r="$repetition" -F, 'NF == 9 { print b "," $0 "," r }' >> "$raw"
        done
    done
done
cat /proc/loadavg >> "$out/toolchains.txt"

echo "done"
