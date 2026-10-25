# Measurements

The C++ form is measured against bbtree itself, on identical workloads,
by two matched programs: `benchmarks/cpp/stx_btree_bench.cpp` and
`benchmarks/rust` (the pinned bbtree crate, commit in
`benchmarks/rust/UPSTREAM_COMMIT`). No benchmark result here is evidence
beyond the workload, machine and toolchain it records.

## Method

- **Same work.** Keys come from indexes through the SplitMix64 finalizer, in
  four families: `u64`; `uuid` (16 bytes); `str16` (16 random hex
  characters, no shared prefixes); `url` (the same behind a 26-byte common
  head). Lookups, removals and scans use the same index sequences in both
  programs, and every cell reports a checksum; the runner fails if the two
  programs disagree on any checksum.
- **Same conditions.** Both programs use the system allocator; C++ is built
  `-O3 -DNDEBUG` with `-mcpu=native` (`-march=native` on x86-64), Rust with
  `-C target-cpu=native`, `codegen-units = 1`, fat LTO. Keys are generated
  before timing; argument copies of keys are inside the timed region in
  both.
- **Cells.** Per map and key family, one process builds a map of `size`
  random keys (`insert_random`) and then times `get_hit`, `get_miss`,
  batched hits (64 per call), `range64` (unsync) or `scan100` (shared),
  `iterate` (unsync), `update` (shared), `remove_random`, then
  `insert_sequential` and `insert_random_batched` (16 per call) into fresh
  maps. Threaded cells (shared map) time inserts of disjoint shares, lookups
  half missing (single and batched), and a 90/10 lookup/update mix. Times
  are mean nanoseconds per operation, wall time over all threads for
  threaded cells.
- **Runner.** `tools/run_benchmarks.py` runs every cell as a fresh process,
  interleaves the programs and alternates which goes first per repetition,
  records the environment, and refuses to overwrite a result directory.
  Summaries give medians and the range of the repetitions.

These are throughput timings. They are not instruction counts, and on a
shared host (the compute pod) they are indicative only.

## Apple M4 (Mac mini), 2026-10-25: partial run

Homebrew LLVM 23.1.2 (`-mcpu=native`) against rustc 1.99.0-nightly
(2026-08-09), macOS 26.5, system allocator. The three-repetition matrix was
stopped on request during its first repetition, so every cell below is
**one run**; raw rows, environment and a one-repetition quick run at 100K and
1M entries are in [results/2026-10-25-m4-partial](../results/2026-10-25-m4-partial).
All 216 completed rows agree on checksums with their Rust counterparts.
Rust/C++ above 1 means C++ is faster.

### Unsync map

| key, size | get hit | get miss | batched get | insert | batched insert | remove | range / iterate |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| u64, 1M | 33.8 / 36.6 (1.08) | 25.9 / 29.4 (1.13) | 22.0 / 23.5 (1.07) | 74.9 / 100.0 (1.33) | 47.4 / 48.6 (1.02) | 103.2 / 107.0 (1.04) | 148.5 / 191.0 (1.29) |
| u64, 10M | 109.8 / 114.2 (1.04) | 91.0 / 80.4 (0.88) | 45.2 / 43.0 (0.95) | 191.2 / 193.4 (1.01) | 83.7 / 93.9 (1.12) | 284.1 / 274.1 (0.96) | 405.3 / 453.6 (1.12) |
| uuid, 1M | 49.6 / 48.8 (0.98) | 29.3 / 32.2 (1.10) | 27.7 / 30.5 (1.10) | 94.1 / 93.3 (0.99) | 53.7 / 53.0 (0.99) | 140.5 / 140.7 (1.00) | 237.8 / 290.4 (1.22) |
| uuid, 10M | 104.2 / 93.7 (0.90) | 77.9 / 88.2 (1.13) | 42.9 / 47.5 (1.11) | 194.6 / 187.0 (0.96) | 81.8 / 82.4 (1.01) | 258.8 / 244.5 (0.94) | 435.5 / 505.3 (1.16) |
| str16, 1M | 113.7 / 153.8 (1.35) | 87.0 / 97.6 (1.12) | 42.7 / 52.0 (1.22) | 151.8 / 150.1 (0.99) | 84.3 / 97.9 (1.16) | 250.6 / 343.5 (1.37) | 428.0 / 650.1 (1.52) |
| url, 1M | 169.1 / 169.3 (1.00) | 91.7 / 99.2 (1.08) | 65.9 / 58.8 (0.89) | 191.7 / 184.3 (0.96) | 115.8 / 122.6 (1.06) | 440.6 / 429.7 (0.98) | 456.8 / 655.0 (1.43) |

Cells read C++ ns / Rust ns (Rust/C++). Full iteration per entry: u64 1M
1.37 / 1.92, url 1M 5.06 / 7.46.

### Shared map

| key, size | get hit | get miss | batched get | insert | batched insert | update | remove | scan100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| u64, 1M | 37.3 / 38.4 (1.03) | 28.0 / 30.4 (1.09) | 29.8 / 28.3 (0.95) | 77.7 / 76.7 (0.99) | 67.0 / 60.5 (0.90) | 41.2 / 40.7 (0.99) | 103.1 / 109.2 (1.06) | 177.6 / 192.3 (1.08) |
| u64, 10M | 114.1 / 90.4 (0.79) | 86.9 / 69.4 (0.80) | 51.2 / 46.2 (0.90) | 200.1 / 172.0 (0.86) | 113.4 / 89.8 (0.79) | 137.4 / 100.4 (0.73) | 284.0 / 221.9 (0.78) | 466.2 / 447.8 (0.96) |
| uuid, 1M | 56.4 / 52.5 (0.93) | 33.8 / 35.8 (1.06) | 37.2 / 34.4 (0.92) | 101.3 / 89.7 (0.89) | 75.1 / 76.7 (1.02) | 59.6 / 59.5 (1.00) | 132.9 / 140.8 (1.06) | 310.2 / 325.8 (1.05) |
| uuid, 10M | 104.0 / 95.4 (0.92) | 75.0 / 70.4 (0.94) | 55.5 / 53.2 (0.96) | 194.0 / 180.7 (0.93) | 112.1 / 108.0 (0.96) | 128.8 / 119.3 (0.93) | 256.7 / 247.2 (0.96) | 562.1 / 563.4 (1.00) |
| str16, 1M | 116.4 / 136.8 (1.18) | 72.5 / 77.4 (1.07) | 59.4 / 57.6 (0.97) | 167.5 / 171.7 (1.02) | 118.6 / 110.6 (0.93) | 127.6 / 150.6 (1.18) | 252.6 / 370.7 (1.47) | 626.9 / 841.4 (1.34) |
| url, 1M | 181.6 / 169.3 (0.93) | 79.1 / 84.3 (1.07) | 93.0 / 68.8 (0.74) | 222.0 / 204.6 (0.92) | 151.4 / 135.7 (0.90) | 171.2 / 179.1 (1.05) | 455.2 / 465.4 (1.02) | 701.8 / 859.7 (1.23) |

Threaded cells of the shared map were not reached in this run. The earlier
one-repetition quick run (1M entries) measured `u64` lookups half missing at
4 threads 16.2 / 15.9 ns and 10 threads 11.7 / 11.2 ns; batched 10.5 / 11.8
and 7.1 / 7.8; `str16` lookups at 10 threads 22.8 / 32.7 ns.

### Reading these numbers

- At 1M entries the two implementations are close: most cells within ±10%,
  with C++ ahead on string removals, scans and unsync iteration.
- **Open gap: the shared map at 10M `u64` keys** runs 10–27% behind bbtree on
  lookups, updates, removals and inserts, while the unsync map at the same
  size is on par and the shared map at 10M `uuid` keys is within 4–8%. One
  run each; not yet diagnosed. The next step is an instruction and
  cache-miss comparison of `get_copied` at 10M.
- **Smaller gaps:** sequential (append) inserts 4–15% behind; the shared
  map's batched inserts 7–21% behind; batched `url` lookups behind in both
  maps.

## Compute pod run, 2026-10-25: Linux x86-64, GCC 13.3

The full matrix (three repetitions, thread counts 1, 2, 4) on the Fable
compute pod: AMD EPYC 9575F slice, 4 vCPUs, Ubuntu 24.04, GCC 13.3
`-O3 -march=native` against stable Rust 1.99.1 (`target-cpu=native`, fat
LTO), glibc malloc in both. `tools/prepare_pod_job.sh` assembles the job and
`benchmarks/pod/run.sh` builds and runs it. The tree measured is commit
901289c (the search code is unchanged since). Results, with the environment:
`results/2026-10-25-pod-x86-gcc13/`.

**On this host the C++ form is behind bbtree.** The geometric mean of
Rust/C++ time over all 168 cells is 0.70 (range 0.36–1.35). Point lookups,
misses and updates are worst, at 0.56–0.63 per workload; inserts and
removals are at 0.70–0.81; scans and range reads are at parity (0.99–1.00).
Some cells have a wide spread (the shared `u64` 1M lookups run from 69 to
201 ns), because the pod's CPU slice is shared.

The M4 numbers above (LLVM 23, NEON) were near parity on the same code, so
the gap belongs to this toolchain and target, not to the design. It is not
yet diagnosed. Candidates, in the order to check them: GCC's code for the
vector-extension count (`detail/vector_count.hpp`) and for the forced-inline
descent, compared with LLVM's on x86; the 16-byte lane groups against
bbtree's explicit AVX-512 count on this Zen 5 core; and a Clang build on the
same pod, which separates the compiler from the target.

### Diagnosis, 2026-10-25

Four jobs on the same pod (`benchmarks/pod/diagnose.sh`, results in
`results/2026-10-25-pod-x86-diagnosis/`) built the C++ bench several ways and
ran each beside bbtree, interleaved within every repetition (3–5) so the
shared host's load (load average 30–75 on the 4-vCPU slice) falls on all
alike. Ratios are C++ time over bbtree time; cells move ±8% between runs.

| cell | GCC 13 (before) | GCC 13 (after) | Clang 18 |
| --- | ---: | ---: | ---: |
| unsync u64 10M get_hit | 1.79–1.84 | 1.37 | 1.13–1.24 |
| unsync u64 10M get_miss | 1.83–1.87 | 1.56 | 1.12–1.17 |
| shared u64 10M get_hit | 1.90–1.94 | 1.81 | 1.23–1.26 |
| unsync str16 1M get_hit | 1.89–1.92 | (unchanged code) | 1.78–1.81 |
| unsync u64 10M insert_random | 1.81–1.83 | 1.72 | 1.46–1.64 |

What that separates:

- **GCC's code on x86-64 is most of the integer lookup gap.** Clang builds of
  the same source run u64 lookups at 1.1–1.3× bbtree; GCC at 1.8–1.9×.
  `-march=x86-64-v3` (no AVX-512) and `-mtune=generic` change nothing, so it
  is neither AVX-512 nor tuning. GCC compiled the lane sum at the end of the
  node count into one extract and one add per lane (764 `vpextrw` in the
  bench binary); summing by shuffles under GCC (142) took unsync u64 lookups
  from 1.82× to 1.37× bbtree. LLVM keeps the loop (see DESIGN.md, "The node
  search"). GCC lacks the AVX-512 unsigned compare in this kernel too
  (three instructions per compare instead of one); that is not yet changed.
- **Strings are behind with either compiler** (1.7–1.9×), while on the M4
  they were 1.2–1.35× *faster* than bbtree. A 16-byte key fits libc++'s inline
  string (22 bytes, macOS) but not libstdc++'s (15, Linux), so on Linux every
  stored key is on the heap; bbtree's `String` is always on the heap, so this
  explains the M4 lead, not yet the Linux lag. A libc++ build on the pod would
  separate the library, but libc++ 18 lacks `std::atomic_ref`.
- **Writes are behind with either compiler** (inserts and removes 1.4–1.7×);
  see the next section.
- Clang 18 on Linux found a portability defect, now fixed: the sized aligned
  `operator delete` is not declared there by default.

### Writes, 2026-10-25

On the M4 inserts and removes are at parity (unsync u64 10M: 1.01 and
0.96); on the pod they are 1.5–1.8× with Clang as with GCC, beyond the
lookup gap. Four probes (`results/2026-10-25-pod-x86-writes/`):

- **Page placement matters, and both pay for it.** With a pooled arena page
  allocator (`benchmarks/pod/arena_page_allocator.hpp`, bench-only, built in
  by `-DSTX_BTREE_BENCH_ARENA`), the Clang build at 1M runs inserts at 0.94×
  bbtree's time (1.33× with the default allocator), removes at 0.86× (1.35×),
  lookups at 0.77× (1.27×) and range reads at 0.48× (1.01×). At 10M it helps
  less: inserts 1.46× (1.56×), removes 1.66× (1.78×). The pod's transparent
  huge pages are madvise-only and unused, so this is 4 KiB-page placement.
- **The two programs make the same allocations.** An `LD_PRELOAD` census
  (`benchmarks/pod/alloc_census.c`) counts identical calls for both: 744 407
  `posix_memalign(1024, 1024)` and 21 791 `posix_memalign(512, 512)` at 10M,
  and the same address spread (1.55 GB for 0.76 GB of pages: glibc's aligned
  path leaves gaps for both). Placement does not separate them; the arena
  removes a cost bbtree pays too.
- **They do the same work.** Callgrind with cache and branch simulation
  (x86-64-v3 builds, since valgrind 3.22 cannot run AVX-512; unsync u64 1M,
  200 000 operations) counts 2.10 G instructions for C++ against 2.21 G for
  bbtree, 30.3 M against 30.6 M simulated L1 read misses, 1.74 M against 1.67 M
  last-level write misses, and fewer mispredicted branches (5.9 M against
  6.6 M).
- **Hardware counters are not available:** the pod's kernel refuses `perf`
  (`perf_event_paranoid` 4; "No permission to enable cycles event").

So by every count available there, the C++ write path does no more work
than bbtree's, yet runs slower on this Zen 5 slice; what separates them is a
hardware effect the simulators do not model (memory-level parallelism, store
forwarding in the shifts, or similar), and it needs hardware counters on a
machine that allows them. Independently, a pooled page allocator is a
measured gain on Linux for both lookups and writes.

### Pooled page allocator, M4, 2026-10-25

`stx_btree_bench` and `stx_btree_bench_pooled` (the same source on
`PooledPageAllocator`) beside bbtree, interleaved, three repetitions, LLVM 23,
`results/2026-10-25-m4-pooled/raw.csv`. On macOS the pool is neutral: every
cell is within 3% of the default allocator (unsync u64 10M: inserts 164.3 and
164.4 ns, removes 231.2 and 226.5 ns; shared u64 10M lookups 98.7 and
96.9 ns).

### Pooled page allocator, pod, 2026-10-25

`benchmarks/pod/diagnose_writes.sh` at da18ed3: GCC 13.3 and Clang 18.1, each
with the default and the pooled allocator, `-march=native`, beside bbtree
(rustc 1.99.1, `target-cpu=native`), interleaved, three repetitions, medians,
`results/2026-10-25-pod-x86-pooled/raw.csv`. This run was disturbed: the
default Clang build's unsync u64 10M lookups, unchanged since, ran at 1.85x
bbtree's time against 1.14-1.25x in the earlier run
(`results/2026-10-25-pod-x86-diagnosis/run3-ab`), so the ratios to bbtree are
indicative only (the host's load average, 21-22 here and 55-75 then, is the
whole 64-core host's and does not show it). The pooled and default builds ran
interleaved under the same conditions, so their comparison is the firmer one. Clang, ratio to
bbtree's time, default then pooled:

| cell | default | pooled |
|---|---|---|
| unsync u64 1M insert_random | 1.40 | 1.02 |
| unsync u64 1M remove_random | 1.12 | 1.00 |
| unsync u64 1M insert_sequential | 1.07 | 1.32 |
| unsync u64 1M get_hit | 1.49 | 1.58 |
| unsync u64 10M insert_random | 1.42 | 1.28 |
| unsync u64 10M remove_random | 1.37 | 1.21 |
| unsync u64 10M insert_sequential | 1.10 | 0.69 |
| unsync u64 10M get_hit | 1.85 | 1.70 |
| unsync str16 1M insert_random | 1.17 | 1.04 |
| unsync str16 1M remove_random | 1.14 | 0.91 |
| shared u64 10M insert_random | 1.34 | 1.22 |
| shared u64 10M remove_random | 1.51 | 1.40 |
| shared str16 1M insert_sequential | 1.50 | 1.01 |

GCC moves the same way (unsync u64 1M inserts 1.51 to 1.12; 10M removes 1.34
to 1.29). On Linux the pool takes most of the write gap at 1M and about a
third of it at 10M, and helps the 10M lookups; at 1M the sequential inserts
and the u64 lookups were slower with it in this run. The lookup gap (1.5-2.1x
here) is beyond what the allocator explains and was inflated in this run; a
repeat on a quiet slice is needed before reading anything finer from it.

## Reproduce on the Mac mini

```sh
~/.local/bin/m4build -- sh tools/verify.sh
~/.local/bin/m4build -- env RUSTFLAGS="-C target-cpu=native" CARGO_TARGET_DIR=.build/rust-bench \
    cargo build --release --manifest-path benchmarks/rust/Cargo.toml
~/.local/bin/m4build -- env STX_BTREE_COMMIT=$(git rev-parse --short HEAD) \
    python3 -B tools/run_benchmarks.py --output .build/bench-results/NEW-NAME
```

Use a new output name each time, keep measurement runs sequential with
builds, and copy results out of `.build/` before the next mirror sync.
