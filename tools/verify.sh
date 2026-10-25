#!/bin/sh
# The release tree, the adjacent sanitizer tree, and a relocated installed
# consumer, from the repository root. Run on the measurement host through
# m4build on the owner's machine. Uses Homebrew LLVM when present.
set -eu
cxx="${CXX:-/opt/homebrew/opt/llvm/bin/clang++}"
cmake="${CMAKE:-/opt/homebrew/bin/cmake}"
ctest="${CTEST:-/opt/homebrew/bin/ctest}"
root="$(pwd)"
"$cmake" -S . -B .build/release -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="$cxx" "-DCMAKE_CXX_FLAGS=-mcpu=native"
"$cmake" --build .build/release -j 8
"$ctest" --test-dir .build/release --output-on-failure
"$cmake" -S . -B .build/sanitize -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_CXX_COMPILER="$cxx" -DSTX_BTREE_SANITIZE=ON -DSTX_BTREE_BUILD_BENCHMARKS=OFF
"$cmake" --build .build/sanitize -j 8
ASAN_OPTIONS=detect_leaks=1:halt_on_error=1:abort_on_error=0:print_summary=1 \
UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1:print_summary=1 \
    "$ctest" --test-dir .build/sanitize --output-on-failure
# Install, move the prefix, and build the consumer against the moved copy.
rm -rf .build/install-original .build/install-relocated .build/installed-consumer
"$cmake" --install .build/release --prefix .build/install-original
mv .build/install-original .build/install-relocated
"$cmake" -S tests/installed -B .build/installed-consumer -DCMAKE_CXX_COMPILER="$cxx" \
    -DCMAKE_PREFIX_PATH="$root/.build/install-relocated"
"$cmake" --build .build/installed-consumer
"$ctest" --test-dir .build/installed-consumer --output-on-failure
echo "verify: release, sanitizer and relocated installed consumer passed"
