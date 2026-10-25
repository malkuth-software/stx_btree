#pragma once

// Optimal binary search trees for given search weights (search_weights.hpp
// states the cost). Three constructions:
//
//   knuth            Knuth's O(n^2) dynamic program with root monotonicity.
//                    Exact. Time and memory quadratic: (n + 1)(n + 2) / 2
//                    cells of 20 bytes.
//   monge_layers     The manuscript's construction (falseywinchnet/
//                    papers_please, obst/manuscript, "Core-Sparse Monge
//                    Construction for Full Optimal Binary Search Trees"):
//                    bounded-height terminal-penalty layers, each a
//                    core-sparse Monge min-plus product
//                    (detail/monge_product.hpp), with witnesses for
//                    reconstruction. Exact. The manuscript proves
//                    O(n^{3/2} log^{3/2}(n + 1)) time when the total mass is
//                    O(n) (after its centering step, which this
//                    implementation does not perform; see docs/OPTIMAL_TREES.md).
//   monge_additive   The same layers from Codex Sydney's additive base
//                    (LayerBase::additive, 2026-10-25): exact, every
//                    layer's core at most 3 L W + n, suggesting
//                    O(n log^3 n) time at W = O(n) through the core-sparse
//                    product (a candidate bound under review, not proved
//                    here). Either can screen inner roots by two output
//                    corners in each product (MongeLayerOptions, Codex
//                    Sydney); off by default, as it removed no roots here.
//   weight_balanced  Each root splits its interval's mass as evenly as the
//                    keys allow (Mehlhorn's bisection rule). O(n log n), not
//                    exact: its cost is reported, not promised optimal.
//
// The exact constructions return the same optimal cost; their trees may
// differ where several trees are optimal.

#include "stx_btree/detail/monge_product.hpp"
#include "stx_btree/search_weights.hpp"

#include <cassert>
#include <cstddef>
#include <cstdint>
#include <memory>
#include <stdexcept>
#include <vector>

namespace stx_btree {

enum class TreeConstruction : std::uint8_t { knuth, monge_layers, monge_additive, weight_balanced };

// Layer 0 of the Monge construction.
//   terminal_penalty  A_0(i, j) = M (j - i), M = (H + 1) W + 1: the
//                     manuscript as published.
//   additive          A_0(i, j) = L S(i, j) + (j - i), S the sum of
//                     p_r + q_r + q_{r+1} over the interval: Codex Sydney's
//                     revision (2026-10-25), which keeps every layer's core
//                     within 3 L W + n.
enum class LayerBase : std::uint8_t { terminal_penalty, additive };

struct MongeLayerOptions final {
    LayerBase base = LayerBase::terminal_penalty;
    // Two-corner screening in every product. Off by default: every product
    // here spans the diagonal, where the completion P (i - j) makes the
    // top-left corner rise and the bottom-right fall with the root, so every
    // root survives and screening only adds work (measured, n <= 8192).
    bool screen_roots = false;
};

// What a monge_layers or monge_additive construction did, for measurement.
struct MongeLayerReport final {
    std::size_t height_bound = 0;        // H, the number of layers allowed
    std::size_t layers = 0;              // layers computed
    bool reached_fixed_point = false;    // stopped early: a layer repeated
    std::size_t largest_core = 0;        // densities in the largest layer
    std::size_t witness_slots = 0;       // integers kept for reconstruction
};

class OptimalTreeBuilder final {
public:
    [[nodiscard]] static SearchTree build(const SearchWeights& weights, TreeConstruction construction) {
        MongeLayerReport report;
        switch (construction) {
        case TreeConstruction::knuth:
            return knuth(weights);
        case TreeConstruction::monge_layers:
            return monge_layers(weights, MongeLayerOptions{.base = LayerBase::terminal_penalty, .screen_roots = false}, report);
        case TreeConstruction::monge_additive:
            return monge_layers(weights, MongeLayerOptions{.base = LayerBase::additive, .screen_roots = false}, report);
        case TreeConstruction::weight_balanced:
            return weight_balanced(weights);
        }
        throw std::invalid_argument("unknown tree construction");
    }

    // ---- Knuth -------------------------------------------------------------

    [[nodiscard]] static SearchTree knuth(const SearchWeights& weights) {
        SearchWeightRules::validate(weights);
        const std::size_t key_count = weights.keys.size();
        const std::vector<ExactCost> prefix = mass_prefix(weights);
        const TriangleIndex cells{.key_count = key_count};
        std::vector<ExactCost> cost(cells.cell_count(), 0);
        std::vector<KeyIndex> root(cells.cell_count(), no_key);
        std::size_t length = 0;
        for (length = 1; length <= key_count; length += 1) {
            std::size_t first = 0;
            for (first = 0; first + length <= key_count; first += 1) {
                const std::size_t end = first + length;
                // Roots are monotone (Knuth; Yao for non-negative weights):
                // root(i, j - 1) <= root(i, j) <= root(i + 1, j).
                std::size_t low = first;
                std::size_t high = end - 1;
                if (length > 1) {
                    low = static_cast<std::size_t>(root[cells.at(first, end - 1)]);
                    high = static_cast<std::size_t>(root[cells.at(first + 1, end)]);
                }
                std::size_t best_root = low;
                ExactCost best = cost[cells.at(first, low)] + cost[cells.at(low + 1, end)];
                std::size_t candidate = 0;
                for (candidate = low + 1; candidate <= high; candidate += 1) {
                    const ExactCost value = cost[cells.at(first, candidate)] + cost[cells.at(candidate + 1, end)];
                    if (value < best) {
                        best = value;
                        best_root = candidate;
                    }
                }
                const ExactCost mass = interval_mass(prefix, weights, first, end);
                cost[cells.at(first, end)] = best + mass;
                root[cells.at(first, end)] = static_cast<KeyIndex>(best_root);
            }
        }
        std::vector<KeyIndex> parent(key_count, no_key);
        std::vector<PendingInterval> pending;
        pending.push_back(PendingInterval{.first = 0, .end = static_cast<KeyIndex>(key_count), .layer = 0, .parent = no_key});
        while (!pending.empty()) {
            const PendingInterval interval = pending.back();
            pending.pop_back();
            if (interval.first == interval.end) {
                continue;
            }
            const KeyIndex chosen = root[cells.at(static_cast<std::size_t>(interval.first), static_cast<std::size_t>(interval.end))];
            parent[static_cast<std::size_t>(chosen)] = interval.parent;
            pending.push_back(PendingInterval{.first = interval.first, .end = chosen, .layer = 0, .parent = chosen});
            pending.push_back(PendingInterval{.first = chosen + 1, .end = interval.end, .layer = 0, .parent = chosen});
        }
        SearchTree tree;
        tree.cost = cost[cells.at(0, key_count)];
        tree.shape = BinaryTreeRules::from_parents(parent);
        return tree;
    }

    // ---- Monge layers -----------------------------------------------------

    // The manuscript's construction as published.
    [[nodiscard]] static SearchTree monge_layers(const SearchWeights& weights, MongeLayerReport& report) {
        return monge_layers(weights, MongeLayerOptions{}, report);
    }

    // Throws std::invalid_argument when the total mass is too large for every
    // intermediate value to fit ExactCost. Terminal penalty: the prototype's
    // bound, mass at most (2^120 - 1) / (16 n^2 (H + 2) + 16). Additive: every
    // completed entry, at most (n + 1) P with P = 2 (3 L W + n) + 1, times 16.
    [[nodiscard]] static SearchTree monge_layers(
        const SearchWeights& weights, const MongeLayerOptions& options, MongeLayerReport& report) {
        using detail::CondensedMatrix;
        using detail::Density;
        using detail::MatrixIndex;
        using detail::MongeMultiplier;
        using detail::MongeProduct;
        using detail::ProductWitness;

        SearchWeightRules::validate(weights);
        report = MongeLayerReport{};
        SearchTree tree;
        const std::size_t key_count = weights.keys.size();
        if (key_count == 0) {
            return tree;
        }
        const MatrixIndex n = static_cast<MatrixIndex>(key_count);
        const ExactCost mass = SearchWeightRules::total_mass(weights);

        // Height bound (manuscript, mixed Fibonacci subtree-mass lemma): some
        // optimal tree has height at most H = min(n, f(W) + L), where f(W) is
        // the least h with F_h > W and L = ceil(log2(n + 1)); the + L is not
        // needed when every key weight is positive.
        std::size_t key_bits = 0;
        std::size_t remaining = key_count;
        while (remaining != 0) {
            key_bits += 1;
            remaining >>= 1;
        }
        const std::size_t height_slack = SearchWeightRules::all_keys_positive(weights) ? 0 : key_bits;
        const std::size_t fibonacci_height = fibonacci_limit(mass);
        const std::size_t height_unbounded = fibonacci_height + height_slack;
        const std::size_t height = height_unbounded < key_count ? height_unbounded : key_count;
        report.height_bound = height;

        const ExactCost n_value = static_cast<ExactCost>(n);
        const ExactCost height_value = static_cast<ExactCost>(height);
        const ExactCost largest = (static_cast<ExactCost>(1) << 120) - 1;
        const std::vector<ExactCost> prefix = mass_prefix(weights);
        std::vector<ExactCost> single(key_count, 0);
        std::size_t key = 0;
        for (key = 0; key < key_count; key += 1) {
            single[key] = static_cast<ExactCost>(weights.keys[key]) + static_cast<ExactCost>(weights.gaps[key]) +
                          static_cast<ExactCost>(weights.gaps[key + 1]);
        }

        // The base: A_0(0, j) for every j (its top row), A_0(i, i + 1) for
        // every key, and the below-diagonal completion P, which exceeds
        // twice every upper-triangle entry of every layer so that no
        // invalid root wins and every layer stays Monge.
        std::vector<ExactCost> base_top(key_count + 1, 0);
        std::vector<ExactCost> base_single(key_count, 0);
        ExactCost below_diagonal = 0;
        if (options.base == LayerBase::terminal_penalty) {
            const ExactCost domain_denominator = 16 * n_value * n_value * (height_value + 2) + 16;
            if (mass > largest / domain_denominator) {
                throw std::invalid_argument("search weights too large for the exact layer construction");
            }
            // Terminal penalty M exceeds any tree within the height bound.
            const ExactCost terminal = (height_value + 1) * mass + 1;
            below_diagonal = 4 * n_value * terminal + 4 * mass + 1;
            for (key = 0; key <= key_count; key += 1) {
                base_top[key] = terminal * static_cast<ExactCost>(key);
            }
            for (key = 0; key < key_count; key += 1) {
                base_single[key] = terminal;
            }
        } else {
            // U = 3 L W + n bounds every upper-triangle entry of every layer.
            const ExactCost level_factor = static_cast<ExactCost>(key_bits);
            const ExactCost entry_limit = largest / (16 * (n_value + 1));
            if (mass > entry_limit / (8 * level_factor + 8)) {
                throw std::invalid_argument("search weights too large for the exact layer construction");
            }
            const ExactCost upper = 3 * level_factor * mass + n_value;
            below_diagonal = 2 * upper + 1;
            for (key = 0; key < key_count; key += 1) {
                base_single[key] = level_factor * single[key] + 1;
                base_top[key + 1] = base_top[key] + base_single[key];
            }
        }

        // Layer 0: the base above the diagonal, P (i - j) below it. Its only
        // densities are on the diagonal, P + A_0(i, i + 1): the base is
        // additive in the interval's ends.
        std::vector<ExactCost> top_row = base_top;
        std::vector<ExactCost> left_column(key_count + 1, 0);
        std::vector<Density> densities;
        for (key = 0; key <= key_count; key += 1) {
            left_column[key] = below_diagonal * static_cast<ExactCost>(key);
        }
        for (key = 0; key < key_count; key += 1) {
            const MatrixIndex at = static_cast<MatrixIndex>(key);
            densities.push_back(Density{.row = at, .column = at, .value = below_diagonal + base_single[key]});
        }
        CondensedMatrix layer = CondensedMatrix::from_densities(std::move(top_row), std::move(left_column), std::move(densities));
        report.largest_core = static_cast<std::size_t>(layer.core_size());

        std::vector<std::unique_ptr<ProductWitness>> witnesses;
        detail::ProductScratch scratch;
        std::size_t step = 0;
        for (step = 1; step <= height; step += 1) {
            // A_h(i, j) = W(i, j) + min over i <= r < j of A_{h-1}(i, r) + A_{h-1}(r + 1, j).
            const CondensedMatrix roots_left = layer.select_range(0, n + 1, 0, n, scratch);
            const CondensedMatrix roots_right = layer.select_range(1, n + 1, 0, n + 1, scratch);
            MongeProduct product = MongeMultiplier::multiply(roots_left, roots_right, options.screen_roots, scratch);
            // Row by row, in row-major order: the diagonal band of the finite
            // completion E_h, then the product's densities right of it.
            densities.clear(); // emptied by the move into the previous layer
            densities.reserve(product.matrix.core.size() + 2 * key_count);
            const std::vector<ExactCost>& previous_single = step == 1 ? base_single : single;
            for (key = 0; key < key_count; key += 1) {
                const MatrixIndex at = static_cast<MatrixIndex>(key);
                densities.push_back(Density{.row = at, .column = at, .value = below_diagonal + single[key]});
                if (key + 1 < key_count) {
                    // min(A_{h-1}(i, i + 1), A_{h-1}(i + 1, i + 2)): the
                    // base's singletons at h = 1, the singleton masses after.
                    const ExactCost bridge = previous_single[key] < previous_single[key + 1] ? previous_single[key]
                                                                                             : previous_single[key + 1];
                    const ExactCost band = bridge - static_cast<ExactCost>(weights.gaps[key + 1]);
                    assert(band >= 0);
                    if (band != 0) {
                        densities.push_back(Density{.row = at, .column = at + 1, .value = band});
                    }
                }
                std::size_t index = 0;
                const std::size_t row_end = static_cast<std::size_t>(product.matrix.row_begin[key + 1]);
                for (index = static_cast<std::size_t>(product.matrix.row_begin[key]); index < row_end; index += 1) {
                    const Density& density = product.matrix.core[index];
                    if (density.column >= density.row + 2) {
                        densities.push_back(density);
                    }
                }
            }
            top_row.assign(key_count + 1, 0);
            left_column.assign(key_count + 1, 0);
            for (key = 1; key <= key_count; key += 1) {
                top_row[key] = product.matrix.top[key] + prefix[key] + static_cast<ExactCost>(weights.gaps[0]);
            }
            for (key = 0; key <= key_count; key += 1) {
                left_column[key] = below_diagonal * static_cast<ExactCost>(key);
            }
            CondensedMatrix next = CondensedMatrix::from_densities(std::move(top_row), std::move(left_column), std::move(densities));
            report.layers += 1;
            const std::size_t core_count = static_cast<std::size_t>(next.core_size());
            if (core_count > report.largest_core) {
                report.largest_core = core_count;
            }
            const bool repeated = same_layer(next, layer);
            report.witness_slots += (*product.witness).slot_count();
            witnesses.push_back(std::move(product.witness));
            layer = std::move(next);
            if (repeated) {
                report.reached_fixed_point = true;
                break;
            }
        }

        // Reconstruction: the root of interval (i, j) at layer h is layer
        // h's product witness for cell (i, j); its children use layer h - 1.
        std::vector<KeyIndex> parent(key_count, no_key);
        std::vector<PendingInterval> pending;
        pending.push_back(PendingInterval{.first = 0, .end = n, .layer = witnesses.size(), .parent = no_key});
        while (!pending.empty()) {
            const PendingInterval interval = pending.back();
            pending.pop_back();
            if (interval.first == interval.end) {
                continue;
            }
            assert(interval.layer > 0);
            const ProductWitness& witness = *witnesses[interval.layer - 1];
            const MatrixIndex chosen = witness.query(interval.first, interval.end);
            assert(interval.first <= chosen && chosen < interval.end);
            parent[static_cast<std::size_t>(chosen)] = interval.parent;
            pending.push_back(PendingInterval{.first = interval.first, .end = chosen, .layer = interval.layer - 1, .parent = chosen});
            pending.push_back(PendingInterval{.first = chosen + 1, .end = interval.end, .layer = interval.layer - 1, .parent = chosen});
        }
        tree.cost = layer.top[key_count];
        tree.shape = BinaryTreeRules::from_parents(parent);
        return tree;
    }

    // ---- Weight-balanced bisection ---------------------------------------

    [[nodiscard]] static SearchTree weight_balanced(const SearchWeights& weights) {
        SearchWeightRules::validate(weights);
        const std::size_t key_count = weights.keys.size();
        const std::vector<ExactCost> prefix = mass_prefix(weights);
        std::vector<KeyIndex> parent(key_count, no_key);
        std::vector<PendingInterval> pending;
        pending.push_back(PendingInterval{.first = 0, .end = static_cast<KeyIndex>(key_count), .layer = 0, .parent = no_key});
        while (!pending.empty()) {
            const PendingInterval interval = pending.back();
            pending.pop_back();
            if (interval.first == interval.end) {
                continue;
            }
            const KeyIndex chosen = balanced_root(prefix, weights, interval.first, interval.end);
            parent[static_cast<std::size_t>(chosen)] = interval.parent;
            pending.push_back(PendingInterval{.first = interval.first, .end = chosen, .layer = 0, .parent = chosen});
            pending.push_back(PendingInterval{.first = chosen + 1, .end = interval.end, .layer = 0, .parent = chosen});
        }
        SearchTree tree;
        tree.shape = BinaryTreeRules::from_parents(parent);
        tree.cost = BinaryTreeRules::cost(tree.shape, weights);
        return tree;
    }

    // The least h with F_h > mass (F_0 = 0, F_1 = 1).
    [[nodiscard]] static std::size_t fibonacci_limit(ExactCost mass) noexcept {
        ExactCost current = 0;
        ExactCost next = 1;
        std::size_t index = 0;
        while (current <= mass) {
            const ExactCost following = current + next;
            current = next;
            next = following;
            index += 1;
        }
        return index;
    }

private:
    // An interval (first, end) of keys still to place, with the layer its
    // root comes from (monge_layers) and the key it hangs below.
    struct PendingInterval final {
        KeyIndex first;
        KeyIndex end;
        std::size_t layer;
        KeyIndex parent;
    };

    // Cells (i, j), 0 <= i <= j <= n, stored row by row.
    struct TriangleIndex final {
        std::size_t key_count;

        [[nodiscard]] std::size_t cell_count() const noexcept {
            return (key_count + 1) * (key_count + 2) / 2;
        }
        [[nodiscard]] std::size_t at(std::size_t first, std::size_t end) const noexcept {
            // Rows before `first` hold (n + 1) + n + ... + (n + 2 - first)
            // cells, first (2n + 3 - first) / 2 in all.
            const std::size_t row_start = first * (2 * key_count + 3 - first) / 2;
            return row_start + (end - first);
        }
    };

    // prefix[k] = sum over t < k of (p_t + q_{t+1}), so that
    // W(i, j) = prefix[j] - prefix[i] + q_i.
    [[nodiscard]] static std::vector<ExactCost> mass_prefix(const SearchWeights& weights) {
        const std::size_t key_count = weights.keys.size();
        std::vector<ExactCost> prefix(key_count + 1, 0);
        std::size_t key = 0;
        for (key = 0; key < key_count; key += 1) {
            prefix[key + 1] = prefix[key] + static_cast<ExactCost>(weights.keys[key]) +
                              static_cast<ExactCost>(weights.gaps[key + 1]);
        }
        return prefix;
    }

    [[nodiscard]] static ExactCost interval_mass(
        const std::vector<ExactCost>& prefix, const SearchWeights& weights, std::size_t first, std::size_t end) noexcept {
        return prefix[end] - prefix[first] + static_cast<ExactCost>(weights.gaps[first]);
    }

    // The root r of (first, end) that minimizes |W(first, r) - W(r + 1, end)|,
    // the least such r on a tie. W(first, r) - W(r + 1, end) grows with r, so
    // a binary search finds where it turns non-negative.
    [[nodiscard]] static KeyIndex balanced_root(
        const std::vector<ExactCost>& prefix, const SearchWeights& weights, KeyIndex first, KeyIndex end) noexcept {
        const std::size_t low_key = static_cast<std::size_t>(first);
        const std::size_t end_key = static_cast<std::size_t>(end);
        std::size_t low = low_key;
        std::size_t high = end_key; // the answer of the search lies in [low, high]
        while (low < high) {
            const std::size_t middle = low + (high - low) / 2;
            const ExactCost difference = split_difference(prefix, weights, low_key, middle, end_key);
            if (difference >= 0) {
                high = middle;
            } else {
                low = middle + 1;
            }
        }
        std::size_t chosen = low < end_key ? low : end_key - 1;
        if (chosen > low_key) {
            const ExactCost here = split_difference(prefix, weights, low_key, chosen, end_key);
            const ExactCost before = split_difference(prefix, weights, low_key, chosen - 1, end_key);
            const ExactCost here_size = here < 0 ? -here : here;
            const ExactCost before_size = before < 0 ? -before : before;
            if (before_size <= here_size) {
                chosen -= 1;
            }
        }
        return static_cast<KeyIndex>(chosen);
    }

    [[nodiscard]] static ExactCost split_difference(
        const std::vector<ExactCost>& prefix, const SearchWeights& weights,
        std::size_t first, std::size_t root, std::size_t end) noexcept {
        const ExactCost left_mass = interval_mass(prefix, weights, first, root);
        const ExactCost right_mass = interval_mass(prefix, weights, root + 1, end);
        return left_mass - right_mass;
    }

    [[nodiscard]] static bool same_layer(const detail::CondensedMatrix& a, const detail::CondensedMatrix& b) noexcept {
        if (a.top != b.top || a.core.size() != b.core.size()) {
            return false;
        }
        std::size_t index = 0;
        for (index = 0; index < a.core.size(); index += 1) {
            const detail::Density& x = a.core[index];
            const detail::Density& y = b.core[index];
            if (x.row != y.row || x.column != y.column || x.value != y.value) {
                return false;
            }
        }
        return true;
    }
};

} // namespace stx_btree
