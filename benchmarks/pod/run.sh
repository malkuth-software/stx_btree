#!/usr/bin/env bash
# The C++/Rust benchmark matrix as one job on the Fable compute pod
# (Linux x86-64, 4 vCPUs, 8 GB, GCC 13). Submitted by tools/prepare_pod_job.sh:
#
#   fable-compute submit .build/pod-job -- bash run.sh
#
# Builds stx_btree with the pod's GCC and the reference bench with a minimal
# Rust toolchain installed inside this job directory (crates vendored, built
# offline), runs the tests once, then the matrix with thread counts 1, 2, 4.
# Results land in results/; the toolchain and build trees are removed at the
# end, as the pod's disk is 5 GB and temporary.
set -euo pipefail
job="$(pwd)"
export RUSTUP_HOME="$job/toolchain/rustup"
export CARGO_HOME="$job/toolchain/cargo"
export PATH="$CARGO_HOME/bin:$PATH"

echo "== toolchain"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init.sh
sh rustup-init.sh -y --profile minimal --default-toolchain stable --no-modify-path
rustc --version
g++ --version | head -1

cd "$job/stx_btree"
echo "== stx_btree (GCC, Release, -march=native)"
cmake -S . -B .build/release -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=g++ \
    "-DCMAKE_CXX_FLAGS=-march=native" -DSTX_BTREE_WARNINGS_AS_ERRORS=OFF
cmake --build .build/release --parallel 4 2>&1 | tee "$job/cxx-build.log"
ctest --test-dir .build/release --output-on-failure

echo "== bbtree reference bench (offline, vendored crates)"
# Cargo reads benchmarks/rust/.cargo/config.toml (the vendored source) from
# its working directory, so it builds from there.
(cd benchmarks/rust && RUSTFLAGS="-C target-cpu=native" CARGO_TARGET_DIR="$job/stx_btree/.build/rust-bench" \
    cargo build --release --offline --locked)

echo "== matrix"
STX_BTREE_COMMIT="$(cat "$job/STX_BTREE_COMMIT")" python3 -B tools/run_benchmarks.py \
    --output "$job/results" --repetitions 3 --thread-counts 1,2,4 \
    --cxx g++ --rustc "$CARGO_HOME/bin/rustc"

echo "== cleanup"
rm -rf "$job/toolchain" .build
echo "done"
