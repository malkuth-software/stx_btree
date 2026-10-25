# Tree constructions per weight family, M4 Mac mini, 2026-10-25

`raw.csv`: `stx_btree_optimal_map_bench construct <n> <family> 3` for
n = 1024, 4096, 16384 and families uniform, zipf, log_normal, laplacian,
random, gaps (`construct_weights` in benchmarks/cpp/optimal_map_bench.cpp).
Columns: mode, construction, keys, family, median seconds, min, max,
cost against Knuth's optimum. Constructions run interleaved, order rotated
per repetition; the default allocator.

Build: Release, Homebrew clang 23.1.2 (`-mcpu=native`), from the working tree
after the Knuth layout change (uncommitted at the time of the run).

The Mini was shared with another session's work during this run; absolute
times are indicative, ratios between constructions in one run are firmer.
Seconds are printed to the millisecond, so sub-millisecond builds show 0.
