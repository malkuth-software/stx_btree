// An exact construction that carries only one-sided frontiers and joins them
// through the seam.
//
// Over a dyadic hierarchy of blocks, each block (a, b) with midpoint key mid
// keeps
//   LF(a, v) for every prefix: the trees on (a, v) that can be optimal under
//            some pressure on their left spine (no pressure on the right),
//   RF(u, b) for every suffix: likewise under pressure on the right spine,
// each tree held as its cost and its pressured spine's block weights from the
// top. The pieces fit together three ways.
//
// - A plain optimum of an interval (i, j) crossing a block's midpoint is the
//   seam identity: cost(T_L) + cost(T_R) + merge over the facing spines,
//   minimized over T_L in the left child's RF(i, mid) and T_R in the right
//   child's LF(mid, j) (any optimum's halves are best responses to each
//   other, so they lie in those frontiers). Intervals inside one child recurse.
// - A right-pressured tree is a root rho, a plain left subtree (off the
//   spine, so unpressured) and a right-pressured right subtree:
//       RF(u, b) from rho, c(u, rho-1) and RF(rho, b);
//   the spine gains rho's block p_rho + W(u, rho-1) on top. LF mirrors it.
// - Frontiers are pruned by dominance: T dominates T' if cost(T) <= cost(T')
//   and T's spine embeds in order into T''s with each block no heavier. Then
//   for every outside sequence T does at least as well: map an interleaving
//   of T' onto T's matched nodes and drop the rest; each pair costs no more.
//   So pruning keeps a superset of the frontier and the construction is
//   exact. Prepending a common root preserves dominance.
//
// The answer is the plain optimum of (0, n), checked against Knuth's table.
// Work is counted as seam merges evaluated (pairs times merge size), frontier
// candidates generated, and dominance tests, against Knuth's candidate roots.

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

struct Pressured final {
    Cost cost = 0;
    std::vector<Cost> spine;  // block weights from the top
};

typedef std::vector<Pressured> Frontier;

struct Work final {
    std::size_t merge_steps = 0;     // lattice cells over all seam merges
    std::size_t pairs = 0;           // (T_L, T_R) pairs merged
    std::size_t candidates = 0;      // frontier candidates generated
    std::size_t dominance_steps = 0; // embedding steps over all dominance tests
    std::size_t plain_intervals = 0; // plain optima computed by the identity
    std::size_t frontier_trees = 0;  // trees kept over all frontiers
    std::size_t largest_frontier = 0;
};

// Whether `small` embeds in order into `large` with each block no heavier.
[[nodiscard]] bool embeds(const std::vector<Cost>& small, const std::vector<Cost>& large, Work& work) {
    std::size_t at = 0;
    std::size_t index = 0;
    for (index = 0; index < small.size(); index += 1) {
        while (at < large.size() && large[at] < small[index]) {
            at += 1;
            work.dominance_steps += 1;
        }
        if (at == large.size()) {
            return false;
        }
        at += 1;
        work.dominance_steps += 1;
    }
    return true;
}

[[nodiscard]] bool dominates(const Pressured& first, const Pressured& second, Work& work) {
    return first.cost <= second.cost && embeds(first.spine, second.spine, work);
}

void insert_pruned(Frontier& frontier, Pressured candidate, Work& work) {
    work.candidates += 1;
    std::size_t index = 0;
    for (index = 0; index < frontier.size(); index += 1) {
        if (dominates(frontier[index], candidate, work)) {
            return;
        }
    }
    std::size_t kept = 0;
    for (index = 0; index < frontier.size(); index += 1) {
        if (!dominates(candidate, frontier[index], work)) {
            if (kept != index) {
                frontier[kept] = std::move(frontier[index]);
            }
            kept += 1;
        }
    }
    frontier.resize(kept);
    frontier.push_back(std::move(candidate));
}

// The best interleaving of two facing spines (block weights from the top):
// per pair the lower node pays its block weight. Placing a node of `own` with
// k nodes of `other` above costs w * k plus the weights of the other nodes
// still to come; placing an `other` node is free.
[[nodiscard]] Cost seam_merge(const std::vector<Cost>& own, const std::vector<Cost>& other, Work& work) {
    if (own.empty() || other.empty()) {
        return 0;
    }
    const std::size_t others = other.size();
    std::vector<Cost> suffix(others + 1, 0);
    std::size_t k = others;
    while (k > 0) {
        k -= 1;
        suffix[k] = suffix[k + 1] + other[k];
    }
    std::vector<Cost> best(others + 1, 0);
    std::vector<Cost> next(others + 1, 0);
    std::size_t i = 0;
    for (i = 0; i < own.size(); i += 1) {
        Cost running = 0;
        for (k = 0; k <= others; k += 1) {
            running = k == 0 ? best[0] : std::min(running, best[k]);
            next[k] = running + own[i] * static_cast<Cost>(k) + suffix[k];
        }
        best.swap(next);
    }
    work.merge_steps += own.size() * (others + 1);
    Cost total = best[0];
    for (k = 1; k <= others; k += 1) {
        total = std::min(total, best[k]);
    }
    return total;
}

class Composer final {
public:
    Composer(const Weights& weights_in) : weights(weights_in) {}

    // The plain optimum of the whole range.
    Cost solve() {
        return plain(0, weights.keys);
    }

    Work work;

private:
    struct Block final {
        std::size_t low = 0;
        std::size_t high = 0;
    };

    [[nodiscard]] std::uint64_t slot(std::size_t a, std::size_t b) const noexcept {
        return static_cast<std::uint64_t>(a) * static_cast<std::uint64_t>(weights.keys + 1) + static_cast<std::uint64_t>(b);
    }

    [[nodiscard]] Cost key_weight(std::size_t key) const noexcept {
        return weights.key_prefix[key] - weights.key_prefix[key - 1];
    }

    // The smallest dyadic block of the hierarchy over (0, n) that holds keys
    // i+1..j, with more than one key.
    [[nodiscard]] Block block_of(std::size_t i, std::size_t j) const noexcept {
        Block block{.low = 0, .high = weights.keys};
        while (true) {
            const std::size_t mid = block.low + (block.high - block.low) / 2;
            if (j <= mid) {
                block.high = mid;
            } else if (i >= mid) {
                block.low = mid;
            } else {
                return block;
            }
        }
    }

    Cost plain(std::size_t i, std::size_t j) {
        if (j <= i) {
            return 0;
        }
        if (j == i + 1) {
            return weights.interval(i, j);
        }
        const std::unordered_map<std::uint64_t, Cost>::const_iterator found = plain_costs.find(slot(i, j));
        if (found != plain_costs.end()) {
            return (*found).second;
        }
        const Block block = block_of(i, j);
        const std::size_t mid = block.low + (block.high - block.low) / 2;
        const Frontier& left = right_frontier(i, mid);
        const Frontier& right = left_frontier(mid, j);
        Cost best = 0;
        bool have = false;
        std::size_t x = 0;
        for (x = 0; x < left.size(); x += 1) {
            std::size_t y = 0;
            for (y = 0; y < right.size(); y += 1) {
                work.pairs += 1;
                const Cost value = left[x].cost + right[y].cost + seam_merge(left[x].spine, right[y].spine, work);
                if (!have || value < best) {
                    best = value;
                    have = true;
                }
            }
        }
        work.plain_intervals += 1;
        plain_costs[slot(i, j)] = best;
        return best;
    }

    // RF(u, b): trees on (u, b) under pressure on the right spine. (u, b) is a
    // suffix of a block; the recurrence only needs plain optima inside it.
    const Frontier& right_frontier(std::size_t u, std::size_t b) {
        const std::uint64_t key = slot(u, b);
        const std::unordered_map<std::uint64_t, Frontier>::const_iterator found = right_frontiers.find(key);
        if (found != right_frontiers.end()) {
            return (*found).second;
        }
        Frontier frontier;
        if (u == b) {
            frontier.push_back(Pressured{.cost = 0, .spine = {}});
        } else {
            std::size_t root = 0;
            for (root = u + 1; root <= b; root += 1) {
                const Cost left_cost = plain(u, root - 1);
                const Frontier rest = right_frontier(root, b);
                const Cost block = key_weight(root) + weights.interval(u, root - 1);
                std::size_t index = 0;
                for (index = 0; index < rest.size(); index += 1) {
                    Pressured candidate;
                    candidate.cost = weights.interval(u, b) + left_cost + rest[index].cost;
                    candidate.spine.reserve(rest[index].spine.size() + 1);
                    candidate.spine.push_back(block);
                    candidate.spine.insert(candidate.spine.end(), rest[index].spine.begin(), rest[index].spine.end());
                    insert_pruned(frontier, std::move(candidate), work);
                }
            }
        }
        work.frontier_trees += frontier.size();
        work.largest_frontier = std::max(work.largest_frontier, frontier.size());
        right_frontiers[key] = std::move(frontier);
        return right_frontiers[key];
    }

    // LF(a, v): trees on (a, v) under pressure on the left spine.
    const Frontier& left_frontier(std::size_t a, std::size_t v) {
        const std::uint64_t key = slot(a, v);
        const std::unordered_map<std::uint64_t, Frontier>::const_iterator found = left_frontiers.find(key);
        if (found != left_frontiers.end()) {
            return (*found).second;
        }
        Frontier frontier;
        if (a == v) {
            frontier.push_back(Pressured{.cost = 0, .spine = {}});
        } else {
            std::size_t root = 0;
            for (root = a + 1; root <= v; root += 1) {
                const Cost right_cost = plain(root, v);
                const Frontier rest = left_frontier(a, root - 1);
                const Cost block = key_weight(root) + weights.interval(root, v);
                std::size_t index = 0;
                for (index = 0; index < rest.size(); index += 1) {
                    Pressured candidate;
                    candidate.cost = weights.interval(a, v) + right_cost + rest[index].cost;
                    candidate.spine.reserve(rest[index].spine.size() + 1);
                    candidate.spine.push_back(block);
                    candidate.spine.insert(candidate.spine.end(), rest[index].spine.begin(), rest[index].spine.end());
                    insert_pruned(frontier, std::move(candidate), work);
                }
            }
        }
        work.frontier_trees += frontier.size();
        work.largest_frontier = std::max(work.largest_frontier, frontier.size());
        left_frontiers[key] = std::move(frontier);
        return left_frontiers[key];
    }

    const Weights& weights;
    std::unordered_map<std::uint64_t, Cost> plain_costs;
    std::unordered_map<std::uint64_t, Frontier> right_frontiers;
    std::unordered_map<std::uint64_t, Frontier> left_frontiers;
};

} // namespace
} // namespace obst

// Usage: frontier_compose <largest n> <seed>
int main(int argc, char** argv) {
    if (argc != 3) {
        std::fprintf(stderr, "usage: frontier_compose <largest n> <seed>\n");
        return 64;
    }
    const std::size_t largest = static_cast<std::size_t>(std::strtoull(argv[1], nullptr, 10));
    std::mt19937_64 random(std::strtoull(argv[2], nullptr, 10));
    std::printf("compose,family,n,exact,knuth_candidates,plain_intervals,pairs,merge_steps,candidates,dominance_steps,frontier_trees,"
                "largest_frontier,knuth_ms,compose_ms\n");
    const obst::Family families[7] = {obst::Family::zipf,      obst::Family::log_uniform, obst::Family::geometric, obst::Family::random,
                                      obst::Family::keys_only, obst::Family::gaps_only,   obst::Family::uniform};
    std::size_t family = 0;
    for (family = 0; family < 7; family += 1) {
        std::size_t n = 0;
        for (n = 2; n <= largest; n += n < 16 ? 1 : n) {
            std::size_t repetition = 0;
            for (repetition = 0; repetition < (n <= 16 ? 10 : 1); repetition += 1) {
                const obst::Weights weights = obst::make_weights(families[family], n, random);
                const std::chrono::steady_clock::time_point knuth_start = std::chrono::steady_clock::now();
                const obst::KnuthTables tables(weights, obst::TieRule::leftmost);
                const std::chrono::steady_clock::time_point knuth_end = std::chrono::steady_clock::now();
                obst::Composer composer(weights);
                const obst::Cost cost = composer.solve();
                const std::chrono::steady_clock::time_point compose_end = std::chrono::steady_clock::now();
                const bool exact = cost == tables.cost(0, n);
                if (!exact) {
                    std::fprintf(stderr, "inexact: %s n=%zu cost %lld optimum %lld\n", obst::family_name(families[family]), n,
                                 static_cast<long long>(cost), static_cast<long long>(tables.cost(0, n)));
                }
                const obst::Work& work = composer.work;
                std::printf("compose,%s,%zu,%d,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%.3f,%.3f\n", obst::family_name(families[family]), n, exact ? 1 : 0,
                            tables.candidate_evaluations(), work.plain_intervals, work.pairs, work.merge_steps, work.candidates,
                            work.dominance_steps, work.frontier_trees, work.largest_frontier,
                            std::chrono::duration<double, std::milli>(knuth_end - knuth_start).count(),
                            std::chrono::duration<double, std::milli>(compose_end - knuth_end).count());
                std::fflush(stdout);
            }
        }
    }
    return 0;
}
