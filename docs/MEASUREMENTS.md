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

## Compute pod run

A full matrix (three repetitions, thread counts 1, 2, 4) is packaged for the
Fable compute pod (Linux x86-64, AMD EPYC 9575F slice, 4 vCPUs, GCC 13.3
against stable Rust): `tools/prepare_pod_job.sh` assembles `.build/pod-job`
and `benchmarks/pod/run.sh` builds both programs there (crates vendored,
built offline) and runs `tools/run_benchmarks.py`. Its results will be added
under `results/` with their environment.

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
