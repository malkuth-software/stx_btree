// The universal frontier: every tree a block of keys takes as the optimum of
// the exact pressure model (pressure.hpp) for some pair of outside spines,
// against the frontier it actually takes inside the enclosing intervals of
// one instance.
//
// By the model, the outside acts on a block only through X and Y, the facing
// outside spines' block weights from the top. Any positive sequence is a
// spine of some outside weights, so the universal frontier is the set of
// minimizers over all pairs of positive sequences of any lengths. It is the
// set a bottom-up construction would have to carry if it knew nothing of the
// block's surroundings; the measured frontier is the set the surroundings of
// one instance actually call for.
//
// The universal frontier is sampled, so the counts are lower bounds; the
// checkpoints show whether they have stopped growing, and the coverage of the
// measured frontier (which the universal one contains) shows whether the
// sampler reaches the pressures that occur. Outside sequences are drawn from
// a mixture: independent log-uniform block weights, the same sorted
// decreasing (heavier higher, as optimal seams have it), and geometric runs;
// lengths 0..max(8, 2|B|). Half the draws have no left part (right-only).
// The solver picks one minimizer, so under exact ties (uniform weights) a
// measured shape may differ from the sampled one only by the tie rule.

#include "pressure.hpp"

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <random>
#include <unordered_set>
#include <vector>

namespace obst {
namespace {

struct Measured final {
    std::unordered_set<std::uint64_t> shapes;
    std::unordered_set<std::uint64_t> right_shapes;
};

// The block's induced shape inside every enclosing interval of the instance.
[[nodiscard]] Measured measure(const KnuthTables& tables, std::size_t n, std::size_t a, std::size_t b) {
    Measured measured;
    std::size_t low = 0;
    for (low = 0; low <= a; low += 1) {
        std::size_t high = 0;
        for (high = b; high <= n; high += 1) {
            std::vector<std::size_t> depths(high - low, 0);
            depths_in(tables, low, high, 0, depths, low);
            const std::uint64_t shape = shape_hash(induced_depths(std::vector<std::size_t>(
                depths.begin() + static_cast<std::ptrdiff_t>(a - low), depths.begin() + static_cast<std::ptrdiff_t>(b - low))));
            measured.shapes.insert(shape);
            if (low == a) {
                measured.right_shapes.insert(shape);
            }
        }
    }
    return measured;
}

class PressureSource final {
public:
    PressureSource(double lightest_in, double heaviest_in, std::size_t longest_in) : lightest(lightest_in), heaviest(heaviest_in), longest(longest_in) {}

    void draw(std::mt19937_64& random, std::vector<Cost>& out) {
        out.clear();
        std::uniform_int_distribution<std::size_t> length(0, longest);
        std::uniform_int_distribution<int> mode(0, 2);
        std::uniform_real_distribution<double> unit(0.0, 1.0);
        const std::size_t count = length(random);
        const int kind = mode(random);
        const double span = std::log(heaviest / lightest);
        std::size_t index = 0;
        if (kind == 2) {
            const double first = lightest * std::exp(span * unit(random));
            const double ratio = 0.3 + 0.7 * unit(random);
            double value = first;
            for (index = 0; index < count; index += 1) {
                out.push_back(static_cast<Cost>(value) + 1);
                value *= ratio;
            }
            return;
        }
        for (index = 0; index < count; index += 1) {
            out.push_back(static_cast<Cost>(lightest * std::exp(span * unit(random))) + 1);
        }
        if (kind == 1) {
            std::sort(out.begin(), out.end());
            std::reverse(out.begin(), out.end());
        }
    }

private:
    double lightest;
    double heaviest;
    std::size_t longest;
};

[[nodiscard]] std::size_t covered(const std::unordered_set<std::uint64_t>& measured, const std::unordered_set<std::uint64_t>& found) {
    std::size_t count = 0;
    for (std::unordered_set<std::uint64_t>::const_iterator it = measured.begin(); it != measured.end(); ++it) {
        count += found.count(*it);
    }
    return count;
}

[[nodiscard]] double catalan(std::size_t keys) {
    double value = 1.0;
    std::size_t index = 0;
    for (index = 0; index < keys; index += 1) {
        value = value * 2.0 * static_cast<double>(2 * index + 1) / static_cast<double>(index + 2);
    }
    return value;
}

void run_block(Family family, const Weights& weights, const KnuthTables& tables, std::size_t n, std::size_t keys, std::size_t budget,
               std::mt19937_64& random) {
    const std::size_t a = n / 2 - keys / 2;
    const std::size_t b = a + keys;
    const Measured measured = measure(tables, n, a, b);
    double lightest = static_cast<double>(weights.interval(a, b));
    std::size_t gap = 0;
    for (gap = a; gap <= b; gap += 1) {
        const Cost weight = weights.gap_prefix[gap + 1] - weights.gap_prefix[gap];
        if (weight > 0) {
            lightest = std::min(lightest, static_cast<double>(weight));
        }
        if (gap > a) {
            const Cost key = key_weight(weights, gap);
            if (key > 0) {
                lightest = std::min(lightest, static_cast<double>(key));
            }
        }
    }
    PressureSource source(lightest / 4.0, 8.0 * static_cast<double>(weights.interval(a, b)), std::max<std::size_t>(8, 2 * keys));
    PressureSolver solver(weights, tables, a, b);
    std::unordered_set<std::uint64_t> found;
    std::unordered_set<std::uint64_t> right_found;
    std::vector<Cost> left_pressure;
    std::vector<Cost> right_pressure;
    std::vector<std::size_t> depths;
    std::size_t checkpoint = 1000;
    std::size_t sample = 0;
    for (sample = 1; sample <= budget; sample += 1) {
        const bool right_only = sample % 2 == 0;
        if (right_only) {
            left_pressure.clear();
        } else {
            source.draw(random, left_pressure);
        }
        source.draw(random, right_pressure);
        solver.solve(left_pressure, right_pressure, depths);
        const std::uint64_t shape = shape_hash(depths);
        found.insert(shape);
        if (right_only) {
            right_found.insert(shape);
        }
        if (sample == checkpoint || sample == budget) {
            std::printf("universal,%s,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%.0f\n", family_name(family), n, keys, sample, found.size(),
                        right_found.size(), measured.shapes.size(), measured.right_shapes.size(), covered(measured.shapes, found),
                        covered(measured.right_shapes, right_found), catalan(keys));
            std::fflush(stdout);
            checkpoint *= 10;
        }
    }
}

} // namespace
} // namespace obst

// Usage: universal_frontier <n> <seed>
int main(int argc, char** argv) {
    if (argc != 3) {
        std::fprintf(stderr, "usage: universal_frontier <n> <seed>\n");
        return 64;
    }
    const std::size_t n = static_cast<std::size_t>(std::strtoull(argv[1], nullptr, 10));
    std::mt19937_64 random(std::strtoull(argv[2], nullptr, 10));
    std::printf("universal,family,n,block_keys,samples,universal_shapes,universal_right_shapes,measured_shapes,measured_right_shapes,"
                "measured_covered,measured_right_covered,catalan\n");
    const obst::Family families[7] = {obst::Family::zipf,      obst::Family::log_uniform, obst::Family::geometric, obst::Family::random,
                                      obst::Family::keys_only, obst::Family::gaps_only,   obst::Family::uniform};
    const std::size_t sizes[6] = {4, 6, 8, 12, 16, 32};
    const std::size_t budgets[6] = {1000000, 1000000, 1000000, 200000, 200000, 30000};
    std::size_t family = 0;
    for (family = 0; family < 7; family += 1) {
        const obst::Weights weights = obst::make_weights(families[family], n, random);
        const obst::KnuthTables tables(weights, obst::TieRule::leftmost);
        std::size_t index = 0;
        for (index = 0; index < 6; index += 1) {
            obst::run_block(families[family], weights, tables, n, sizes[index], budgets[index], random);
        }
    }
    return 0;
}
