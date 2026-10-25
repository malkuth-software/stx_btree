#!/usr/bin/env bash
# Diagnosis job for the x86-64 write gap (inserts and removes 1.4-1.7x
# bbtree's time with GCC and Clang; at parity on the M4). Builds the bench
# with each compiler twice: with the library's page allocator, and with the
# library's PooledPageAllocator (pooled_page_allocator.hpp), which isolates the
# system allocator's aligned allocations and page placement. Tries perf stat
# from Ubuntu's linux-tools if the kernel allows it. Submitted by
# tools/prepare_pod_job.sh with this script as run.sh.
set -euo pipefail
job="$(pwd)"
out="$job/results"
mkdir -p "$out"
remove_scratch() {
    rm -rf "$job/toolchain" "$job/clang" "$job/clang-debs" "$job/perf" "$job/stx_btree/.build" "$job/stx_btree/benchmarks/rust/vendor"
}
trap remove_scratch EXIT
export RUSTUP_HOME="$job/toolchain/rustup"
export CARGO_HOME="$job/toolchain/cargo"
export PATH="$CARGO_HOME/bin:$PATH"

echo "== toolchains"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init.sh
sh rustup-init.sh -y --profile minimal --default-toolchain stable --no-modify-path
# A restarted pod comes up with empty package lists.
apt-get update -qq > "$out/apt-update.log" 2>&1
mkdir -p "$job/clang-debs" "$job/clang"
(cd "$job/clang-debs" && apt-get download clang-18 libclang-cpp18 libllvm18 libclang-common-18-dev llvm-18-linker-tools libclang1-18)
for deb in "$job"/clang-debs/*.deb; do dpkg -x "$deb" "$job/clang"; done
clang_libraries="$job/clang/usr/lib/x86_64-linux-gnu:$job/clang/usr/lib/llvm-18/lib"
clang="$job/clang/usr/lib/llvm-18/bin/clang++"
LD_LIBRARY_PATH="$clang_libraries" "$clang" --version | head -1 | tee "$out/toolchains.txt"
g++ --version | head -1 | tee -a "$out/toolchains.txt"
rustc --version | tee -a "$out/toolchains.txt"
cat /proc/loadavg >> "$out/toolchains.txt"

echo "== perf"
perf=""
mkdir -p "$job/perf"
kernel="$(uname -r)"
version="${kernel%-generic}"
if (cd "$job/perf" && apt-get download "linux-tools-$version" "linux-tools-$kernel") > "$out/perf-download.log" 2>&1; then
    for deb in "$job"/perf/*.deb; do dpkg -x "$deb" "$job/perf/root"; done
    candidate="$(find "$job/perf/root" -type f -name perf | head -1)"
    if [ -n "$candidate" ] && "$candidate" stat -e task-clock true > "$out/perf-probe.log" 2>&1; then
        if "$candidate" stat -e cycles,instructions true >> "$out/perf-probe.log" 2>&1; then
            perf="$candidate"
        fi
    fi
fi
echo "perf: ${perf:-unavailable (see perf-probe.log, perf-download.log)}" | tee -a "$out/toolchains.txt"

cd "$job/stx_btree"
echo "== benches"
build_bench() {
    local name="$1" compiler="$2" flags="$3"
    LD_LIBRARY_PATH="$clang_libraries" cmake -S . -B ".build/$name" -DCMAKE_BUILD_TYPE=Release "-DCMAKE_CXX_COMPILER=$compiler" \
        "-DCMAKE_CXX_FLAGS=$flags" -DSTX_BTREE_WARNINGS_AS_ERRORS=OFF -DSTX_BTREE_BUILD_TESTS=OFF > /dev/null
    LD_LIBRARY_PATH="$clang_libraries" cmake --build ".build/$name" --parallel 4 --target stx_btree_bench > "$out/build-$name.log" 2>&1
}
build_bench gcc g++ "-march=native"
build_bench gcc_pooled g++ "-march=native -DSTX_BTREE_BENCH_POOLED"
build_bench clang "$clang" "-march=native"
build_bench clang_pooled "$clang" "-march=native -DSTX_BTREE_BENCH_POOLED"
(cd benchmarks/rust && RUSTFLAGS="-C target-cpu=native" CARGO_TARGET_DIR="$job/stx_btree/.build/rust-bench" \
    cargo build --release --offline --locked 2>&1 | tail -1)
rust="$job/stx_btree/.build/rust-bench/release/bbtree-reference-bench"

echo "== interleaved cells"
raw="$out/raw.csv"
echo "build,implementation,map,key,size,threads,workload,operations,ns_per_op,checksum,repetition" > "$raw"
for cell in "unsync u64 10000000" "unsync u64 1000000" "unsync str16 1000000" "shared u64 10000000" "shared str16 1000000"; do
    for repetition in 1 2 3; do
        for build in gcc gcc_pooled clang clang_pooled rust; do
            program="./.build/$build/stx_btree_bench"
            if [ "$build" = rust ]; then
                program="$rust"
            fi
            # shellcheck disable=SC2086
            "$program" $cell 1000000 | awk -v b="$build" -v r="$repetition" -F, 'NF == 9 { print b "," $0 "," r }' >> "$raw"
        done
    done
done

if [ -n "$perf" ]; then
    echo "== perf stat (whole process, unsync u64 10M)"
    for build in clang clang_pooled rust; do
        program="./.build/$build/stx_btree_bench"
        if [ "$build" = rust ]; then
            program="$rust"
        fi
        "$perf" stat -e task-clock,cycles,instructions,cache-misses,dTLB-load-misses,page-faults \
            -o "$out/perf-stat-$build.txt" "$program" unsync u64 10000000 1000000 > /dev/null 2>&1 || true
    done
fi
cat /proc/loadavg >> "$out/toolchains.txt"
echo "done"
