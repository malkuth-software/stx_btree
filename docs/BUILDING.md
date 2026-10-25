# Building stx_btree

C++20, CMake 3.21 or later, and a threads library. No other dependency. The
library is header-only; CMake builds its tests, an example and the benchmark.

## Configure, build, test

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
ctest --test-dir build --output-on-failure
```

The tests are `stx_btree_unsync_map_test` and `stx_btree_shared_map_test`
(differential against `std::map`, with a full structural invariant check),
`stx_btree_stress_test` (ten threads, two seconds per tree shape; pass a
number of seconds to run longer) and `stx_btree_custom_key_example`.

Options:

| Option | Default | Effect |
| --- | --- | --- |
| `STX_BTREE_BUILD_TESTS` | on at top level | the tests and example |
| `STX_BTREE_BUILD_BENCHMARKS` | on at top level | `stx_btree_bench` |
| `STX_BTREE_SANITIZE` | off | ASan and UBSan, no recovery |
| `STX_BTREE_WARNINGS_AS_ERRORS` | on | `-Werror` on the repository's own programs |

## The sanitizer tree

Every build tree keeps a sanitizer tree beside it (house style 5):

```sh
cmake -S . -B build-sanitize -DCMAKE_BUILD_TYPE=RelWithDebInfo -DSTX_BTREE_SANITIZE=ON -DSTX_BTREE_BUILD_BENCHMARKS=OFF
cmake --build build-sanitize
ASAN_OPTIONS=detect_leaks=1:halt_on_error=1 UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1 \
    ctest --test-dir build-sanitize --output-on-failure
```

LeakSanitizer is active on macOS arm64 with Homebrew LLVM 23 (checked with a
deliberate leak) and on Linux.

## Verified toolchains

| Host | Compiler | Trees |
| --- | --- | --- |
| Apple M4, macOS 26.5 | Homebrew LLVM 23.1.2 (`/opt/homebrew/opt/llvm/bin/clang++`), `-mcpu=native` | release, sanitizer, relocated install |
| Apple M4, macOS 26.5 | Homebrew GCC 15.2 (`g++-15`) | release |
| Linux x86-64 (Ubuntu 24.04, AMD EPYC 9575F slice, compute pod) | GCC 13.3, `-march=native` | release (no warnings; tests in the benchmark job) |
| macOS arm64 | Apple clang 21 | development builds of the tests |

`tools/verify.sh` runs the first row on the owner's Mac mini (through
`m4build`): the release tree with its tests, the sanitizer tree with its
tests, then an install that is moved to another directory and consumed by
`tests/installed` through `find_package` alone. A portability claim beyond
these rows is not a test result.

## Install and consume

```sh
cmake --install build --prefix /your/prefix
```

installs the headers, a relocatable CMake package and, under
`share/licenses/stx_btree/`, `LICENSE`, `NOTICE` and `PROVENANCE.md`.

```cmake
find_package(stx_btree 0.1 CONFIG REQUIRED)
target_link_libraries(my_program PRIVATE stx_btree::stx_btree)
```

Or add the source directory with `add_subdirectory` and link the same target.

## House-style checks

```sh
python3 -B tools/check_house_style.py include tests benchmarks/cpp examples
python3 -B tools/check_lifetime_rules.py include tests benchmarks/cpp examples
```

Both cover spelling and two lifetime rules only; ownership, initialization
and lifetimes still need review against docs/PROGRAMMING_HOUSE_STYLE.md.

## The reference benchmark

`benchmarks/rust` runs bbtree itself on the same workloads. It needs the
pinned upstream checkout (`tools/fetch_upstream.sh`) and a Rust toolchain:

```sh
RUSTFLAGS="-C target-cpu=native" CARGO_TARGET_DIR=build/rust-bench \
    cargo build --release --manifest-path benchmarks/rust/Cargo.toml
```

[Measurements](MEASUREMENTS.md) covers running the matrix.
