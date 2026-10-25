#!/usr/bin/env bash
# Callgrind (instruction counts and simulated cache misses, inclusive per
# function) of the Clang-built C++ bench and the Rust bench on one cell, for
# the write-gap diagnosis: deterministic, so the shared host's load does not
# enter. Both are built for x86-64-v3 (AVX2): valgrind 3.22 cannot run
# AVX-512 code, so counts here are for that target. Submitted by tools/prepare_pod_job.sh with this script as run.sh.
set -euo pipefail
job="$(pwd)"
out="$job/results"
mkdir -p "$out"
remove_scratch() {
    rm -rf "$job/toolchain" "$job/clang" "$job/clang-debs" "$job/stx_btree/.build" "$job/stx_btree/benchmarks/rust/vendor"
}
trap remove_scratch EXIT
export RUSTUP_HOME="$job/toolchain/rustup"
export CARGO_HOME="$job/toolchain/cargo"
export PATH="$CARGO_HOME/bin:$PATH"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init.sh
sh rustup-init.sh -y --profile minimal --default-toolchain stable --no-modify-path
mkdir -p "$job/clang-debs" "$job/clang"
(cd "$job/clang-debs" && apt-get download clang-18 libclang-cpp18 libllvm18 libclang-common-18-dev llvm-18-linker-tools libclang1-18)
for deb in "$job"/clang-debs/*.deb; do dpkg -x "$deb" "$job/clang"; done
export LD_LIBRARY_PATH="$job/clang/usr/lib/x86_64-linux-gnu:$job/clang/usr/lib/llvm-18/lib"
clang="$job/clang/usr/lib/llvm-18/bin/clang++"
cd "$job/stx_btree"
cmake -S . -B .build/clang -DCMAKE_BUILD_TYPE=RelWithDebInfo "-DCMAKE_CXX_COMPILER=$clang" "-DCMAKE_CXX_FLAGS=-march=x86-64-v3 -O3 -DNDEBUG" \
    -DSTX_BTREE_WARNINGS_AS_ERRORS=OFF -DSTX_BTREE_BUILD_TESTS=OFF > /dev/null
cmake --build .build/clang --parallel 4 --target stx_btree_bench > "$out/build-clang.log" 2>&1
(cd benchmarks/rust && RUSTFLAGS="-C target-cpu=x86-64-v3" CARGO_TARGET_DIR="$job/stx_btree/.build/rust-bench" \
    cargo build --release --offline --locked 2>&1 | tail -1)
rust="$job/stx_btree/.build/rust-bench/release/bbtree-reference-bench"
unset LD_LIBRARY_PATH
for build in cpp rust; do
    program=./.build/clang/stx_btree_bench
    if [ "$build" = rust ]; then
        program="$rust"
    fi
    valgrind --tool=callgrind --cache-sim=yes --callgrind-out-file="$out/callgrind.$build.out" \
        "$program" unsync u64 1000000 200000 > "$out/run-$build.csv" 2> "$out/valgrind-$build.log"
    callgrind_annotate --inclusive=yes "$out/callgrind.$build.out" > "$out/inclusive-$build.txt" 2>&1 || true
    callgrind_annotate "$out/callgrind.$build.out" > "$out/self-$build.txt" 2>&1 || true
done
echo "done"
