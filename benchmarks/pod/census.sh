#!/usr/bin/env bash
# Heap-request census of the C++ and Rust benches on one cell
# (benchmarks/pod/alloc_census.c under LD_PRELOAD), for the write-gap
# diagnosis. Submitted by tools/prepare_pod_job.sh with this script as run.sh.
set -euo pipefail
job="$(pwd)"
out="$job/results"
mkdir -p "$out"
remove_scratch() {
    rm -rf "$job/toolchain" "$job/stx_btree/.build" "$job/stx_btree/benchmarks/rust/vendor"
}
trap remove_scratch EXIT
export RUSTUP_HOME="$job/toolchain/rustup"
export CARGO_HOME="$job/toolchain/cargo"
export PATH="$CARGO_HOME/bin:$PATH"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init.sh
sh rustup-init.sh -y --profile minimal --default-toolchain stable --no-modify-path
cd "$job/stx_btree"
gcc -O2 -shared -fPIC -o "$job/alloc_census.so" benchmarks/pod/alloc_census.c -ldl
cmake -S . -B .build/gcc -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=g++ "-DCMAKE_CXX_FLAGS=-march=native" \
    -DSTX_BTREE_WARNINGS_AS_ERRORS=OFF -DSTX_BTREE_BUILD_TESTS=OFF > /dev/null
cmake --build .build/gcc --parallel 4 --target stx_btree_bench > "$out/build-gcc.log" 2>&1
(cd benchmarks/rust && RUSTFLAGS="-C target-cpu=native" CARGO_TARGET_DIR="$job/stx_btree/.build/rust-bench" \
    cargo build --release --offline --locked 2>&1 | tail -1)
rust="$job/stx_btree/.build/rust-bench/release/bbtree-reference-bench"
for size in 1000000 10000000; do
    ALLOC_CENSUS_OUT="$out/census-cpp-$size.csv" LD_PRELOAD="$job/alloc_census.so" \
        ./.build/gcc/stx_btree_bench unsync u64 "$size" 1000000 > "$out/run-cpp-$size.csv"
    ALLOC_CENSUS_OUT="$out/census-rust-$size.csv" LD_PRELOAD="$job/alloc_census.so" \
        "$rust" unsync u64 "$size" 1000000 > "$out/run-rust-$size.csv"
done
echo "done"
