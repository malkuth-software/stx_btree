// An exact join: the optimal tree of L = (i, m-1), key m, R = (m, j) from the
// optimal trees of L and R, rebuilding only the region that changes.
//
// Reuse needs no proof. With canonical ties (the leftmost optimal root of
// every interval) an interval's optimal subtree depends on that interval
// alone, so wherever the joined tree reaches an interval that is a subtree of
// a side's canonical tree, that subtree is reused whole. Only the region
// above those intervals is solved.
//
// Solving is Knuth's recurrence evaluated top-down, on demand, with branch
// and bound. A candidate root r of (a, b) costs W(a, b) + c(a, r-1) + c(r, b);
// candidates are tried in order of a lower bound on that sum and abandoned
// once the bound exceeds the best exact cost found, so every abandoned
// candidate is certified worse and the chosen root is the leftmost optimum.
//
// The lower bound on c(x, y). Cut (x, y) by the side trees into blocks that
// are known subtrees (exact cost) and separator keys. Restricting an optimal
// tree of (x, y) to one block's keys keeps every ancestor relation inside it
// (a BST is a treap by depth, and the block is contiguous) and deepens
// nothing, so it costs at least the block's optimum; a separator costs at
// least its weight. Beyond that, each piece's shallowest element (unique: it
// is the treap minimum of a contiguous range) is an ancestor of every element
// of any piece whose shallowest element it is an ancestor of. So every
// element gains at least the depth of its piece in the tree the shallowest
// elements induce, a BST over the pieces, and
//
//     c(x, y) >= sum of block optima + sum of separator weights
//                + the optimal sum over pieces of W(piece) * depth(piece),
//
// the last an optimal keys-only BST over the piece weights (depth from 0),
// solved by Knuth over the few pieces. W(x, y) less the heaviest piece is its
// depth-one special case.
//
// Root ranges are narrowed by Knuth's monotonicity, root(a', b') <= root(a, b)
// when a' <= a and b' <= b, probing intervals already known.
//
// Built bottom-up over a midpoint or weight-median split, every join's sides
// are canonical optima by induction, and the result is checked against
// Knuth's tables: cost and every node's root.

#include "obst_common.hpp"

#include <algorithm>
#include <chrono>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <random>
#include <unordered_map>
#include <vector>

namespace obst {
namespace {

// A tree over keys 1..n, linked by key; node 0 is the empty tree. Each node
// records its subtree's interval and cost.
struct Forest final {
    explicit Forest(std::size_t n) : left(n + 2, 0), right(n + 2, 0), low(n + 2, 0), high(n + 2, 0), cost(n + 2, 0) {}

    std::vector<std::size_t> left;
    std::vector<std::size_t> right;
    std::vector<std::size_t> low;
    std::vector<std::size_t> high;
    std::vector<Cost> cost;

    [[nodiscard]] Cost cost_of(std::size_t node) const noexcept {
        return node == 0 ? 0 : cost[node];
    }
};

struct JoinStats final {
    std::size_t solves = 0;          // intervals solved (not reused)
    std::size_t bounded = 0;         // candidate roots given a lower bound
    std::size_t evaluated = 0;       // candidate roots evaluated exactly
    std::size_t cut_visits = 0;      // side-tree nodes visited by the bounds
    std::size_t changed = 0;         // nodes of the joined tree not reused
    std::size_t seeded = 0;          // side subtrees registered for reuse
    std::size_t coarse_items = 0;    // pieces put through the coarse bound

    void add(const JoinStats& other) noexcept {
        solves += other.solves;
        bounded += other.bounded;
        evaluated += other.evaluated;
        cut_visits += other.cut_visits;
        changed += other.changed;
        seeded += other.seeded;
        coarse_items += other.coarse_items;
    }
};

struct Pieces final {
    Cost known = 0;                 // block optima and separator weights
    std::vector<Cost> weights;      // each piece's weight, in key order
};

struct Candidate final {
    Cost bound = 0;
    std::size_t root = 0;
};

struct ByBoundThenRoot final {
    [[nodiscard]] bool operator()(const Candidate& first, const Candidate& second) const noexcept {
        return first.bound < second.bound || (first.bound == second.bound && first.root < second.root);
    }
};

class ExactJoin final {
public:
    ExactJoin(const Weights& weights_in, Forest& forest_in) : weights(weights_in), forest(forest_in) {}

    // Joins the canonical optimal trees of (i, m-1) and (m, j) around m and
    // returns the root of the canonical optimal tree of (i, j).
    std::size_t join(std::size_t left_root, std::size_t i, std::size_t m, std::size_t right_root, std::size_t j) {
        low_end = i;
        middle = m;
        high_end = j;
        left_side = left_root;
        right_side = right_root;
        known.clear();
        stats = JoinStats{};
        seed(left_root);
        seed(right_root);
        solve(i, j);
        return link(i, j);
    }

    JoinStats stats;

private:
    struct Entry final {
        Cost cost = 0;
        std::size_t root = 0;
        bool reused = false;
    };

    [[nodiscard]] std::uint64_t slot(std::size_t a, std::size_t b) const noexcept {
        return static_cast<std::uint64_t>(a) * static_cast<std::uint64_t>(weights.keys + 1) + static_cast<std::uint64_t>(b);
    }

    [[nodiscard]] Cost key_weight(std::size_t key) const noexcept {
        return weights.key_prefix[key] - weights.key_prefix[key - 1];
    }

    void seed(std::size_t node) {
        if (node == 0) {
            return;
        }
        known[slot(forest.low[node], forest.high[node])] = Entry{.cost = forest.cost[node], .root = node, .reused = true};
        stats.seeded += 1;
        seed(forest.left[node]);
        seed(forest.right[node]);
    }

    // Adds the pieces of the side subtree over (low, high) rooted at node that
    // fall inside (x, y).
    void cut(std::size_t low, std::size_t high, std::size_t node, std::size_t x, std::size_t y, Pieces& pieces) {
        stats.cut_visits += 1;
        if (high < x || low > y) {
            return;
        }
        if (x <= low && high <= y) {
            pieces.known += forest.cost_of(node);
            pieces.weights.push_back(weights.interval(low, high));
            return;
        }
        // A partial overlap spans two gaps, so the subtree is not empty.
        cut(low, node - 1, forest.left[node], x, y, pieces);
        if (x < node && node <= y) {
            pieces.known += key_weight(node);
            pieces.weights.push_back(key_weight(node));
        }
        cut(node, high, forest.right[node], x, y, pieces);
    }

    [[nodiscard]] Cost lower_bound(std::size_t a, std::size_t b) {
        if (a == b) {
            return 0;
        }
        const std::unordered_map<std::uint64_t, Entry>::const_iterator found = known.find(slot(a, b));
        if (found != known.end()) {
            return (*found).second.cost;
        }
        Pieces& pieces = scratch_pieces;
        pieces.known = 0;
        pieces.weights.clear();
        if (b < middle) {
            cut(low_end, middle - 1, left_side, a, b, pieces);
        } else if (a >= middle) {
            cut(middle, high_end, right_side, a, b, pieces);
        } else {
            cut(low_end, middle - 1, left_side, a, middle - 1, pieces);
            pieces.known += key_weight(middle);
            pieces.weights.push_back(key_weight(middle));
            cut(middle, high_end, right_side, middle, b, pieces);
        }
        return pieces.known + coarse_cost(pieces.weights);
    }

    // The optimal keys-only BST cost over `items`, depth counted from 0:
    // Knuth's recurrence with his root bounds (they hold for keys alone).
    [[nodiscard]] Cost coarse_cost(const std::vector<Cost>& items) {
        const std::size_t count = items.size();
        stats.coarse_items += count;
        if (count <= 1) {
            return 0;
        }
        const std::size_t side = count + 1;
        coarse_costs.assign(side * side, 0);
        coarse_roots.assign(side * side, 0);
        coarse_prefix.assign(side, 0);
        std::size_t index = 0;
        for (index = 0; index < count; index += 1) {
            coarse_prefix[index + 1] = coarse_prefix[index] + items[index];
        }
        // coarse_costs[s * side + t]: items s..t-1, each weighted by depth + 1.
        std::size_t length = 0;
        for (length = 1; length <= count; length += 1) {
            std::size_t first = 0;
            for (first = 0; first + length <= count; first += 1) {
                const std::size_t last = first + length;
                std::size_t low = first;
                std::size_t high = last - 1;
                if (length > 1) {
                    low = coarse_roots[first * side + last - 1];
                    high = coarse_roots[(first + 1) * side + last];
                }
                Cost best = 0;
                std::size_t best_root = low;
                std::size_t root = 0;
                for (root = low; root <= high; root += 1) {
                    const Cost value = coarse_costs[first * side + root] + coarse_costs[(root + 1) * side + last];
                    if (root == low || value < best) {
                        best = value;
                        best_root = root;
                    }
                }
                coarse_costs[first * side + last] = best + coarse_prefix[last] - coarse_prefix[first];
                coarse_roots[first * side + last] = best_root;
            }
        }
        return coarse_costs[count] - coarse_prefix[count];
    }

    // Narrows [*lowest, *highest] by the known root of (a2, b2), if any.
    void narrow(std::size_t a, std::size_t b, std::size_t a2, std::size_t b2, std::size_t* lowest, std::size_t* highest) const {
        if (a2 >= b2) {
            return;
        }
        const std::unordered_map<std::uint64_t, Entry>::const_iterator found = known.find(slot(a2, b2));
        if (found == known.end()) {
            return;
        }
        const std::size_t root = (*found).second.root;
        if (a2 <= a && b2 <= b) {
            *lowest = std::max(*lowest, root);
        }
        if (a2 >= a && b2 >= b) {
            *highest = std::min(*highest, root);
        }
    }

    Cost solve(std::size_t a, std::size_t b) {
        if (a == b) {
            return 0;
        }
        const std::unordered_map<std::uint64_t, Entry>::const_iterator found = known.find(slot(a, b));
        if (found != known.end()) {
            return (*found).second.cost;
        }
        stats.solves += 1;
        std::size_t lowest = a + 1;
        std::size_t highest = b;
        narrow(a, b, a, b - 1, &lowest, &highest);
        narrow(a, b, a + 1, b, &lowest, &highest);
        narrow(a, b, a, middle - 1, &lowest, &highest);
        narrow(a, b, middle, b, &lowest, &highest);
        narrow(a, b, low_end, b, &lowest, &highest);
        narrow(a, b, a, high_end, &lowest, &highest);
        const Cost weight = weights.interval(a, b);
        std::vector<Candidate> candidates;
        candidates.reserve(highest - lowest + 1);
        std::size_t root = 0;
        for (root = lowest; root <= highest; root += 1) {
            candidates.push_back(Candidate{.bound = weight + lower_bound(a, root - 1) + lower_bound(root, b), .root = root});
        }
        stats.bounded += candidates.size();
        std::sort(candidates.begin(), candidates.end(), ByBoundThenRoot{});
        Cost best = 0;
        std::size_t best_root = 0;
        std::size_t index = 0;
        for (index = 0; index < candidates.size(); index += 1) {
            if (best_root != 0 && candidates[index].bound > best) {
                break;
            }
            stats.evaluated += 1;
            const std::size_t candidate = candidates[index].root;
            const Cost value = weight + solve(a, candidate - 1) + solve(candidate, b);
            if (best_root == 0 || value < best || (value == best && candidate < best_root)) {
                best = value;
                best_root = candidate;
            }
        }
        known[slot(a, b)] = Entry{.cost = best, .root = best_root, .reused = false};
        return best;
    }

    std::size_t link(std::size_t a, std::size_t b) {
        if (a == b) {
            return 0;
        }
        const Entry entry = known.at(slot(a, b));
        if (entry.reused) {
            return entry.root;
        }
        const std::size_t root = entry.root;
        const std::size_t left = link(a, root - 1);
        const std::size_t right = link(root, b);
        forest.left[root] = left;
        forest.right[root] = right;
        forest.low[root] = a;
        forest.high[root] = b;
        forest.cost[root] = entry.cost;
        stats.changed += 1;
        return root;
    }

    const Weights& weights;
    Forest& forest;
    std::unordered_map<std::uint64_t, Entry> known;
    Pieces scratch_pieces;
    std::vector<Cost> coarse_costs;
    std::vector<std::size_t> coarse_roots;
    std::vector<Cost> coarse_prefix;
    std::size_t low_end = 0;
    std::size_t middle = 0;
    std::size_t high_end = 0;
    std::size_t left_side = 0;
    std::size_t right_side = 0;
};

enum class Split { middle, weight_median };

struct Build final {
    JoinStats total;
    JoinStats top;  // the last, largest join
};

std::size_t build_exact(const Weights& weights, Forest& forest, ExactJoin& joiner, std::size_t i, std::size_t j, Split split, Build& build) {
    if (j <= i) {
        return 0;
    }
    if (j == i + 1) {
        forest.left[j] = 0;
        forest.right[j] = 0;
        forest.low[j] = i;
        forest.high[j] = j;
        forest.cost[j] = weights.interval(i, j);
        return j;
    }
    std::size_t m = i + 1 + (j - i - 1) / 2;
    if (split == Split::weight_median) {
        const Cost half = weights.interval(i, j) / 2;
        std::size_t low = i + 1;
        std::size_t high = j;
        while (low < high) {
            const std::size_t mid = low + (high - low) / 2;
            if (weights.interval(i, mid - 1) < half) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        m = low;
    }
    const std::size_t left_root = build_exact(weights, forest, joiner, i, m - 1, split, build);
    const std::size_t right_root = build_exact(weights, forest, joiner, m, j, split, build);
    const std::size_t root = joiner.join(left_root, i, m, right_root, j);
    build.total.add(joiner.stats);
    build.top = joiner.stats;
    return root;
}

// Whether the built tree is Knuth's canonical tree, node by node.
[[nodiscard]] bool matches_knuth(const KnuthTables& tables, const Forest& forest, std::size_t root, std::size_t a, std::size_t b) {
    if (a == b) {
        return root == 0;
    }
    if (root != tables.root(a, b) || forest.cost[root] != tables.cost(a, b)) {
        return false;
    }
    return matches_knuth(tables, forest, forest.left[root], a, root - 1) && matches_knuth(tables, forest, forest.right[root], root, b);
}

// Runs one instance; returns the exact build's milliseconds.
double run_instance(Family family, std::size_t n, std::mt19937_64& random) {
    const Weights weights = make_weights(family, n, random);
    const std::chrono::steady_clock::time_point knuth_start = std::chrono::steady_clock::now();
    const KnuthTables tables(weights, TieRule::leftmost);
    const std::chrono::steady_clock::time_point knuth_end = std::chrono::steady_clock::now();
    const double knuth_ms = std::chrono::duration<double, std::milli>(knuth_end - knuth_start).count();
    const Split splits[2] = {Split::middle, Split::weight_median};
    double slowest = 0.0;
    std::size_t index = 0;
    for (index = 0; index < 2; index += 1) {
        Forest forest(n);
        ExactJoin joiner(weights, forest);
        Build build;
        const std::chrono::steady_clock::time_point start = std::chrono::steady_clock::now();
        const std::size_t root = build_exact(weights, forest, joiner, 0, n, splits[index], build);
        const std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
        const double exact_ms = std::chrono::duration<double, std::milli>(end - start).count();
        slowest = std::max(slowest, exact_ms);
        if (!matches_knuth(tables, forest, root, 0, n)) {
            std::fprintf(stderr, "not Knuth's canonical tree: %s n=%zu split=%zu\n", family_name(family), n, index);
            std::exit(70);
        }
        std::printf("exact,%s,%zu,%s,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%.3f,%.3f\n", family_name(family), n,
                    index == 0 ? "middle" : "weight_median", tables.candidate_evaluations(), build.total.bounded,
                    build.total.evaluated, build.total.solves, build.total.cut_visits, build.total.changed, build.top.bounded,
                    build.top.evaluated, build.top.solves, build.top.changed, knuth_ms, exact_ms);
    }
    std::fflush(stdout);
    return slowest;
}

} // namespace
} // namespace obst

// Usage: exact_join <largest n> <seconds per instance before a family stops> <seed>
int main(int argc, char** argv) {
    if (argc != 4) {
        std::fprintf(stderr, "usage: exact_join <largest n> <seconds per instance before a family stops> <seed>\n");
        return 64;
    }
    const std::size_t largest = static_cast<std::size_t>(std::strtoull(argv[1], nullptr, 10));
    const double limit_ms = 1000.0 * std::strtod(argv[2], nullptr);
    std::mt19937_64 random(std::strtoull(argv[3], nullptr, 10));
    std::printf("exact,family,n,split,knuth_candidates,bounded,evaluated,solves,cut_visits,changed,top_bounded,top_evaluated,"
                "top_solves,top_changed,knuth_ms,exact_ms\n");
    const obst::Family families[7] = {obst::Family::zipf,      obst::Family::log_uniform, obst::Family::geometric, obst::Family::random,
                                      obst::Family::keys_only, obst::Family::gaps_only,   obst::Family::uniform};
    std::size_t family = 0;
    for (family = 0; family < 7; family += 1) {
        std::size_t n = 0;
        for (n = 2; n <= largest; n += n < 16 ? 1 : n) {
            std::size_t repetition = 0;
            double slowest = 0.0;
            for (repetition = 0; repetition < (n <= 16 ? 30 : 1); repetition += 1) {
                slowest = std::max(slowest, obst::run_instance(families[family], n, random));
            }
            if (slowest > limit_ms) {
                break;
            }
        }
    }
    return 0;
}
