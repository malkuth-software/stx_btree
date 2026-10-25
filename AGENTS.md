# stx_btree

A header-only C++20 form of bbtree (Xiangpeng Hao,
https://github.com/XiangpengHao/bbtree), offered under bbtree's terms, MIT OR
Apache-2.0. Keep LICENSE, NOTICE and PROVENANCE.md intact and accurate; a
change that translates more of bbtree updates PROVENANCE.md's tables.

## Code style (mandatory)

All C++ follows docs/PROGRAMMING_HOUSE_STYLE.md (the gui_forms copy). Read
it in full before changing code. No auto, lambdas, trailing returns,
structured bindings, coroutines, ranges pipelines or `->`; named functors;
explicit types and initialization; validation before mutation. Match the
surrounding naming and comment density. Before committing:

    python3 -B tools/check_house_style.py include tests benchmarks/cpp examples
    python3 -B tools/check_lifetime_rules.py include tests benchmarks/cpp examples

## Design authority

bbtree's design record (design/03-decisions.md, decisions Dnn, at the
commit in benchmarks/rust/UPSTREAM_COMMIT) is the reason for every layout,
threshold and protocol here; docs/DESIGN.md lists where the C++ form
departs. Do not change a node layout, an underflow threshold, the split
rule, the prefix upkeep or the latch protocol without a measured reason, and
record it in docs/DESIGN.md. The shared map's racing reads are deliberate
and documented there; keep header fields, edges, latch words and the root
pointer atomic, and bound every racing read by a node's capacity.

## Build and checks

    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build
    ctest --test-dir build --output-on-failure

Every build keeps a sanitizer tree beside it (STX_BTREE_SANITIZE=ON, ASan,
UBSan and LSan, halt on error); run the whole suite there before pushing.
On the owner's machine run builds through m4build from this repository,
serialized, and never edit the remote mirror:

    /Users/ultimussecundai/.local/bin/m4build -- sh tools/verify.sh

verify.sh builds the release and sanitizer trees with Homebrew LLVM, runs
both suites and checks a relocated installed consumer. Also build with
GCC (g++-15 on the Mini) before claiming portability; GCC found defects
Clang did not.

## Benchmarks

Compare against bbtree only through benchmarks/cpp and benchmarks/rust,
which must keep identical workloads and checksums; tools/run_benchmarks.py
runs the matrix and refuses to overwrite results. Record compiler, flags,
allocator, machine and repetitions with every claim, keep negative results,
and never call a cell faster without its measurement. Store run output under
.build/ on the Mini and copy it to results/ before the next mirror sync.

The full matrix may run on the Fable compute pod (~/.local/bin/fable-compute,
README in ~/.local/share/fable-compute/) through tools/prepare_pod_job.sh,
only when no other session is using the pod; coordinate with the session
using it. Never stop the pod; the owner decides. Timings on that shared host
are indicative, not evidence of small differences.

## Scope

File maps, stores and leaf annexes, sets, the entry API, bulk building and
splitting, and the Verus proofs are not translated. Adding one follows the
same rules: port with bbtree's tests in spirit, update PROVENANCE.md, and
measure against the Rust crate.
