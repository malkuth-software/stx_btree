// Context frontiers: how many different trees does a block of keys take
// across all the problems that contain it?
//
// The seam factorization. Split a range into L and R. In any tree over it the
// ancestors of the L|R boundary form one path, the seam, which interleaves
// L's right spine with R's left spine; every other node hangs off it within
// one side. With T_L and T_R the trees the whole induces on each side (a BST
// is a treap by depth, so restriction to a contiguous range keeps ancestry),
//
//     cost(T) = cost(T_L) + cost(T_R) + cross,
//
// where cross charges each seam node, for every seam node of the other side
// above it, its block's weight (the node and what hangs off it within its
// side). Swapping two adjacent seam nodes from different sides changes cross
// by the difference of their block weights, so the best interleaving puts
// heavier blocks higher; with both spines decreasing in block weight, cross is
// the sum over pairs of min(w_x, w_y), the integral over t of N_L(t) N_R(t)
// with N(t) the number of spine blocks heavier than t: the two sides interact
// pointwise in the weight-threshold domain. This harness checks the identity
// on optimal trees.
//
// The factorization saves work only if each side can export a small frontier:
// the set of trees it takes under every outside pressure, computed once and
// reused by every enclosing problem. The frontier of a block B = (a, b) is
// measured directly: for every enclosing interval (a', b'), a' <= a and
// b' >= b, take the canonical optimal tree of (a', b'), restrict it to B's
// keys, and count the distinct shapes. A restriction's shape is the Cartesian
// tree of its keys' depths (the shallowest key of a contiguous range is
// unique), identified here by a 64-bit hash of its parent array.

#include "obst_common.hpp"

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <random>
#include <unordered_set>
#include <vector>

namespace obst {
namespace {

// Records the depth of every key of (low_key, high_key] in the canonical
// optimal tree of (a, b), visiting only subtrees that reach those keys.
void record_depths(const KnuthTables& tables, std::size_t a, std::size_t b, std::size_t depth, std::size_t low_key,
                   std::size_t high_key, std::vector<std::size_t>& depths) {
    if (a >= b || b <= low_key || a >= high_key) {
        return;
    }
    const std::size_t root = tables.root(a, b);
    if (root > low_key && root <= high_key) {
        depths[root - low_key - 1] = depth;
    }
    record_depths(tables, a, root - 1, depth + 1, low_key, high_key, depths);
    record_depths(tables, root, b, depth + 1, low_key, high_key, depths);
}

// The parent array of the Cartesian tree (minimum on top) of `depths`,
// hashed (FNV-1a over parent indices; 0 marks the root).
[[nodiscard]] std::uint64_t shape_hash(const std::vector<std::size_t>& depths, std::vector<std::size_t>& stack,
                                       std::vector<std::size_t>& parent) {
    const std::size_t count = depths.size();
    stack.clear();
    parent.assign(count, 0);
    std::size_t index = 0;
    for (index = 0; index < count; index += 1) {
        std::size_t last_popped = count;
        while (!stack.empty() && depths[stack.back()] > depths[index]) {
            last_popped = stack.back();
            stack.pop_back();
        }
        if (last_popped != count) {
            parent[last_popped] = index + 1;
        }
        if (!stack.empty()) {
            parent[index] = stack.back() + 1;
        }
        stack.push_back(index);
    }
    std::uint64_t hash = 1469598103934665603ULL;
    for (index = 0; index < count; index += 1) {
        hash ^= static_cast<std::uint64_t>(parent[index]);
        hash *= 1099511628211ULL;
    }
    return hash;
}

struct Frontier final {
    std::size_t contexts = 0;
    std::size_t shapes = 0;        // over all enclosing intervals
    std::size_t right_shapes = 0;  // enclosing intervals with a' = a
    std::size_t left_shapes = 0;   // enclosing intervals with b' = b
};

[[nodiscard]] Frontier measure_block(const KnuthTables& tables, std::size_t n, std::size_t a, std::size_t b) {
    std::unordered_set<std::uint64_t> all;
    std::unordered_set<std::uint64_t> right;
    std::unordered_set<std::uint64_t> left;
    std::vector<std::size_t> depths(b - a, 0);
    std::vector<std::size_t> stack;
    std::vector<std::size_t> parent;
    Frontier frontier;
    std::size_t outer_low = 0;
    for (outer_low = 0; outer_low <= a; outer_low += 1) {
        std::size_t outer_high = 0;
        for (outer_high = b; outer_high <= n; outer_high += 1) {
            record_depths(tables, outer_low, outer_high, 0, a, b, depths);
            const std::uint64_t hash = shape_hash(depths, stack, parent);
            all.insert(hash);
            if (outer_low == a) {
                right.insert(hash);
            }
            if (outer_high == b) {
                left.insert(hash);
            }
            frontier.contexts += 1;
        }
    }
    frontier.shapes = all.size();
    frontier.right_shapes = right.size();
    frontier.left_shapes = left.size();
    return frontier;
}

struct BlockSpine final {
    std::vector<Cost> blocks;  // spine block weights, from the top
};

// The block weights along the spine of the induced tree on (low, high) that
// faces the boundary: the right spine when `right_spine`, else the left. The
// induced tree is the Cartesian tree of depths; its spine nodes are the
// running minima from the boundary side.
[[nodiscard]] BlockSpine facing_spine(const Weights& weights, const std::vector<std::size_t>& depths, std::size_t low, bool right_spine) {
    BlockSpine spine;
    const std::size_t count = depths.size();
    // Spine keys: from the top, each next one is the shallowest key strictly
    // beyond the previous toward the boundary.
    std::vector<std::size_t> keys;
    if (right_spine) {
        std::size_t start = 0;
        while (start < count) {
            std::size_t best = start;
            std::size_t index = 0;
            for (index = start; index < count; index += 1) {
                if (depths[index] < depths[best]) {
                    best = index;
                }
            }
            keys.push_back(best);
            start = best + 1;
        }
        std::size_t previous = 0;  // position after the previous spine key, in key offsets
        std::size_t index = 0;
        for (index = 0; index < keys.size(); index += 1) {
            // Block: keys previous..keys[index] with the gaps between, i.e.
            // the interval (low + previous, low + keys[index] + 1) less the
            // gap shared with the next block.
            const Cost block = weights.interval(low + previous, low + keys[index] + 1) -
                               (weights.gap_prefix[low + keys[index] + 2] - weights.gap_prefix[low + keys[index] + 1]);
            spine.blocks.push_back(block);
            previous = keys[index] + 1;
        }
    } else {
        std::size_t end = count;
        while (end > 0) {
            std::size_t best = end - 1;
            std::size_t index = end;
            while (index > 0) {
                index -= 1;
                if (depths[index] < depths[best]) {
                    best = index;
                }
            }
            keys.push_back(best);
            end = best;
        }
        std::size_t following = count;  // key offset one past the block's last key
        std::size_t index = 0;
        for (index = 0; index < keys.size(); index += 1) {
            const Cost block = weights.interval(low + keys[index], low + following) -
                               (weights.gap_prefix[low + keys[index] + 1] - weights.gap_prefix[low + keys[index]]);
            spine.blocks.push_back(block);
            following = keys[index];
        }
    }
    return spine;
}

// Checks cost(T) = cost(T_L) + cost(T_R) + cross for the optimal tree of
// (i, j) split before key m (L = (i, m-1), keys i+1..m-1; R = (m-1, j), keys
// m..j; they share the gap m-1) and compares the cross term with the sum over
// spine pairs of min(w_x, w_y).
struct IdentityCheck final {
    Cost residual = 0;       // cost(T) - cost(T_L) - cost(T_R) - cross(actual)
    Cost cross = 0;          // the actual cross term
    Cost pairwise_min = 0;   // sum over spine pairs of min(w_x, w_y)
    bool decreasing = true;  // both spines decrease in block weight
};

void depths_in(const KnuthTables& tables, std::size_t a, std::size_t b, std::size_t depth, std::vector<std::size_t>& out, std::size_t base) {
    if (a >= b) {
        return;
    }
    const std::size_t root = tables.root(a, b);
    out[root - base - 1] = depth;
    depths_in(tables, a, root - 1, depth + 1, out, base);
    depths_in(tables, root, b, depth + 1, out, base);
}

[[nodiscard]] IdentityCheck check_identity(const Weights& weights, const KnuthTables& tables, std::size_t i, std::size_t m, std::size_t j) {
    std::vector<std::size_t> depths(j - i, 0);
    depths_in(tables, i, j, 0, depths, i);
    const std::vector<std::size_t> left_depths(depths.begin(), depths.begin() + static_cast<std::ptrdiff_t>(m - 1 - i));
    const std::vector<std::size_t> right_depths(depths.begin() + static_cast<std::ptrdiff_t>(m - 1 - i), depths.end());
    IdentityCheck check;
    // Every element's ancestors, split by side (the treap rule: key k is an
    // ancestor of x iff k is the shallowest key between them, inclusive). A
    // side's induced tree charges each of its elements for its same-side
    // ancestors (keys also for themselves); the cross term charges each
    // element for its other-side ancestors. The boundary gap m-1 is in both
    // sides: each charges it for its own ancestors, so it has no cross term.
    const Cost whole = tables.cost(i, j);
    Cost left_cost = 0;
    Cost right_cost = 0;
    Cost cross = 0;
    const std::size_t count = j - i;
    std::size_t element = 0;
    for (element = 0; element < count; element += 1) {
        const std::size_t key = i + element + 1;
        const Cost weight = weights.key_prefix[key] - weights.key_prefix[key - 1];
        const bool element_left = key < m;
        std::size_t same = 0;
        std::size_t other = 0;
        std::size_t shallowest = depths[element];
        std::size_t index = 0;
        for (index = element; index > 0; index -= 1) {
            if (depths[index - 1] < shallowest) {
                shallowest = depths[index - 1];
                if ((i + index < m) == element_left) {
                    same += 1;
                } else {
                    other += 1;
                }
            }
        }
        shallowest = depths[element];
        for (index = element + 1; index < count; index += 1) {
            if (depths[index] < shallowest) {
                shallowest = depths[index];
                if ((i + index + 1 < m) == element_left) {
                    same += 1;
                } else {
                    other += 1;
                }
            }
        }
        (element_left ? left_cost : right_cost) += weight * static_cast<Cost>(same + 1);
        cross += weight * static_cast<Cost>(other);
    }
    std::size_t gap = 0;
    for (gap = 0; gap <= count; gap += 1) {
        const Cost weight = weights.gap_prefix[i + gap + 1] - weights.gap_prefix[i + gap];
        std::size_t left_ancestors = 0;
        std::size_t right_ancestors = 0;
        std::size_t shallowest = static_cast<std::size_t>(-1);
        std::size_t index = gap;
        while (index > 0) {
            index -= 1;
            if (depths[index] < shallowest) {
                shallowest = depths[index];
                (i + index + 1 < m ? left_ancestors : right_ancestors) += 1;
            }
        }
        shallowest = static_cast<std::size_t>(-1);
        for (index = gap; index < count; index += 1) {
            if (depths[index] < shallowest) {
                shallowest = depths[index];
                (i + index + 1 < m ? left_ancestors : right_ancestors) += 1;
            }
        }
        if (i + gap == m - 1) {
            left_cost += weight * static_cast<Cost>(left_ancestors);
            right_cost += weight * static_cast<Cost>(right_ancestors);
        } else if (i + gap < m - 1) {
            left_cost += weight * static_cast<Cost>(left_ancestors);
            cross += weight * static_cast<Cost>(right_ancestors);
        } else {
            right_cost += weight * static_cast<Cost>(right_ancestors);
            cross += weight * static_cast<Cost>(left_ancestors);
        }
    }
    check.cross = cross;
    check.residual = whole - left_cost - right_cost - cross;
    const BlockSpine left_spine = facing_spine(weights, left_depths, i, true);
    const BlockSpine right_spine = facing_spine(weights, right_depths, m - 1, false);
    std::size_t x = 0;
    for (x = 0; x < left_spine.blocks.size(); x += 1) {
        if (x > 0 && left_spine.blocks[x] > left_spine.blocks[x - 1]) {
            check.decreasing = false;
        }
        std::size_t y = 0;
        for (y = 0; y < right_spine.blocks.size(); y += 1) {
            check.pairwise_min += std::min(left_spine.blocks[x], right_spine.blocks[y]);
        }
    }
    std::size_t y = 0;
    for (y = 1; y < right_spine.blocks.size(); y += 1) {
        if (right_spine.blocks[y] > right_spine.blocks[y - 1]) {
            check.decreasing = false;
        }
    }
    return check;
}

} // namespace
} // namespace obst

// Usage: context_frontier <n> <seed>
int main(int argc, char** argv) {
    if (argc != 3) {
        std::fprintf(stderr, "usage: context_frontier <n> <seed>\n");
        return 64;
    }
    const std::size_t n = static_cast<std::size_t>(std::strtoull(argv[1], nullptr, 10));
    std::mt19937_64 random(std::strtoull(argv[2], nullptr, 10));
    std::printf("identity,family,n,joins,residual_nonzero,decreasing,cross_equals_pairwise_min,cross_equals_when_decreasing\n");
    std::printf("frontier,family,n,block_low,block_keys,contexts,shapes,right_shapes,left_shapes\n");
    const obst::Family families[7] = {obst::Family::zipf,      obst::Family::log_uniform, obst::Family::geometric, obst::Family::random,
                                      obst::Family::keys_only, obst::Family::gaps_only,   obst::Family::uniform};
    std::size_t family = 0;
    for (family = 0; family < 7; family += 1) {
        const obst::Weights weights = obst::make_weights(families[family], n, random);
        const obst::KnuthTables tables(weights, obst::TieRule::leftmost);
        std::size_t joins = 0;
        std::size_t nonzero = 0;
        std::size_t decreasing = 0;
        std::size_t equal = 0;
        std::size_t equal_decreasing = 0;
        std::uniform_int_distribution<std::size_t> gap(0, n);
        std::size_t sample = 0;
        for (sample = 0; sample < 2000; sample += 1) {
            std::size_t i = gap(random);
            std::size_t j = gap(random);
            if (i > j) {
                std::swap(i, j);
            }
            if (j < i + 3) {
                continue;
            }
            std::uniform_int_distribution<std::size_t> split(i + 2, j);
            const std::size_t m = split(random);
            const obst::IdentityCheck check = obst::check_identity(weights, tables, i, m, j);
            joins += 1;
            nonzero += check.residual != 0 ? 1 : 0;
            decreasing += check.decreasing ? 1 : 0;
            equal += check.cross == check.pairwise_min ? 1 : 0;
            equal_decreasing += (check.decreasing && check.cross == check.pairwise_min) ? 1 : 0;
        }
        std::printf("identity,%s,%zu,%zu,%zu,%zu,%zu,%zu\n", obst::family_name(families[family]), n, joins, nonzero, decreasing, equal,
                    equal_decreasing);
        std::size_t keys = 0;
        for (keys = 4; keys <= n / 4; keys *= 2) {
            const std::size_t low = n / 2 - keys / 2;
            const obst::Frontier frontier = obst::measure_block(tables, n, low, low + keys);
            std::printf("frontier,%s,%zu,%zu,%zu,%zu,%zu,%zu,%zu\n", obst::family_name(families[family]), n, low, keys, frontier.contexts,
                        frontier.shapes, frontier.right_shapes, frontier.left_shapes);
            std::fflush(stdout);
        }
    }
    return 0;
}
