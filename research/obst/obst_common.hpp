#pragma once

// Shared by the OBST research harnesses: weights, weight families and
// Knuth's O(n^2) tables, the oracle every construction is checked against.
//
// Keys 1..n carry hit weights p[k]; gaps 0..n carry miss weights q[g]. The
// interval (i, j) holds keys i+1..j and gaps i..j; its cost is the sum, over
// its nodes, of the weight of each node's subtree (Knuth's recurrence).

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <random>
#include <vector>

namespace obst {

typedef std::int64_t Cost;

struct Weights final {
    std::vector<Cost> key_prefix;  // key_prefix[k] = p[1] + ... + p[k]
    std::vector<Cost> gap_prefix;  // gap_prefix[g] = q[0] + ... + q[g-1]
    std::size_t keys = 0;

    // The weight of the interval (i, j).
    [[nodiscard]] Cost interval(std::size_t i, std::size_t j) const noexcept {
        return key_prefix[j] - key_prefix[i] + gap_prefix[j + 1] - gap_prefix[i];
    }
};

[[nodiscard]] inline Weights weights_from(const std::vector<Cost>& p, const std::vector<Cost>& q) {
    Weights weights;
    weights.keys = p.size() - 1;
    weights.key_prefix.assign(p.size(), 0);
    weights.gap_prefix.assign(q.size() + 1, 0);
    std::size_t index = 0;
    for (index = 1; index < p.size(); index += 1) {
        weights.key_prefix[index] = weights.key_prefix[index - 1] + p[index];
    }
    for (index = 0; index < q.size(); index += 1) {
        weights.gap_prefix[index + 1] = weights.gap_prefix[index] + q[index];
    }
    return weights;
}

enum class Family { uniform, random, keys_only, gaps_only, zipf, log_uniform, geometric };

[[nodiscard]] inline const char* family_name(Family family) noexcept {
    switch (family) {
    case Family::uniform:
        return "uniform";
    case Family::random:
        return "random";
    case Family::keys_only:
        return "keys_only";
    case Family::gaps_only:
        return "gaps_only";
    case Family::zipf:
        return "zipf";
    case Family::log_uniform:
        return "log_uniform";
    case Family::geometric:
        return "geometric";
    }
    return "unknown";
}

// p has n+1 entries (p[0] unused), q has n+1.
[[nodiscard]] inline Weights make_weights(Family family, std::size_t n, std::mt19937_64& random) {
    std::vector<Cost> p(n + 1, 0);
    std::vector<Cost> q(n + 1, 0);
    std::uniform_int_distribution<Cost> wide(1, 1000000);
    std::uniform_real_distribution<double> unit(0.0, 1.0);
    std::size_t index = 0;
    if (family == Family::zipf) {
        std::vector<std::size_t> rank(n, 0);
        for (index = 0; index < n; index += 1) {
            rank[index] = index + 1;
        }
        std::shuffle(rank.begin(), rank.end(), random);
        for (index = 1; index <= n; index += 1) {
            p[index] = static_cast<Cost>(1.0e9 / static_cast<double>(rank[index - 1])) + 1;
        }
        for (index = 0; index <= n; index += 1) {
            q[index] = 1;
        }
    } else {
        for (index = 0; index <= n; index += 1) {
            Cost key = 0;
            Cost gap = 0;
            switch (family) {
            case Family::uniform:
                key = 1;
                gap = 1;
                break;
            case Family::random:
                key = wide(random);
                gap = wide(random);
                break;
            case Family::keys_only:
                key = wide(random);
                gap = 0;
                break;
            case Family::gaps_only:
                key = 0;
                gap = wide(random);
                break;
            case Family::log_uniform:
                key = static_cast<Cost>(std::exp2(30.0 * unit(random)));
                gap = static_cast<Cost>(std::exp2(30.0 * unit(random)));
                break;
            case Family::geometric:
                key = static_cast<Cost>(1.0e12 * std::pow(0.93, static_cast<double>(index))) + 1;
                gap = static_cast<Cost>(1.0e11 * std::pow(0.93, static_cast<double>(index))) + 1;
                break;
            case Family::zipf:
                break;
            }
            if (index > 0) {
                p[index] = key;
            }
            q[index] = gap;
        }
    }
    return weights_from(p, q);
}

enum class TieRule { leftmost, rightmost };

// Knuth's O(n^2) tables: cost and root of every interval.
class KnuthTables final {
public:
    KnuthTables(const Weights& weights, TieRule rule)
        : side(weights.keys + 1),
          costs(side * side, 0),
          roots(side * side, 0) {
        const std::size_t n = weights.keys;
        std::size_t length = 0;
        for (length = 1; length <= n; length += 1) {
            std::size_t i = 0;
            for (i = 0; i + length <= n; i += 1) {
                const std::size_t j = i + length;
                std::size_t low = i + 1;
                std::size_t high = j;
                if (length > 1) {
                    low = root(i, j - 1);
                    high = root(i + 1, j);
                }
                std::size_t best_root = low;
                Cost best = cost(i, low - 1) + cost(low, j);
                std::size_t candidate = 0;
                evaluations += high - low + 1;
                for (candidate = low + 1; candidate <= high; candidate += 1) {
                    const Cost value = cost(i, candidate - 1) + cost(candidate, j);
                    const bool better = rule == TieRule::leftmost ? value < best : value <= best;
                    if (better) {
                        best = value;
                        best_root = candidate;
                    }
                }
                costs[i * side + j] = best + weights.interval(i, j);
                roots[i * side + j] = static_cast<std::uint32_t>(best_root);
            }
        }
    }

    [[nodiscard]] Cost cost(std::size_t i, std::size_t j) const noexcept {
        return costs[i * side + j];
    }

    // Candidate roots Knuth evaluated, over all intervals.
    [[nodiscard]] std::size_t candidate_evaluations() const noexcept {
        return evaluations;
    }

    // The root key of a nonempty interval.
    [[nodiscard]] std::size_t root(std::size_t i, std::size_t j) const noexcept {
        return roots[i * side + j];
    }

private:
    std::size_t side;
    std::size_t evaluations = 0;
    std::vector<Cost> costs;
    std::vector<std::uint32_t> roots;
};

} // namespace obst
