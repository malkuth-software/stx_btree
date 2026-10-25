# Optimal search trees and the static optimal map

Two pieces, not from bbtree, built beside the maps:

1. **Exact optimal binary search trees** for given search weights
   (`search_weights.hpp`, `optimal_tree.hpp`, `detail/monge_product.hpp`):
   Knuth's O(n²) construction, and the manuscript's core-sparse Monge
   construction, both returning exact 128-bit costs and the tree.
2. **`OptimalMap`**, a static ordered map laid out for a known access
   distribution (`optimal_map.hpp`, `detail/tree_packing.hpp`): a
   weight-optimal (or weight-balanced) binary tree, packed into multiway nodes
   that bbtree's node search reads.

Sources: the manuscript "Core-Sparse Monge Construction for Full Optimal
Binary Search Trees" (OpenAI Codex Sydney; problem selection and
sponsorship: Joshuah Rainstar), falseywinchnet/papers_please `obst/`, commit
eef656f, and its MIT-licensed prototype `obst/code/compact_obst.cpp`; the
Gawrychowski–Gorbachev–Kociumaka core-sparse Monge product (ESA 2025); Gil
and Itai, "How to pack trees" (1999). See [NOTICE](../NOTICE).

## Cost model

n keys with success weights p₀…pₙ₋₁, n + 1 gaps with failure weights q₀…qₙ
(gap j lies between keys j − 1 and j). A key at depth d costs p(d + 1), a
gap below d keys costs q·d: weighted three-way comparisons. All weights are
`std::uint64_t`; costs are `ExactCost` (signed 128-bit, a GCC/Clang
extension).

## Constructions

| `TreeConstruction` | Exact | Time | Memory |
| --- | --- | --- | --- |
| `knuth` | yes | O(n²) | (n+1)(n+2)/2 cells of 20 B (670 MB at n = 8192, 6 GB at 24 576) |
| `monge_layers` | yes | proved O(n^{3/2} log^{3/2}(n+1)) at W = O(n) (manuscript) | witnesses: 26–73 M integers at n = 8192 |
| `monge_additive` | yes | candidate O(n log³(n+1)) at W = O(n) (under review) | as `monge_layers` |
| `weight_balanced` | no | O(n log n) | O(n) |

`monge_layers` is the manuscript's terminal-penalty iteration: H layers
A_h(i, j) = W(i, j) + min over roots r of A_{h−1}(i, r) + A_{h−1}(r+1, j),
H = min(n, f(W) + L) from the mixed Fibonacci mass lemma, each layer one
core-sparse min-plus product of the finitely completed previous layer, with a
fixed-point early stop and witness reconstruction. The port keeps the
prototype's algorithm and witness structure and stores cores in
compressed rows; on one instance (n = 4096, keys 1–32, gaps 0–3) it runs in
3.2 s against the prototype's 13.8 s, with identical layer counts and cores.
The manuscript's centering step (normalized height for large total mass) is
not implemented.

Checks (`tests/optimal_tree_test.cpp`): for every n ≤ 8 and eight weight
families (small random with zeros, keys only, gaps only, up to 2⁴⁰, uniform,
Zipf-like, the manuscript's odd ramp and ruler families), every binary search
tree is enumerated and costed; the cubic recurrence, Knuth and the layers
must all equal that minimum. Then 96 instances 9 ≤ n < 149 against the cubic
recurrence, 8 instances 600 ≤ n < 1200 against Knuth, and edge cases (empty,
all-zero, near-2⁶⁴ weights). Each returned tree is checked to be a search
tree whose own cost is the reported cost.

### The additive base (Codex Sydney's revision)

`monge_additive` (`LayerBase::additive`) replaces the penalty base
A₀(i, j) = M(j − i) with A₀(i, j) = L·S(i, j) + (j − i), where
S(i, j) = Σ_{r=i}^{j−1}(p_r + q_r + q_{r+1}) and L = ⌈log₂(n + 1)⌉. It is
additive in the interval's ends, so its interior core is empty, and strictly
above C(i, j) on every nonempty interval; the recurrence is unchanged. The
note's argument: every layer satisfies C ≤ A_h ≤ 3L·W(i, j) + (j − i), so with
U = 3LW + n the completion P = 2U + 1 suffices and every layer's density mass
telescopes to at most U; with W = O(n) and H = O(log n) layers that suggests
O(n log³ n) time through the core-sparse product. I checked the steps (the
base bound, monotonicity, exactness at H and at a fixed point, the
reconstruction argument, the telescoping) and found no flaw; the proof is
Sydney's and still under review, so the bound is a candidate, not a claim.
The implementation changes only the base row, the h = 1 band
(min(A₀(i, i + 1), A₀(i + 1, i + 2)) − q_{i+1}) and P; the tests run it, and
the penalty base, against enumeration, the cubic recurrence and Knuth.

### Two-corner root screening (measured: no effect here)

`MongeLayerOptions::screen_roots` drops, in every product, inner roots that
cannot be the smallest minimizer of any entry: for k < l, Monge makes
f_k − f_l nondecreasing (f_k(i, j) = A(i, k) + B(k, j)), so a root beaten by a
later one at the top-left corner, or matched by an earlier one at the
bottom-right corner, never wins (Codex Sydney). It is correct (tested, all
configurations), but in this construction it removed no roots at all: every
product spans the diagonal, where the completion P(i − j) makes the
top-left corner rise and the bottom-right fall with the root, so every root
is a record at both corners. It costs 1–8% and is off by default.

### Measured construction time (Apple M4, LLVM 23, median of 3)

`results/2026-10-25-m4-monge-fast/` (current), with the earlier run in
`results/2026-10-25-m4-monge-revision/` as "before". Weights: uniform (all
p, q = 1), zipf (p = 10⁶/(rank + 1) + 1 for a random rank, q = 1), random
(p in 1..1000, q in 0..999). Seconds.

| family | n | knuth | penalty base, before → now | additive base, before → now | now ÷ knuth (penalty / additive) |
| --- | ---: | ---: | ---: | ---: | ---: |
| uniform | 4096 | 0.080 | 0.651 → 0.301 | 0.652 → 0.300 | 3.76 / 3.75 |
| uniform | 8192 | 0.355 | 1.620 → 0.751 | 1.627 → 0.747 | 2.12 / 2.10 |
| uniform | 12 288 | 0.871 | 1.198 | 1.189 | 1.38 / 1.37 |
| uniform | 16 384 | 1.836 | 3.188 → 1.786 | 3.120 → 1.776 | **0.97 / 0.97** |
| uniform | 24 576 | 5.550 | 5.002 → 2.723 | 4.934 → 2.669 | **0.49 / 0.48** |
| zipf | 8192 | 0.393 | 3.341 → 2.021 | 3.031 → 1.874 | 5.14 / 4.77 |
| zipf | 16 384 | 1.446 | 8.163 → 4.943 | 7.417 → 4.544 | 3.42 / 3.14 |
| zipf | 24 576 † | 4.107 | 8.146 | 7.465 | 1.98 / 1.82 |
| random | 8192 | 0.384 | 5.566 → 3.521 | 6.385 → 4.024 | 9.17 / 10.48 |
| random | 16 384 | 1.600 | 14.798 → 9.082 | 17.037 → 10.463 | 5.68 / 6.54 |
| random | 24 576 † | 4.716 | 16.136 | 18.423 | 3.42 / 3.91 |

† one repetition.

**The layers beat Knuth from n = 16 384 for uniform weights** (additive
1.776 s, range 1.772–1.791, against Knuth's 1.836 s, 1.804–1.857) and run in
half Knuth's time at 24 576 (2.67 s against 5.55 s). For zipf and random
weights Knuth is still faster at every size the Mini's 16 GB allows (its table
is 10.7 GB at 32 768), but the ratio falls with n: zipf 5.1 → 3.1 → 1.8 and
random 9.2 → 5.7 → 3.4 from 8192 to 24 576. That is one host and one crossing
family; the trend is not a proof of a crossing for the others.

What made the layers about twice as fast (2.1× uniform, 1.6× zipf and
random, identical results): densities stay row-major through every
producer, so building a matrix skips both counting sorts and, when nothing
repeats, takes the input vector as its core without copying (the staircase
merge emits each row's left part, staircase run and right part in order; the
layer step puts each row's diagonal band before the product's densities); a
column-major index is built only for the two matrices a merge walks, not for
every matrix; contiguous selections (the split's halves, the layer's two
operands) read one run of the core and the needed border spans without
building index vectors or interval maps; and the per-row and per-column
masses, interval maps and column flags reuse one scratch workspace per
construction (`detail::ProductScratch`).

On the bases: identical cores and times for uniform weights; the additive base
cuts zipf cores by about 23% and time by 8–9%; for the random family
(W ≈ 1000n, where the 3LW bound says nothing) its cores are 9–10% larger and it
is 13–15% slower. Every run reached a fixed point before H.

## Packing and layout

`TreePacker::pack` cuts the binary tree into connected pieces of at most K
keys (K = 48 for two-byte windows) minimizing weighted node visits for that
tree (a dynamic program over (key, keys sharing its node); time Σ min(K,
size(left)+1)·min(K, size(right)+1)). A piece of k keys has k + 1 exits, so
each is a multiway node. Tests compare its cost with a walk of every search
and, for n ≤ 12 and K ≤ 4, with brute force over every edge cut (1 206
packings).

Packing a fixed tree fragments: a balanced tree fills 48-key nodes about
half, and a Zipf-shaped tree yields many small nodes. `ColdSubtreeLayout`
therefore re-lays a subtree as full count-balanced nodes (a B-tree bulk load)
when that costs at most `count_layout_slack_percent` (default 2) more
weighted visits than the packing there. Uniform weights become a full
B-tree (4M keys: 83 335 nodes, height 4, instead of 157 629 and 5); skewed
weights keep the packing, because under Zipf nearly every subtree has a
dominant key and the count layout loses more than 10% there. The price is
memory: 4–5× the nodes of the uniform layout at s ≥ 0.8.

## The map

Nodes are 128 bytes (one M-series line): 96 bytes of windows (48 × 2 B for
integers, 24 × 4 B for strings), an exit mask, entry and child offsets.
Windows are taken after the common prefix of the node's fences, which every
key and query reaching it shares. Search counts windows below and equal over
all slots in 16-byte lane groups, compares a single candidate inline and
sends several to an outlined tie search; the child is `first_child +
popcount(exits below e)`. `find_many` runs 16 lanes, each prefetching its next
node or candidate entry. Keys and values live in one array in node order.
Tests (`tests/optimal_map_test.cpp`) cover u64 (full range and crowded),
i64, and strings with long shared prefixes, embedded zeros and prefix keys,
for all constructions and slacks 0, 2, 50, under ASan/UBSan.

### Measured lookups (Apple M4, LLVM 23, median of 3, 10 M queries)

`results/2026-10-25-m4-optimal/lookup.csv`. Random u64 keys; query rank r has
weight round(10¹²/(r + 1)^s), ranks a random permutation of the keys, and the
skewed map is built (weight_balanced tree, slack 2) for exactly those
weights. ns per lookup:

| keys | s | sorted array | bbtree unsync | static, uniform | static, uniform, batched | static, skewed | static, skewed, batched | skewed visits | skewed nodes |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1M | 0.0 | 42.6 | 32.0 | 29.8 | 39.9 | 29.3 | 40.1 | 3.93 | 22 721 |
| 1M | 0.8 | 40.6 | 29.4 | 29.6 | 40.0 | 36.2 | 35.3 | 3.28 | 84 209 |
| 1M | 1.0 | 36.8 | 27.8 | 29.7 | 38.3 | 31.3 | 30.7 | 2.54 | 87 427 |
| 1M | 1.2 | 32.3 | 24.1 | 30.8 | 35.0 | 24.4 | 27.3 | 1.73 | 123 346 |
| 8M | 0.0 | 188.6 | 84.8 | 76.4 | 54.1 | 76.0 | 54.3 | 4.33 | 266 806 |
| 8M | 0.8 | 165.1 | 80.2 | 70.2 | 50.9 | 58.8 | 45.7 | 3.76 | 1 371 804 |
| 8M | 1.0 | 124.8 | 63.2 | 59.7 | 46.7 | 42.3 | 36.6 | 2.83 | 1 170 320 |
| 8M | 1.2 | 68.9 | 42.3 | 47.9 | 41.5 | 26.4 | 28.6 | 1.79 | 995 731 |

Reading them:

- **Past the caches the skewed layout pays.** At 8M keys and s = 1.0–1.2 it
  is 1.5–1.6× faster than bbtree and 1.4–1.8× faster than the same static
  map built for uniform weights; batched, s = 0.8 reaches 1.75× bbtree.
- **At 1M keys it does not.** The M4's caches hold most of either structure;
  bbtree ties the skewed map at s = 1.2 and beats it below.
- The uniform static map (a full B-tree with no slack) is 11% faster than
  bbtree at 8M, s = 0, and 13% slower at s = 1.2; it is a static structure
  against a dynamic one. bbtree's own batched lookup is not in this table.
- Visits fall with skew as expected (4.33 → 1.79), but time follows only
  where misses dominate; the extra nodes cost memory (1.17 M × 128 B = 150 MB
  against 34 MB at 8M, s = 1.0).
- One host, one key type, one distribution family; the Linux pod has not run
  this benchmark.

## Limits and next steps

- Construction for the map at millions of keys uses `weight_balanced`; the
  exact constructions are practical to a few times 10⁴ keys today (Knuth by
  memory, the layers by time).
- The packing is optimal for the given binary tree, not among multiway
  trees; an exact multiway construction (layers whose step splits an
  interval into up to K + 1 parts) is open.
- Below the crossover the layers still lose on constant factors; matrices
  still allocate their borders, cores and row offsets, and the dense leaves
  compute whole rows and columns of their operands.
