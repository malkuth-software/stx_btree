# Contributing

Read [the design](docs/DESIGN.md), [building](docs/BUILDING.md) and the
[programming house style](docs/PROGRAMMING_HOUSE_STYLE.md) first.

- The design is bbtree's. A change to a layout, threshold, search or latch
  protocol needs a concrete workload, a measured reason, and an entry in
  docs/DESIGN.md; cite the bbtree decision it departs from.
- Every change runs the whole suite in the release and the sanitizer tree
  and builds with both Clang and GCC. Concurrency changes also run the
  stress test for longer (`stx_btree_stress_test 20`).
- Performance claims compare with bbtree through the matched benchmarks,
  with compiler, flags, allocator, machine, repetitions and spread. Keep
  regressions and negative results.
- Contributions are offered under the repository's terms: MIT OR
  Apache-2.0, at the recipient's option. Unless you state otherwise, a
  contribution you submit is dual licensed so, without additional terms.
