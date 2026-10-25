// Seam locality: can an optimal binary search tree be built by zipping
// optimal trees of adjacent sections along their facing spines?
//
// Weights, intervals and Knuth's tables are in obst_common.hpp.
//
// A zip joins L = (i, m-1), the key m and R = (m, j). L's right spine
// s1 < s2 < ... and R's left spine r1 > r2 > ... face each other. A zipped
// tree takes a prefix s1..su and a prefix r1..rv, interleaves them on a seam
// path from the root, and ends the path at m. Everything off the path hangs
// unchanged: the left subtrees of the s nodes, the right subtrees of the r
// nodes, and the remainders of L below su and of R below rv as m's children.
// The seam node reached after a L nodes and b R nodes roots the interval
// (s_a, r_b - 1), so the best interleaving is a lattice-path minimum.
//
// The conjecture: for some optimal L and R, the best zip is optimal for
// (i, j). If it holds at every merge, building bottom-up over any section
// hierarchy is exact, in time set by spine lengths instead of n^2.
//
// Knuth's tables are the oracle. Ties are covered only by its two extremal
// root choices (leftmost and rightmost minimum, each consistent with Knuth's
// root bounds); a merge that fails under both is reported as failing.

#include "obst_common.hpp"

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <random>
#include <string>
#include <vector>

namespace obst {
namespace {

// The facing spines of the two sides and what hangs off them. Index 0 is the
// state before any spine node is taken.
struct Spines final {
    std::vector<std::size_t> left_low;    // left_low[a]: s_a (s_0 = i)
    std::vector<Cost> left_hang;          // left_hang[a]: costs hung by s_1..s_a
    std::vector<Cost> left_rest;          // left_rest[a]: cost of L below s_a
    std::vector<std::size_t> right_high;  // right_high[b]: r_b - 1 (r_0 - 1 = j)
    std::vector<Cost> right_hang;
    std::vector<Cost> right_rest;
};

struct Zip final {
    Cost cost = 0;
    std::size_t left_taken = 0;
    std::size_t right_taken = 0;
};

// The best zip over the lattice of spine prefixes. `path` is scratch, and on
// return path[a * (t + 1) + b] holds the best seam cost reaching (a, b).
[[nodiscard]] Zip best_zip(const Weights& weights, const Spines& spines, std::vector<Cost>& path) {
    const std::size_t t = spines.left_low.size() - 1;
    const std::size_t u = spines.right_high.size() - 1;
    path.assign((t + 1) * (u + 1), 0);
    Zip best;
    bool found = false;
    std::size_t a = 0;
    for (a = 0; a <= t; a += 1) {
        std::size_t b = 0;
        for (b = 0; b <= u; b += 1) {
            Cost reach = 0;
            if (a > 0 && b > 0) {
                reach = std::min(path[(a - 1) * (u + 1) + b], path[a * (u + 1) + b - 1]);
            } else if (a > 0) {
                reach = path[(a - 1) * (u + 1) + b];
            } else if (b > 0) {
                reach = path[a * (u + 1) + b - 1];
            }
            const Cost here = reach + weights.interval(spines.left_low[a], spines.right_high[b]);
            path[a * (u + 1) + b] = here;
            const Cost total = here + spines.left_hang[a] + spines.left_rest[a] + spines.right_hang[b] + spines.right_rest[b];
            if (!found || total < best.cost) {
                best = Zip{.cost = total, .left_taken = a, .right_taken = b};
                found = true;
            }
        }
    }
    return best;
}

// The spines of Knuth's optimal trees for (i, m-1) and (m, j).
[[nodiscard]] Spines knuth_spines(const KnuthTables& tables, std::size_t i, std::size_t m, std::size_t j) {
    Spines spines;
    std::size_t low = i;
    spines.left_low.push_back(low);
    spines.left_hang.push_back(0);
    spines.left_rest.push_back(tables.cost(i, m - 1));
    while (low < m - 1) {
        const std::size_t next = tables.root(low, m - 1);
        spines.left_hang.push_back(spines.left_hang.back() + tables.cost(low, next - 1));
        spines.left_low.push_back(next);
        spines.left_rest.push_back(tables.cost(next, m - 1));
        low = next;
    }
    std::size_t high = j;
    spines.right_high.push_back(high);
    spines.right_hang.push_back(0);
    spines.right_rest.push_back(tables.cost(m, j));
    while (high > m) {
        const std::size_t next = tables.root(m, high);
        spines.right_hang.push_back(spines.right_hang.back() + tables.cost(next, high));
        spines.right_high.push_back(next - 1);
        spines.right_rest.push_back(tables.cost(m, next - 1));
        high = next - 1;
    }
    return spines;
}

// Ancestors of m in Knuth's optimal tree for (i, j) that are L keys but not
// on L's optimal right spine, plus those that are R keys off R's left spine.
[[nodiscard]] std::size_t off_spine_ancestors(const KnuthTables& tables, std::size_t i, std::size_t m, std::size_t j) {
    std::vector<char> on_left(j + 2, 0);
    std::vector<char> on_right(j + 2, 0);
    std::size_t low = i;
    while (low < m - 1) {
        low = tables.root(low, m - 1);
        on_left[low] = 1;
    }
    std::size_t high = j;
    while (high > m) {
        const std::size_t next = tables.root(m, high);
        on_right[next] = 1;
        high = next - 1;
    }
    std::size_t off = 0;
    std::size_t lo = i;
    std::size_t hi = j;
    while (true) {
        const std::size_t root = tables.root(lo, hi);
        if (root == m) {
            break;
        }
        if (root < m) {
            off += on_left[root] == 0 ? 1 : 0;
            lo = root;
        } else {
            off += on_right[root] == 0 ? 1 : 0;
            hi = root - 1;
        }
    }
    return off;
}

// A built tree over keys 1..n, linked by key.
class BuiltTree final {
public:
    explicit BuiltTree(std::size_t n) : left(n + 2, 0), right(n + 2, 0), subtree_cost(n + 2, 0) {}

    std::vector<std::size_t> left;
    std::vector<std::size_t> right;
    std::vector<Cost> subtree_cost;

    [[nodiscard]] Cost cost_of(std::size_t node) const noexcept {
        return node == 0 ? 0 : subtree_cost[node];
    }
};

// Zips the built trees of (i, m-1) and (m, j) around m; returns the root.
std::size_t zip_built(const Weights& weights, BuiltTree& tree, std::size_t left_root, std::size_t i, std::size_t m,
                      std::size_t right_root, std::size_t j, std::vector<Cost>& path) {
    Spines spines;
    std::vector<std::size_t> left_nodes(1, 0);
    std::vector<std::size_t> right_nodes(1, 0);
    spines.left_low.push_back(i);
    spines.left_hang.push_back(0);
    spines.left_rest.push_back(tree.cost_of(left_root));
    std::size_t node = left_root;
    while (node != 0) {
        left_nodes.push_back(node);
        spines.left_hang.push_back(spines.left_hang.back() + tree.cost_of(tree.left[node]));
        spines.left_low.push_back(node);
        spines.left_rest.push_back(tree.cost_of(tree.right[node]));
        node = tree.right[node];
    }
    spines.right_high.push_back(j);
    spines.right_hang.push_back(0);
    spines.right_rest.push_back(tree.cost_of(right_root));
    node = right_root;
    while (node != 0) {
        right_nodes.push_back(node);
        spines.right_hang.push_back(spines.right_hang.back() + tree.cost_of(tree.right[node]));
        spines.right_high.push_back(node - 1);
        spines.right_rest.push_back(tree.cost_of(tree.left[node]));
        node = tree.left[node];
    }
    const Zip zip = best_zip(weights, spines, path);
    const std::size_t columns = spines.right_high.size();
    const std::size_t a_end = zip.left_taken;
    const std::size_t b_end = zip.right_taken;
    const std::size_t m_left = a_end == 0 ? left_root : tree.right[left_nodes[a_end]];
    const std::size_t m_right = b_end == 0 ? right_root : tree.left[right_nodes[b_end]];
    tree.left[m] = m_left;
    tree.right[m] = m_right;
    tree.subtree_cost[m] = weights.interval(spines.left_low[a_end], spines.right_high[b_end]) + tree.cost_of(m_left) + tree.cost_of(m_right);
    // Walk the best lattice path back from (a_end, b_end), linking each seam
    // node above the one below it.
    std::size_t below = m;
    std::size_t a = a_end;
    std::size_t b = b_end;
    while (a > 0 || b > 0) {
        bool from_left = false;
        if (a > 0 && b > 0) {
            from_left = path[(a - 1) * columns + b] <= path[a * columns + b - 1];
        } else {
            from_left = a > 0;
        }
        std::size_t seam = 0;
        if (from_left) {
            a -= 1;
            seam = left_nodes[a + 1];
            tree.right[seam] = below;
            tree.subtree_cost[seam] = weights.interval(spines.left_low[a], spines.right_high[b]) + tree.cost_of(tree.left[seam]) + tree.cost_of(below);
        } else {
            b -= 1;
            seam = right_nodes[b + 1];
            tree.left[seam] = below;
            tree.subtree_cost[seam] = weights.interval(spines.left_low[a], spines.right_high[b]) + tree.cost_of(below) + tree.cost_of(tree.right[seam]);
        }
        below = seam;
    }
    return below;
}

// Atom locality, the weaker conjecture: keep every subtree hanging off the
// facing spines intact as an atom, and re-solve only the spine keys and m as
// a small OBST whose gaps are the atoms. bounds[0] = i, bounds[1..T] are the
// chain keys in order, and atom a is the interval (bounds[a], bounds[a+1]-1)
// with bounds[T+1] = j+1. Every tree over a chain interval holds each of its
// atoms once, so subtracting their costs leaves Knuth's form (zero on single
// atoms) and his root bounds apply.
class ChainSolver final {
public:
    // Solves the chain; returns its best cost including the atoms' costs.
    Cost solve(const Weights& weights, const std::vector<std::size_t>& bounds, const std::vector<Cost>& atom_costs) {
        keys = bounds.size() - 2;
        side = keys + 1;
        costs.assign(side * side, 0);
        roots.assign(side * side, 0);
        std::size_t length = 0;
        for (length = 1; length <= keys; length += 1) {
            std::size_t a = 0;
            for (a = 0; a + length <= keys; a += 1) {
                const std::size_t b = a + length;
                std::size_t low = a + 1;
                std::size_t high = b;
                if (length > 1) {
                    low = roots[a * side + b - 1];
                    high = roots[(a + 1) * side + b];
                }
                std::size_t best_root = low;
                Cost best = costs[a * side + low - 1] + costs[low * side + b];
                std::size_t candidate = 0;
                for (candidate = low + 1; candidate <= high; candidate += 1) {
                    const Cost value = costs[a * side + candidate - 1] + costs[candidate * side + b];
                    if (value < best) {
                        best = value;
                        best_root = candidate;
                    }
                }
                costs[a * side + b] = best + weights.interval(bounds[a], bounds[b + 1] - 1);
                roots[a * side + b] = best_root;
            }
        }
        Cost total = costs[keys];
        std::size_t atom = 0;
        for (atom = 0; atom < atom_costs.size(); atom += 1) {
            total += atom_costs[atom];
        }
        return total;
    }

    // Links the solved chain over chain interval (a, b) into the tree, with
    // atom_roots as its leaves; returns the subtree's root.
    std::size_t link(const Weights& weights, BuiltTree& tree, const std::vector<std::size_t>& bounds,
                     const std::vector<std::size_t>& atom_roots, std::size_t a, std::size_t b) const {
        if (a == b) {
            return atom_roots[a];
        }
        const std::size_t root = roots[a * side + b];
        const std::size_t key = bounds[root];
        const std::size_t left = link(weights, tree, bounds, atom_roots, a, root - 1);
        const std::size_t right = link(weights, tree, bounds, atom_roots, root, b);
        tree.left[key] = left;
        tree.right[key] = right;
        tree.subtree_cost[key] = weights.interval(bounds[a], bounds[b + 1] - 1) + tree.cost_of(left) + tree.cost_of(right);
        return key;
    }

private:
    std::size_t keys = 0;
    std::size_t side = 0;
    std::vector<Cost> costs;
    std::vector<std::size_t> roots;
};

// Appends, in key order, the keys of the top `depth` levels of Knuth's
// optimal tree for (low, high); what lies below stays atoms.
void open_atom(const KnuthTables& tables, std::size_t low, std::size_t high, std::size_t depth, std::vector<std::size_t>& bounds) {
    if (depth == 0 || low >= high) {
        return;
    }
    const std::size_t root = tables.root(low, high);
    open_atom(tables, low, root - 1, depth - 1, bounds);
    bounds.push_back(root);
    open_atom(tables, root, high, depth - 1, bounds);
}

// The chain of Knuth's optimal trees for (i, m-1) and (m, j), with each atom
// opened `depth` levels.
[[nodiscard]] Cost knuth_chain(const Weights& weights, const KnuthTables& tables, std::size_t i, std::size_t m, std::size_t j,
                               std::size_t depth, ChainSolver& solver, std::size_t* chain_keys) {
    std::vector<std::size_t> spine(1, i);
    std::size_t low = i;
    while (low < m - 1) {
        low = tables.root(low, m - 1);
        spine.push_back(low);
    }
    spine.push_back(m);
    std::vector<std::size_t> right;
    std::size_t high = j;
    while (high > m) {
        const std::size_t next = tables.root(m, high);
        right.push_back(next);
        high = next - 1;
    }
    std::size_t index = right.size();
    while (index > 0) {
        index -= 1;
        spine.push_back(right[index]);
    }
    spine.push_back(j + 1);
    std::vector<std::size_t> bounds(1, i);
    for (index = 0; index + 1 < spine.size(); index += 1) {
        open_atom(tables, spine[index], spine[index + 1] - 1, depth, bounds);
        if (index + 2 < spine.size()) {
            bounds.push_back(spine[index + 1]);
        }
    }
    bounds.push_back(j + 1);
    std::vector<Cost> atom_costs;
    for (index = 0; index + 1 < bounds.size(); index += 1) {
        atom_costs.push_back(tables.cost(bounds[index], bounds[index + 1] - 1));
    }
    *chain_keys = bounds.size() - 2;
    return solver.solve(weights, bounds, atom_costs);
}

// Joins the built trees of (i, m-1) and (m, j) around m by the chain; returns
// the root.
std::size_t chain_built(const Weights& weights, BuiltTree& tree, std::size_t left_root, std::size_t i, std::size_t m,
                        std::size_t right_root, std::size_t j, ChainSolver& solver) {
    std::vector<std::size_t> bounds(1, i);
    std::vector<std::size_t> atom_roots;
    std::size_t node = left_root;
    std::size_t last = 0;
    while (node != 0) {
        atom_roots.push_back(tree.left[node]);
        bounds.push_back(node);
        last = node;
        node = tree.right[node];
    }
    atom_roots.push_back(last == 0 ? 0 : tree.right[last]);
    bounds.push_back(m);
    std::vector<std::size_t> right;
    node = right_root;
    while (node != 0) {
        right.push_back(node);
        node = tree.left[node];
    }
    atom_roots.push_back(right.empty() ? 0 : tree.left[right.back()]);
    std::size_t index = right.size();
    while (index > 0) {
        index -= 1;
        bounds.push_back(right[index]);
        atom_roots.push_back(tree.right[right[index]]);
    }
    bounds.push_back(j + 1);
    std::vector<Cost> atom_costs;
    for (index = 0; index < atom_roots.size(); index += 1) {
        atom_costs.push_back(tree.cost_of(atom_roots[index]));
    }
    solver.solve(weights, bounds, atom_costs);
    return solver.link(weights, tree, bounds, atom_roots, 0, bounds.size() - 2);
}

enum class Split { middle, weight_median };
enum class Join { zip, chain };

// Builds (i, j) bottom-up by zips; returns the root (0 when empty).
std::size_t build_by_zips(const Weights& weights, BuiltTree& tree, std::size_t i, std::size_t j, Split split, Join join, std::vector<Cost>& path,
                          ChainSolver& solver) {
    if (j <= i) {
        return 0;
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
    const std::size_t left_root = build_by_zips(weights, tree, i, m - 1, split, join, path, solver);
    const std::size_t right_root = build_by_zips(weights, tree, m, j, split, join, path, solver);
    if (join == Join::chain) {
        return chain_built(weights, tree, left_root, i, m, right_root, j, solver);
    }
    return zip_built(weights, tree, left_root, i, m, right_root, j, path);
}

// Recomputes a built tree's cost from its links, checking that it is a
// search tree over exactly the keys of (i, j); -1 when it is not.
[[nodiscard]] Cost checked_cost(const Weights& weights, const BuiltTree& tree, std::size_t root, std::size_t i, std::size_t j) {
    if (root == 0) {
        return i == j ? 0 : -1;
    }
    if (root <= i || root > j) {
        return -1;
    }
    const Cost left = checked_cost(weights, tree, tree.left[root], i, root - 1);
    const Cost right = checked_cost(weights, tree, tree.right[root], root, j);
    if (left < 0 || right < 0) {
        return -1;
    }
    return weights.interval(i, j) + left + right;
}

// Records, for every key of Knuth's optimal tree for (low, high), the low end
// of its subtree's interval (the high end follows from the tree's shape).
void record_lows(const KnuthTables& tables, std::size_t low, std::size_t high, std::vector<std::size_t>& lows,
                 std::vector<std::size_t>& highs) {
    if (low >= high) {
        return;
    }
    const std::size_t root = tables.root(low, high);
    lows[root] = low;
    highs[root] = high;
    record_lows(tables, low, root - 1, lows, highs);
    record_lows(tables, root, high, lows, highs);
}

// Keys of (i, j) other than m whose subtree in the joined optimum differs
// from their subtree in their side's optimum: the region a join must rebuild.
[[nodiscard]] std::size_t changed_nodes(const KnuthTables& tables, std::size_t i, std::size_t m, std::size_t j) {
    std::vector<std::size_t> side_lows(j + 1, 0);
    std::vector<std::size_t> side_highs(j + 1, 0);
    std::vector<std::size_t> joined_lows(j + 1, 0);
    std::vector<std::size_t> joined_highs(j + 1, 0);
    record_lows(tables, i, m - 1, side_lows, side_highs);
    record_lows(tables, m, j, side_lows, side_highs);
    record_lows(tables, i, j, joined_lows, joined_highs);
    std::size_t changed = 0;
    std::size_t key = 0;
    for (key = i + 1; key <= j; key += 1) {
        if (key != m && (side_lows[key] != joined_lows[key] || side_highs[key] != joined_highs[key])) {
            changed += 1;
        }
    }
    return changed;
}

constexpr std::size_t depth_cap = 8;

struct MergeCensus final {
    std::size_t merges = 0;
    std::size_t fail_leftmost = 0;
    std::size_t fail_rightmost = 0;
    std::size_t fail_both = 0;
    double worst_excess = 0.0;  // relative, over merges failing under both
    std::size_t off_spine_total = 0;
    std::size_t off_spine_worst = 0;
    std::size_t longest_spine = 0;
    std::size_t chain_fail = 0;
    double chain_worst_excess = 0.0;
    std::size_t longest_chain = 0;
    // depth_needed[d]: merges first exact with atoms opened d levels; the
    // last entry counts merges not exact within the cap.
    std::size_t depth_needed[depth_cap + 2] = {};
    std::size_t changed_total = 0;
    std::size_t changed_worst = 0;
    std::size_t keys_total = 0;
};

void census_merge(const Weights& weights, const KnuthTables& leftmost, const KnuthTables& rightmost, std::size_t i, std::size_t m,
                  std::size_t j, std::vector<Cost>& path, ChainSolver& solver, MergeCensus& census) {
    const Spines left_spines = knuth_spines(leftmost, i, m, j);
    const Spines right_spines = knuth_spines(rightmost, i, m, j);
    const Cost optimum = leftmost.cost(i, j);
    const Cost by_left = best_zip(weights, left_spines, path).cost;
    const Cost by_right = best_zip(weights, right_spines, path).cost;
    census.merges += 1;
    census.fail_leftmost += by_left != optimum ? 1 : 0;
    census.fail_rightmost += by_right != optimum ? 1 : 0;
    const std::size_t spine = std::max(left_spines.left_low.size(), left_spines.right_high.size()) - 1;
    census.longest_spine = std::max(census.longest_spine, spine);
    if (by_left != optimum && by_right != optimum) {
        census.fail_both += 1;
        const double excess = static_cast<double>(std::min(by_left, by_right) - optimum) / static_cast<double>(optimum);
        census.worst_excess = std::max(census.worst_excess, excess);
        const std::size_t off = off_spine_ancestors(leftmost, i, m, j);
        census.off_spine_total += off;
        census.off_spine_worst = std::max(census.off_spine_worst, off);
    }
    std::size_t chain_keys = 0;
    const Cost by_chain = knuth_chain(weights, leftmost, i, m, j, 0, solver, &chain_keys);
    census.longest_chain = std::max(census.longest_chain, chain_keys);
    if (by_chain != optimum) {
        census.chain_fail += 1;
        const double excess = static_cast<double>(by_chain - optimum) / static_cast<double>(optimum);
        census.chain_worst_excess = std::max(census.chain_worst_excess, excess);
    }
    std::size_t depth = 0;
    Cost opened = by_chain;
    while (opened != optimum && depth <= depth_cap) {
        depth += 1;
        if (depth <= depth_cap) {
            opened = knuth_chain(weights, leftmost, i, m, j, depth, solver, &chain_keys);
        }
    }
    census.depth_needed[depth] += 1;
    const std::size_t changed = changed_nodes(leftmost, i, m, j);
    census.changed_total += changed;
    census.changed_worst = std::max(census.changed_worst, changed);
    census.keys_total += j - i;
}

void print_census(const char* family, std::size_t n, const char* scope, const MergeCensus& census) {
    std::printf("merge,%s,%zu,%s,%zu,%zu,%zu,%zu,%.3e,%zu,%zu,%zu,%zu,%.3e,%zu\n", family, n, scope, census.merges, census.fail_leftmost,
                census.fail_rightmost, census.fail_both, census.worst_excess, census.off_spine_total, census.off_spine_worst,
                census.longest_spine, census.chain_fail, census.chain_worst_excess, census.longest_chain);
    std::printf("depth,%s,%zu,%s", family, n, scope);
    std::size_t depth = 0;
    for (depth = 0; depth <= depth_cap + 1; depth += 1) {
        std::printf(",%zu", census.depth_needed[depth]);
    }
    std::printf(",%.2f,%zu,%.2f\n", static_cast<double>(census.changed_total) / static_cast<double>(census.merges), census.changed_worst,
                static_cast<double>(census.keys_total) / static_cast<double>(census.merges));
}

void run_instance(Family family, std::size_t n, std::size_t sampled_merges, std::mt19937_64& random) {
    const Weights weights = make_weights(family, n, random);
    const std::chrono::steady_clock::time_point knuth_start = std::chrono::steady_clock::now();
    const KnuthTables leftmost(weights, TieRule::leftmost);
    const std::chrono::steady_clock::time_point knuth_end = std::chrono::steady_clock::now();
    const KnuthTables rightmost(weights, TieRule::rightmost);
    std::vector<Cost> path;
    ChainSolver solver;
    MergeCensus census;
    if (sampled_merges == 0) {
        std::size_t i = 0;
        for (i = 0; i < n; i += 1) {
            std::size_t j = 0;
            for (j = i + 1; j <= n; j += 1) {
                std::size_t m = 0;
                for (m = i + 1; m <= j; m += 1) {
                    census_merge(weights, leftmost, rightmost, i, m, j, path, solver, census);
                }
            }
        }
        print_census(family_name(family), n, "all", census);
    } else {
        std::uniform_int_distribution<std::size_t> gap(0, n);
        std::size_t sample = 0;
        for (sample = 0; sample < sampled_merges; sample += 1) {
            std::size_t i = gap(random);
            std::size_t j = gap(random);
            if (i == j) {
                continue;
            }
            if (i > j) {
                std::swap(i, j);
            }
            std::uniform_int_distribution<std::size_t> key(i + 1, j);
            census_merge(weights, leftmost, rightmost, i, key(random), j, path, solver, census);
        }
        print_census(family_name(family), n, "sampled", census);
    }
    const Split splits[2] = {Split::middle, Split::weight_median};
    const Join joins[2] = {Join::zip, Join::chain};
    std::size_t index = 0;
    for (index = 0; index < 4; index += 1) {
        BuiltTree tree(n);
        const std::chrono::steady_clock::time_point zip_start = std::chrono::steady_clock::now();
        const std::size_t root = build_by_zips(weights, tree, 0, n, splits[index % 2], joins[index / 2], path, solver);
        const std::chrono::steady_clock::time_point zip_end = std::chrono::steady_clock::now();
        const Cost built = tree.cost_of(root);
        const Cost checked = checked_cost(weights, tree, root, 0, n);
        const Cost optimum = leftmost.cost(0, n);
        const double knuth_ms = std::chrono::duration<double, std::milli>(knuth_end - knuth_start).count();
        const double zip_ms = std::chrono::duration<double, std::milli>(zip_end - zip_start).count();
        if (checked != built || built < optimum) {
            std::fprintf(stderr, "invalid built tree: %s n=%zu\n", family_name(family), n);
            std::exit(70);
        }
        std::printf("build,%s,%zu,%s_%s,%lld,%lld,%.9f,%.3f,%.3f\n", family_name(family), n, index % 2 == 0 ? "middle" : "weight_median",
                    index / 2 == 0 ? "zip" : "chain", static_cast<long long>(built), static_cast<long long>(optimum),
                    static_cast<double>(built) / static_cast<double>(optimum), knuth_ms, zip_ms);
    }
    std::fflush(stdout);
}

} // namespace
} // namespace obst

// Usage: seam_locality <max exhaustive n> <largest sampled n> <samples> <seed>
int main(int argc, char** argv) {
    if (argc != 5) {
        std::fprintf(stderr, "usage: seam_locality <max exhaustive n> <largest sampled n> <samples> <seed>\n");
        return 64;
    }
    const std::size_t exhaustive = static_cast<std::size_t>(std::strtoull(argv[1], nullptr, 10));
    const std::size_t largest = static_cast<std::size_t>(std::strtoull(argv[2], nullptr, 10));
    const std::size_t samples = static_cast<std::size_t>(std::strtoull(argv[3], nullptr, 10));
    std::mt19937_64 random(std::strtoull(argv[4], nullptr, 10));
    std::printf("merge,family,n,scope,merges,fail_leftmost,fail_rightmost,fail_both,worst_excess,off_spine_total,off_spine_worst,"
                "longest_spine,chain_fail,chain_worst_excess,longest_chain\n");
    std::printf("depth,family,n,scope,d0,d1,d2,d3,d4,d5,d6,d7,d8,beyond,changed_mean,changed_worst,keys_mean\n");
    std::printf("build,family,n,split,built_cost,optimal_cost,ratio,knuth_ms,zip_ms\n");
    const obst::Family families[7] = {obst::Family::uniform, obst::Family::random,      obst::Family::keys_only, obst::Family::gaps_only,
                                      obst::Family::zipf,    obst::Family::log_uniform, obst::Family::geometric};
    std::size_t family = 0;
    for (family = 0; family < 7; family += 1) {
        std::size_t n = 0;
        for (n = 2; n <= exhaustive; n += n < 16 ? 1 : n / 2) {
            std::size_t repetition = 0;
            for (repetition = 0; repetition < (n <= 16 ? 20 : 3); repetition += 1) {
                obst::run_instance(families[family], n, 0, random);
            }
        }
        for (n = exhaustive * 2; n <= largest; n *= 2) {
            obst::run_instance(families[family], n, samples, random);
        }
    }
    return 0;
}
