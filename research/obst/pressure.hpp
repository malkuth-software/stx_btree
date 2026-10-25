#pragma once

// The exact pressure model (see pressure_model.cpp): what a block of keys
// does inside any enclosing problem, as a function of the two facing outside
// spines. Shared by the pressure and frontier harnesses.

#include "obst_common.hpp"

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <vector>

namespace obst {

[[nodiscard]] inline Cost key_weight(const Weights& weights, std::size_t key) noexcept {
    return weights.key_prefix[key] - weights.key_prefix[key - 1];
}

inline void depths_in(const KnuthTables& tables, std::size_t a, std::size_t b, std::size_t depth, std::vector<std::size_t>& out, std::size_t base) {
    if (a >= b) {
        return;
    }
    const std::size_t root = tables.root(a, b);
    out[root - base - 1] = depth;
    depths_in(tables, a, root - 1, depth + 1, out, base);
    depths_in(tables, root, b, depth + 1, out, base);
}

// Block weights of the left spine of the tree induced on keys low+1..high by
// `depths` (indexed by key - base - 1): the keys shallower than every key to
// their left, each with what lies between it and the next one up.
[[nodiscard]] inline std::vector<Cost> left_spine_blocks(const Weights& weights, const std::vector<std::size_t>& depths, std::size_t base,
                                                  std::size_t low, std::size_t high) {
    std::vector<std::size_t> spine;
    std::size_t shallowest = static_cast<std::size_t>(-1);
    std::size_t key = 0;
    for (key = low + 1; key <= high; key += 1) {
        if (depths[key - base - 1] < shallowest) {
            shallowest = depths[key - base - 1];
            spine.push_back(key);
        }
    }
    std::vector<Cost> blocks;
    std::size_t index = 0;
    for (index = 0; index < spine.size(); index += 1) {
        const std::size_t above = index + 1 < spine.size() ? spine[index + 1] : high + 1;
        blocks.push_back(key_weight(weights, spine[index]) + weights.interval(spine[index], above - 1));
    }
    return blocks;
}

// Block weights of the right spine of the tree induced on keys low+1..high.
[[nodiscard]] inline std::vector<Cost> right_spine_blocks(const Weights& weights, const std::vector<std::size_t>& depths, std::size_t base,
                                                   std::size_t low, std::size_t high) {
    std::vector<std::size_t> spine;
    std::size_t shallowest = static_cast<std::size_t>(-1);
    std::size_t key = high;
    while (key > low) {
        if (depths[key - base - 1] < shallowest) {
            shallowest = depths[key - base - 1];
            spine.push_back(key);
        }
        key -= 1;
    }
    std::vector<Cost> blocks;
    std::size_t index = 0;
    for (index = 0; index < spine.size(); index += 1) {
        const std::size_t above = index + 1 < spine.size() ? spine[index + 1] : low;
        blocks.push_back(key_weight(weights, spine[index]) + weights.interval(above, spine[index] - 1));
    }
    return blocks;
}

// The coupling between the two outside spines, from the outside alone. With
// k_l nodes of the left part's right spine X and k_r of the right part's left
// spine Y above the block's root, the top k_l and k_r interleave among
// themselves (best merge, lower pays its block), every X node below the root
// is below the k_r Y nodes above it, and every Y node below is below the k_l
// X nodes above. h[k_l * (|Y| + 1) + k_r] is that cost.
[[nodiscard]] inline std::vector<Cost> coupling(const std::vector<Cost>& x, const std::vector<Cost>& y) {
    const std::size_t xs = x.size();
    const std::size_t ys = y.size();
    std::vector<Cost> x_suffix(xs + 1, 0);
    std::vector<Cost> y_suffix(ys + 1, 0);
    std::size_t i = xs;
    while (i > 0) {
        i -= 1;
        x_suffix[i] = x_suffix[i + 1] + x[i];
    }
    std::size_t k = ys;
    while (k > 0) {
        k -= 1;
        y_suffix[k] = y_suffix[k + 1] + y[k];
    }
    std::vector<Cost> top((xs + 1) * (ys + 1), 0);
    for (i = 0; i <= xs; i += 1) {
        for (k = 0; k <= ys; k += 1) {
            if (i == 0 && k == 0) {
                continue;
            }
            Cost best = 0;
            bool found = false;
            if (i > 0) {
                best = top[(i - 1) * (ys + 1) + k] + x[i - 1] * static_cast<Cost>(k);
                found = true;
            }
            if (k > 0) {
                const Cost value = top[i * (ys + 1) + k - 1] + y[k - 1] * static_cast<Cost>(i);
                if (!found || value < best) {
                    best = value;
                }
            }
            top[i * (ys + 1) + k] = best;
        }
    }
    std::vector<Cost> table((xs + 1) * (ys + 1), 0);
    for (i = 0; i <= xs; i += 1) {
        for (k = 0; k <= ys; k += 1) {
            table[i * (ys + 1) + k] = top[i * (ys + 1) + k] + static_cast<Cost>(k) * x_suffix[i] + static_cast<Cost>(i) * y_suffix[k];
        }
    }
    return table;
}

// The cross cost of two facing spines (block weights from the top) under
// their best interleaving with the first own node placed after exactly
// `first` outside nodes (the root's position on the seam): per pair, the lower
// node pays its block weight, so placing an own node with k outside nodes
// above costs w * k plus the weights of the outside nodes still to come.
[[nodiscard]] inline Cost merge_from(const std::vector<Cost>& own, const std::vector<Cost>& outside, std::size_t first) {
    const std::size_t others = outside.size();
    std::vector<Cost> suffix(others + 1, 0);
    std::size_t k = others;
    while (k > 0) {
        k -= 1;
        suffix[k] = suffix[k + 1] + outside[k];
    }
    const Cost unreachable = static_cast<Cost>(1) << 62;
    std::vector<Cost> best(others + 1, unreachable);
    best[first] = own[0] * static_cast<Cost>(first) + suffix[first];
    std::size_t i = 0;
    for (i = 1; i < own.size(); i += 1) {
        std::vector<Cost> next(others + 1, unreachable);
        Cost running = unreachable;
        for (k = 0; k <= others; k += 1) {
            running = std::min(running, best[k]);
            if (running != unreachable) {
                next[k] = running + own[i] * static_cast<Cost>(k) + suffix[k];
            }
        }
        best = next;
    }
    Cost total = unreachable;
    for (k = 0; k <= others; k += 1) {
        total = std::min(total, best[k]);
    }
    return total;
}

// The penalized optimum on block (a, b) when the right spine meets the
// outside sequence `right_pressure` and the left spine `left_pressure`, each
// at its best interleaving, coupled through how many outside nodes of each
// side sit above the block's root.
class PressureSolver final {
public:
    PressureSolver(const Weights& weights_in, const KnuthTables& tables_in, std::size_t a_in, std::size_t b_in)
        : weights(weights_in), tables(tables_in), a(a_in), b(b_in) {}

    // Solves; returns the minimum and fills `depths` (key - a - 1) with the
    // optimum's shape.
    Cost solve(const std::vector<Cost>& left_pressure, const std::vector<Cost>& right_pressure, std::vector<std::size_t>& depths) {
        const std::size_t count = b - a;
        const std::size_t right_others = right_pressure.size();
        const std::size_t left_others = left_pressure.size();
        std::vector<Cost> right_suffix(right_others + 1, 0);
        std::vector<Cost> left_suffix(left_others + 1, 0);
        std::size_t k = right_others;
        while (k > 0) {
            k -= 1;
            right_suffix[k] = right_suffix[k + 1] + right_pressure[k];
        }
        k = left_others;
        while (k > 0) {
            k -= 1;
            left_suffix[k] = left_suffix[k + 1] + left_pressure[k];
        }
        const std::size_t right_side = right_others + 1;
        const std::size_t left_side = left_others + 1;
        // gR(u, k): tree on (u, b), its right spine still to merge with the
        // outside nodes k.. ; index (u - a) * right_side + k.
        right_cost.assign((count + 1) * right_side, 0);
        right_next.assign((count + 1) * right_side, 0);
        std::size_t u = b;
        while (u > a) {
            u -= 1;
            k = right_side;
            while (k > 0) {
                k -= 1;
                Cost best = 0;
                std::size_t best_v = 0;
                std::size_t v = 0;
                for (v = u + 1; v <= b; v += 1) {
                    const Cost block = weights.interval(u, v - 1) + key_weight(weights, v);
                    const Cost value = tables.cost(u, v - 1) + block * static_cast<Cost>(k) + right_suffix[k] + right_cost[(v - a) * right_side + k];
                    if (best_v == 0 || value < best) {
                        best = value;
                        best_v = v;
                    }
                }
                Cost total = weights.interval(u, b) + best;
                std::size_t choice = best_v;
                if (k + 1 < right_side && right_cost[(u - a) * right_side + k + 1] < total) {
                    total = right_cost[(u - a) * right_side + k + 1];
                    choice = 0;  // an outside node first
                }
                right_cost[(u - a) * right_side + k] = total;
                right_next[(u - a) * right_side + k] = choice;
            }
        }
        // gL(v, k): tree on (a, v), its left spine still to merge with the
        // outside nodes k.. on the left; index (v - a) * left_side + k.
        left_cost.assign((count + 1) * left_side, 0);
        left_next.assign((count + 1) * left_side, 0);
        std::size_t v = 0;
        for (v = a + 1; v <= b; v += 1) {
            k = left_side;
            while (k > 0) {
                k -= 1;
                Cost best = 0;
                std::size_t best_u = 0;
                std::size_t key = 0;
                for (key = a + 1; key <= v; key += 1) {
                    const Cost block = key_weight(weights, key) + weights.interval(key, v);
                    const Cost value = tables.cost(key, v) + block * static_cast<Cost>(k) + left_suffix[k] + left_cost[(key - 1 - a) * left_side + k];
                    if (best_u == 0 || value < best) {
                        best = value;
                        best_u = key;
                    }
                }
                Cost total = weights.interval(a, v) + best;
                std::size_t choice = best_u;
                if (k + 1 < left_side && left_cost[(v - a) * left_side + k + 1] < total) {
                    total = left_cost[(v - a) * left_side + k + 1];
                    choice = 0;
                }
                left_cost[(v - a) * left_side + k] = total;
                left_next[(v - a) * left_side + k] = choice;
            }
        }
        const std::vector<Cost> couple = coupling(left_pressure, right_pressure);
        Cost best = 0;
        std::size_t best_root = 0;
        std::size_t best_right_k = 0;
        std::size_t best_left_k = 0;
        std::vector<Cost> right_part(right_side, 0);
        std::size_t root = 0;
        for (root = a + 1; root <= b; root += 1) {
            const Cost right_block = weights.interval(a, root - 1) + key_weight(weights, root);
            const Cost left_block = key_weight(weights, root) + weights.interval(root, b);
            for (k = 0; k < right_side; k += 1) {
                right_part[k] = right_block * static_cast<Cost>(k) + right_suffix[k] + right_cost[(root - a) * right_side + k];
            }
            std::size_t left_k = 0;
            for (left_k = 0; left_k < left_side; left_k += 1) {
                const Cost left_part = left_block * static_cast<Cost>(left_k) + left_suffix[left_k] + left_cost[(root - 1 - a) * left_side + left_k];
                for (k = 0; k < right_side; k += 1) {
                    const Cost value = left_part + right_part[k] + couple[left_k * right_side + k];
                    if (best_root == 0 || value < best) {
                        best = value;
                        best_root = root;
                        best_right_k = k;
                        best_left_k = left_k;
                    }
                }
            }
        }
        depths.assign(count, 0);
        depths[best_root - a - 1] = 0;
        std::size_t upper = best_root - 1;
        std::size_t depth = 1;
        k = best_left_k;
        while (upper > a) {
            const std::size_t node = left_next[(upper - a) * left_side + k];
            if (node == 0) {
                k += 1;
                continue;
            }
            depths[node - a - 1] = depth;
            plain_depths(node, upper, depth + 1, depths);
            upper = node - 1;
            depth += 1;
        }
        std::size_t lower = best_root;
        depth = 1;
        k = best_right_k;
        while (lower < b) {
            const std::size_t node = right_next[(lower - a) * right_side + k];
            if (node == 0) {
                k += 1;
                continue;
            }
            depths[node - a - 1] = depth;
            plain_depths(lower, node - 1, depth + 1, depths);
            lower = node;
            depth += 1;
        }
        return weights.interval(a, b) + best;
    }

    // The penalized cost of the tree with these depths.
    [[nodiscard]] Cost penalized_cost(const std::vector<std::size_t>& depths, const std::vector<Cost>& left_pressure,
                                      const std::vector<Cost>& right_pressure) const {
        const std::size_t count = b - a;
        Cost total = 0;
        std::size_t index = 0;
        for (index = 0; index < count; index += 1) {
            total += key_weight(weights, a + index + 1) * static_cast<Cost>(depths[index] + 1);
        }
        std::size_t gap = 0;
        for (gap = 0; gap <= count; gap += 1) {
            std::size_t depth = 0;
            if (gap > 0) {
                depth = std::max(depth, depths[gap - 1] + 1);
            }
            if (gap < count) {
                depth = std::max(depth, depths[gap] + 1);
            }
            total += (weights.gap_prefix[a + gap + 1] - weights.gap_prefix[a + gap]) * static_cast<Cost>(depth);
        }
        // Spine blocks from the top: the helpers list them from the bottom.
        std::vector<Cost> left_blocks = left_spine_blocks(weights, depths, a, a, b);
        std::vector<Cost> right_blocks = right_spine_blocks(weights, depths, a, a, b);
        std::reverse(left_blocks.begin(), left_blocks.end());
        std::reverse(right_blocks.begin(), right_blocks.end());
        const std::vector<Cost> couple = coupling(left_pressure, right_pressure);
        const std::size_t right_side = right_pressure.size() + 1;
        Cost best = 0;
        bool found = false;
        std::size_t left_k = 0;
        for (left_k = 0; left_k <= left_pressure.size(); left_k += 1) {
            const Cost left_part = merge_from(left_blocks, left_pressure, left_k);
            std::size_t right_k = 0;
            for (right_k = 0; right_k < right_side; right_k += 1) {
                const Cost value = left_part + merge_from(right_blocks, right_pressure, right_k) + couple[left_k * right_side + right_k];
                if (!found || value < best) {
                    best = value;
                    found = true;
                }
            }
        }
        return total + best;
    }

private:
    void plain_depths(std::size_t low, std::size_t high, std::size_t depth, std::vector<std::size_t>& depths) const {
        if (low >= high) {
            return;
        }
        const std::size_t root = tables.root(low, high);
        depths[root - a - 1] = depth;
        plain_depths(low, root - 1, depth + 1, depths);
        plain_depths(root, high, depth + 1, depths);
    }

    const Weights& weights;
    const KnuthTables& tables;
    std::size_t a;
    std::size_t b;
    std::vector<Cost> right_cost;
    std::vector<std::size_t> right_next;
    std::vector<Cost> left_cost;
    std::vector<std::size_t> left_next;
};

struct ByGlobalDepth final {
    const std::vector<std::size_t>* global;

    [[nodiscard]] bool operator()(std::size_t first, std::size_t second) const noexcept {
        return (*global)[first] < (*global)[second];
    }
};

[[nodiscard]] inline std::uint64_t shape_hash(const std::vector<std::size_t>& depths) {
    const std::size_t count = depths.size();
    std::vector<std::size_t> stack;
    std::vector<std::size_t> parent(count, 0);
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

// Depths in the Cartesian tree (minimum on top) of `global`: the tree a
// contiguous block induces from depths in an enclosing tree.
[[nodiscard]] inline std::vector<std::size_t> induced_depths(const std::vector<std::size_t>& global) {
    const std::size_t count = global.size();
    std::vector<std::size_t> parent(count, count);
    std::vector<std::size_t> stack;
    std::size_t index = 0;
    for (index = 0; index < count; index += 1) {
        std::size_t last_popped = count;
        while (!stack.empty() && global[stack.back()] > global[index]) {
            last_popped = stack.back();
            stack.pop_back();
        }
        if (last_popped != count) {
            parent[last_popped] = index;
        }
        if (!stack.empty()) {
            parent[index] = stack.back();
        }
        stack.push_back(index);
    }
    // Parents are shallower in `global`, so visiting by global depth sets
    // each parent's depth first.
    std::vector<std::size_t> order(count, 0);
    for (index = 0; index < count; index += 1) {
        order[index] = index;
    }
    std::sort(order.begin(), order.end(), ByGlobalDepth{&global});
    std::vector<std::size_t> depths(count, 0);
    for (index = 0; index < count; index += 1) {
        const std::size_t node = order[index];
        depths[node] = parent[node] == count ? 0 : depths[parent[node]] + 1;
    }
    return depths;
}

} // namespace obst
