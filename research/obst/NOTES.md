# Seam locality: research notes

The open question: can an optimal binary search tree with key and gap weights
be built in o(n^2)? Knuth's O(n^2) has stood since 1971. This directory tests
one family of ideas: build optimal trees of small sections, then join
neighbours bottom-up (the "cascade"), re-solving only near the seam where two
sections meet. If every join were local, the total would be set by spine
lengths, not n^2.

`seam_locality.cpp` is the harness. Knuth's tables (leftmost and rightmost
root on ties) are the oracle. For a join of L = (i, m-1), key m and
R = (m, j), each built from Knuth's optimal side trees, it measures:

- **zip**: the seam is a path that interleaves a prefix of L's right spine
  with a prefix of R's left spine, then ends at m; everything off the path
  stays intact. Solved as a lattice-path minimum in O(spine^2).
- **chain (atom locality)**: every subtree hanging off the two facing spines
  stays intact as an atom; the spine keys and m are re-solved freely as a
  small OBST whose gaps are the atoms. Knuth over the chain, O(spine^2).
- **opening depth**: the fewest levels of each atom that must be opened
  (turned into free keys) before the chain becomes exact.
- **changed region**: the number of keys whose subtree in the joined optimum
  differs from their subtree in their side's optimum. With canonical ties an
  unchanged key's whole subtree is unchanged, so this is the top region any
  exact join must rebuild.
- **bottom-up builds**: whole trees built by zips or chains over a midpoint
  or weight-median split, against the optimum.

Weight families: uniform (all 1), random (uniform 1..10^6 on keys and gaps),
keys only, gaps only (the Garsia-Wachs case), Zipf (exponent 1 over a random
permutation, gaps 1), log-uniform (2^U(0,30)), geometric (ratio 0.93, a path).

## Results, 2026-10-25, M4 Mac mini, Apple clang 21, -O2

Exhaustive joins for n <= 12 (every i, m, j; 20 instances per n up to 16), and
1000 sampled joins per instance up to n = 4096 (`./seam 16 4096 1000 7`).

1. **Seam locality (zip) is false.** At n <= 12, 19-51% of joins fail under
   both tie rules, gaps-only included; the worst excess is 22%. At n = 4096 it
   fails in 95-99% of sampled joins for every non-uniform family.
2. **Atom locality (chain) is false.** It repairs about half the zip failures
   at small n, but at n = 4096 still fails in 86-98% of joins (worst excess
   1.4-4.1%).
3. **The damage is deep.** The opening depth needed grows about one level per
   doubling of n (random weights at n = 2048: 39% of joins need more than 8
   levels). Opening by depth costs 2^d, so it does not rescue the idea.
4. **The changed region is linear for most families.** Mean changed keys per
   join at n = 4096 (mean interval 1368 keys): random 370 (27%), keys only
   265 (19%), gaps only 683 (49%), uniform 558 (41%), geometric 586 (43%).
   Zipf is the exception: 22 (1.6%), growing slowly (2.6 at n = 32, 13 at
   1024, 22 at 4096); log-uniform sits between (50, 3.7%).
5. **Bottom-up approximations.** The chain build lands within 0.1-0.5% of
   optimal for random, keys-only, gaps-only, log-uniform and geometric
   weights, 2.6% for Zipf, exact for uniform, in under 1 ms at n = 4096
   against Knuth's 65-81 ms. Approximation in subquadratic time is already
   known (Mehlhorn's weight-balanced trees, Karpinski-Larmore-Rytter), so
   this is not new.

## What it means

A join of two optimal halves rebuilds a constant fraction of the result for
random, uniform and gap-only weights. Re-solving that region is the same
problem at a constant fraction of the size, so any exact scheme of this shape
satisfies T(n) = 2T(n/2) + S(cn) with S the re-solve cost, and stays
quadratic unless the re-solve itself is subquadratic. Locality is not the
lever for those weights.

Skewed weights (Zipf, and partly log-uniform) are different: the region a
join must rebuild stays small. That is the regime where the Monge layer
construction loses to Knuth (docs/OPTIMAL_TREES.md), while uniform weights,
where locality fails worst, are where the Monge layers win. An exact join
for skewed weights would need a cheap way to find the changed region and a
certificate that it is complete; neither exists yet.

## The exact join (`exact_join.cpp`)

The follow-up question: for skewed weights the region a join must rebuild is
small, so find it cheaply and certify it complete.

Finding it needs no certificate. With canonical ties (leftmost optimal root
everywhere) an interval's optimal subtree depends only on that interval, so
the join evaluates Knuth's recurrence top-down on demand and stops wherever it
reaches an interval that is a subtree of a side's canonical tree. Certifying
the rest is branch and bound: each candidate root is tried in order of a lower
bound on its cost and abandoned once the bound exceeds the best exact cost.
The bound cuts the interval by the side trees into known blocks and separator
keys: block optima, plus separator weights, plus an optimal keys-only BST over
the piece weights (each piece's shallowest element is an ancestor of every
element of the pieces below it, so the pieces induce a BST and every element
pays its piece's depth there). Root ranges are narrowed by Knuth's
monotonicity from intervals already known.

**It is exact**: built bottom-up over midpoint and weight-median splits, every
tree matches Knuth's canonical tree node by node (cost and root), n up to 4096
in every family, with ASan and UBSan clean at n <= 128.

**It is not fast.** Weight-median split, M4, Apple clang 21 -O2
(`results/2026-10-25-m4-exact-join.csv`):

| family, n | Knuth candidates | intervals solved | candidates bounded | nodes rebuilt | Knuth ms | join ms |
|---|---|---|---|---|---|---|
| zipf 512 | 245 K | 32 K | 965 K | 1 112 | 0.6 | 228 |
| zipf 2048 | 4.4 M | 1.43 M | 183 M | 4 460 | 15.5 | 29 894 |
| random 2048 | 4.2 M | 2.37 M | 244 M | 5 508 | 18.9 | 6 294 |
| random 4096 | 16.8 M | 9.60 M | 1 964 M | 10 992 | 102 | 48 807 |
| uniform 4096 | 16.8 M | 9.85 M | 2 056 M | 6 198 | 70 | 36 001 |

The intervals solved approach all n^2/2 intervals in every family, and the
candidates bounded grow about 8x per doubling: cubic, worse than Knuth.
Zipf rebuilds only 4 460 nodes at n = 2048, but certifying them solved 1.43 M
intervals.

**Why.** Certifying a root r of (a, b) means showing c(a, r'-1) + c(r', b)
is no smaller for every other r'. Near-optimal roots differ by little, and a
lower bound built from the side trees is loose by much more than that margin,
so most competitors survive to exact evaluation; their child intervals are
misaligned with the side trees (one end at a or b, the other anywhere), are
not known, and each recursively needs the same. The small changed region is a
property of the answer; the proof that it is the answer still touches nearly
every interval. Knuth avoids the bounding entirely by visiting intervals in
an order where his root bounds are always available; the top-down order
loses that.

So the obstacle is sharp: an o(n^2) exact join needs a certificate of root
optimality whose size tracks the changed region, not the competitor set.
Bounds from the side trees alone are too loose to be that certificate.

## A factorization (`context_frontier.cpp`)

FFT saves work by reuse: a butterfly computes each partial result once and
shares it among many outputs, and the n x n matrix is never formed. Knuth's
table is scaffolding in the same sense (the answer is n roots, the table n^2
costs), so a work saving has to come from a factorization that shares partial
results across many intervals instead of materializing them.

**The seam identity.** Split a range before key m into L and R. In any tree
the ancestors of the boundary gap form one path (the seam), interleaving L's
right spine with R's left spine; every other node hangs off it within one
side. With T_L and T_R the trees the whole induces on each side (restriction
to a contiguous range keeps ancestry, since a BST is a treap by depth),

    cost(T) = cost(T_L) + cost(T_R) + cross,

where cross charges every element for its ancestors on the other side, which
are exactly the other side's seam nodes above its own seam node. Per pair of
seam nodes (x from L, y from R) the lower one pays its block weight (the node
and what hangs off it within its side), so cross >= sum over pairs of
min(w_x, w_y), with equality when the heavier block is always the higher.

Measured on optimal trees (2000 sampled joins per family, n = 64 and 2048):
the identity holds with zero residual in every join, and **cross equals the
pairwise-min sum in every optimal join**, including the 6-36% where a spine
is not decreasing in block weight. So the two sides of an optimal tree
interact only through the multisets of their facing spines' block weights:

    cross = integral over t of N_L(t) * N_R(t) dt,

N(t) the number of facing-spine blocks heavier than t. In the
weight-threshold domain the interaction is a pointwise product, as a
convolution becomes a product under the Fourier transform. Seen from one
side, the other side is a concave penalty on its facing spine: a block of
weight w pays Lambda(w) = sum over the other spine of min(w, w_y).

**Frontiers.** A side can then export, instead of one tree, its frontier: the
trees it takes under every outside pressure, computed once and reused by every
enclosing problem. The factorization saves work only if frontiers are small.
Measured directly: for a block B of keys in the middle of the range, restrict
the canonical optimal tree of every enclosing interval (a', b') to B and count
distinct shapes. "Right" fixes a' = a (pressure from the right only), "left"
fixes b' = b, "both" is every enclosing interval. n = 2048, about 10^6
contexts per block (`results/2026-10-25-m4-frontier-2048.csv`):

| family | B = 64: right, left, both | B = 256 | B = 512 |
|---|---|---|---|
| zipf | 4, 5, 18 | 3, 3, 12 | 8, 4, 31 |
| log-uniform | 2, 2, 7 | 4, 7, 34 | 8, 9, 86 |
| random | 12, 11, 151 | 22, 25, 655 | 24, 32, 1069 |
| keys only | 7, 8, 92 | 21, 22, 488 | 30, 24, 901 |
| gaps only | 23, 23, 804 | 95, 94, 13 496 | 192, 187, 46 663 |
| uniform | 64, 32, 2 800 | 256, 128, 47 680 | 512, 256, 144 959 |
| geometric | 64, 32, 2 800 | 256, 128, 47 680 | 512, 256, 104 806 |

- One-sided frontiers are at most |B| (uniform and geometric reach it
  exactly), about |B|/2.7 for gaps only, roughly sqrt|B| for random and
  keys-only weights (12, 22, 24 at 64, 256, 512), and nearly constant for
  Zipf and log-uniform (at most 8 or 9).
- Two-sided frontiers are close to the product of the one-sided ones (random
  at 512: 1069 against 24 x 32 = 768; uniform at 256: 47 680 against
  32 768): pressure from the left and from the right act nearly
  independently, a tensor structure like a butterfly's.

**What it could buy.** A divide-and-conquer that builds each block's frontier
from its children's would cost, per level, (n/s) blocks times the work to
combine frontiers of size F(s) per side. With F(s) ~ sqrt(s) and a combine
cubic in F, a level costs n sqrt(s) and the whole recursion n^1.5 for random
weights, and near n polylog n for Zipf and log-uniform; uniform, geometric
and gaps-only weights have F(s) ~ s and gain nothing (they are where the Monge
layers already win). This is a projection, not a result: it needs (1) a way
to enumerate a block's frontier intrinsically, from the pressure
parametrization (concave Lambda on the facing spine) rather than from the
enclosing intervals, which the measurement used; and (2) a combine whose cost
is bounded by the frontier sizes.

## The pressure model is exact (`pressure_model.cpp`)

What a block B = (a, b) does inside any enclosing problem is fixed by the
outside only through the facing spines. Let X be the left part's right spine
and Y the right part's left spine, block weights from the top. B's induced
tree minimizes

    cost_B(T) + mergeL(T, X) + mergeR(T, Y) + h(k_l, k_r)

- mergeR is the best interleaving of T's right spine with Y in which the
  lower node of each pair pays its block weight. Placing a B node with k
  outside nodes above it costs w * k plus the weight of the outside nodes
  still to come.
- mergeL is the same on the left.
- k_l and k_r count the outside nodes of each side above B's root, the node
  the two merges share.
- h is a coupling computed from X and Y alone:
  - the best interleaving of their top k_l and k_r nodes;
  - plus k_r times X's weight below the root;
  - plus k_l times Y's weight below the root.

Solving it is a lattice over B's spines and the outside sequences: O(|B|^2 K)
plus O(|B| K^2) at the root, given Knuth's table on B.

Two corrections were needed on the way, each pinned by a check that the
identity makes impossible to fail (a cheaper block tree merged with the real
outside would beat the optimum):

1. The per-node penalty sum over Y of min(w, y) is not the interaction. It
   undercharges trees whose spine order conflicts with heavier-higher. The
   interaction is the order-aware merge.
2. With pressure from both sides, independent merges miss the coupling h.

With both in place: **0 mismatches** in 28 000 sampled enclosing intervals at
n = 512 (blocks of 8-64 keys, every family, a quarter of them one-sided),
and in 5 600 at n = 128 under ASan and UBSan
(`results/2026-10-25-m4-pressure-512.csv`). So a block's whole behaviour in
every context is a function of its own weights and two outside sequences.

**What composing frontiers would cost.** Building a block's frontier from its
children's means pairing a child-left tree with a child-right tree and
keeping the pairs that win under some pressure. Using the measured two-sided
frontiers at n = 2048, the pairs over the levels s = 128..1024 (n/s blocks,
each pairing two children's frontiers) come to:

| family | pairs | if two-sided = right x left exactly | Knuth's ~ n^2 |
|---|---|---|---|
| zipf | 17 482 | 15 044 | 4 194 304 |
| log-uniform | 26 032 | 16 960 | 4 194 304 |
| keys only | 3.27 M | 2.24 M | 4 194 304 |
| random | 4.62 M | 2.78 M | 4 194 304 |
| gaps only | 5.2 G | 2.9 G | 4 194 304 |
| uniform | 52 G | 39 G | 4 194 304 |

- **Zipf and log-uniform:** naive pairing is 160-240x less than Knuth's
  candidate count.
- **Random and keys-only:** it breaks even. Their two-sided frontiers grow
  like 2|B|, so pairing costs about |B|^2 per block. A win there needs a
  composition that pairs the one-sided factors (about sqrt|B| each) through
  the k-indexed coupling, which is the only place left and right meet.
- **Uniform, geometric and gaps-only:** naive pairing is far worse, as
  expected.

**The missing piece** is an intrinsic frontier: generating a block's frontier
without solving the enclosing intervals. By the model, the pressure from one
side enters only through the outside sequence's length and suffix sums (any
positive decreasing sequence), so the universal frontier is the set of trees
optimal for some pair of such sequences under h. Its size is unknown. Random
pressure draws (the harness's `intrinsic_*` columns) cover only part of the
measured frontier (13 of 22 shapes for random weights at 16 keys) and say
little; the gaps-only draw is degenerate because the sampler scales by key
weights, which are zero there.

## The universal frontier (`universal_frontier.cpp`)

The universal frontier is what a block would have to carry if it knew nothing
of its surroundings: every tree that is the model's optimum for some pair of
outside sequences. Any positive sequence is a spine of some outside weights,
so this ranges over all pairs of positive sequences of any length.

How it was measured:
- **Sampled universal frontier.** Up to 10^6 draws per block from a mixture
  of i.i.d. log-uniform blocks, the same sorted decreasing, and geometric
  runs, lengths 0..max(8, 2|B|), half of them right-only. The counts are
  lower bounds; the checkpoints show saturation.
- **Measured frontier.** Taken exactly, over every enclosing interval of an
  n = 256 instance, for the same centre block.

M4, Apple clang 21 -O2, `results/2026-10-25-m4-universal-256.csv`. Entries
are two-sided / right-only shape counts:

| family | 8 keys: universal, measured | 12 keys | 16 keys |
|---|---|---|---|
| zipf | 10/2, 4/1 | 22/4, 3/1 | 22/5, 4/2 |
| log-uniform | 10/4, 1/1 | 13/8, 1/1 | 5/2, 1/1 |
| random | 26/4, 15/3 | 58/8, 18/4 | 105/9, 34/6 |
| keys only | 19/4, 4/2 | 14/3, 12/3 | 120/10, 16/4 |
| gaps only | 8/3, 8/3 | 26/5, 26/5 | 110/10, 70/9 |
| uniform | 32/8, 32/8 | 79/11, 79/11 | 146/16, 148/16 |
| geometric | 36/8, 31/8 | 105/12, 62/10 | 210/20, 86/10 |

- **The model passes a consistency check.** Up to 16 keys the sampled
  universal frontier is saturated (the last checkpoint adds at most 8
  shapes) and contains every measured shape, except 1 of 86 for geometric
  and 2 of 148 for uniform (ties). At 32 keys 30 000 draws are not enough:
  the counts are still growing and cover only 55-100% of the measured shapes.
- **Universal is a small factor above measured, not a blowup.** It is 1x for
  uniform and gaps-only weights, about 2-3x for random and geometric, and up
  to 5-7x for Zipf and keys-only. That is against Catalan numbers of 1430 to
  35 million.
- **One-sided universal frontiers are at most |B|:** 9 for random weights at
  16 keys, 5 for Zipf, 16 (= |B|) for uniform.
- **Two-sided universal frontiers grow fast for random weights:** 26, 58, 105
  at 8, 12, 16 keys, about 4x per doubling. That is close to the product of
  the one-sided counts (81 at 16 keys).

**What it means for a construction.** A bottom-up construction that knows
nothing of the surroundings must carry the universal frontier.
- One-sided, that is cheap: at most |B|, often much less.
- Two-sided, it is not: pairing two-sided frontiers would cost more than
  Knuth on the block for random weights (105^2 pairs at 32 keys against
  32^2).

So the frontier recursion can win only if it carries the one-sided factors
and composes them through the k-indexed coupling, never forming the
two-sided product. The coupling is the only place the two sides meet.

## One-sided composition (`frontier_compose.cpp`)

The construction carrying only one-sided frontiers:
- each dyadic block keeps LF of its prefixes and RF of its suffixes;
- plain optima of crossing intervals come from the seam identity over
  RF x LF pairs;
- the frontiers come from the root recurrences;
- pruning uses an exact dominance: lower cost and an in-order embedding of
  the spine with no heavier blocks.

**It is exact:** all 151 instances (n <= 32, Zipf, under ASan and UBSan)
match Knuth. **It explodes:** dominance keeps almost everything. At n = 32
the largest frontier held 32 768 trees and the plain optima took
1 073 807 328 pair merges against Knuth's 1 251 candidates. The run was
stopped there (`results/2026-10-25-m4-compose-partial.csv`).

The design has a second, structural cost. The root recurrence needs the
plain optimum of every interval inside a block, so even with perfect pruning
every interval is computed once, each by a frontier product instead of
Knuth's O(1). Carrying frontiers cannot beat Knuth unless the root
candidates themselves are pruned, which needs the root-bound structure Knuth
has and this recursion lacks.

## Knuth layouts (`knuth_layouts.cpp`)

Constant factors, not asymptotics, for the library's exact construction.
Interleaved in one process at n = 16 384 (Apple clang 21 -O2, median of 3,
`results/2026-10-25-m4-knuth-layouts-16384.csv`), against the library as it
was (diagonals, row-major triangle, 128-bit costs plus a root per cell):

- **Diagonal schedule, one array of roots, 64-bit costs:** 1.55-2.1x faster
  on every family, 2.5x less memory. 64-bit alone is worth 1.15-1.3x over
  the same layout at 128 bits.
- **Row schedule over column-major costs:** 2.2-2.3x faster than the old
  layout on Zipf and log-normal, 1.9x on random. But it is 1.7-2.4x slower
  than the diagonal on uniform and Laplacian weights, where roots sit
  mid-interval, far from the cell being written.

Root recovery from the cost table costs under 1 ms in both. Both are now in
the library (`knuth`, `knuth_scattered`).

## Open threads

- An exact enumeration of the universal frontier (the sampler loses ground
  past 16 keys), for example by parametric search over the outside
  sequences' suffix sums.
- A composition through the k-indexed coupling that pairs one-sided factors,
  which is what random weights need.
- A certificate of root optimality sized by the changed region. Candidates:
  tighter bounds (the coarse piece tree is the only structure used so far),
  or a top-down order that keeps Knuth's root bounds available, as his
  bottom-up order does.
- Whether the Zipf changed region is polylogarithmic; larger n on the pod.
- A hybrid that sends flat stretches to the Monge layers and skewed stretches
  to joins.
