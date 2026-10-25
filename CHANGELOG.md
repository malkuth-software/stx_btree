# Changelog

## 0.1.0 (unreleased)

First C++ form of bbtree 0.1.5 (upstream commit 8adae97).

- Inline-key encodings for `std::uint64_t`, `std::int64_t`,
  `std::array<std::uint8_t, N>` and `std::string`; `InlineKeyTraits` for
  other keys.
- Node layouts, the lane-group inline-key count, per-node prefixes fitted to
  fences, the shared prefix, leaf heads and hash tags.
- `unsync::BBTreeMap`: find, insert, try_insert, remove, pop_first,
  pop_last, lower_bound, bidirectional iterators, `get_many`, `insert_many`.
- `BBTreeMap` (shared): get_copied, get_cloned, read, contains, update,
  insert, try_insert, update_or_insert, get_or_insert, remove, remove_if,
  scan, scan_rev, `get_many_copied`, `insert_many`, and owner `clear` and
  `for_each_mut`.
- Differential, threaded and stress tests, a custom-key example, an
  installed-consumer test, matched C++/Rust benchmarks and their runner.
- Not a stable ABI or memory format.
