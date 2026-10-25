// The pressure model: is a block's tree inside any enclosing problem the
// optimum of the block alone under the pressure of its two facing outside
// spines?
//
// From the seam identity (context_frontier.cpp), the rest of an enclosing
// interval acts on a block B = (a, b) only through the facing spines: X, the
// left part's right spine, and Y, the right part's left spine (block weights
// from the top). The model: B's induced tree minimizes
//
//     cost_B(T) + mergeL(T, X) + mergeR(T, Y) + h(k_l, k_r),
//
// where mergeR is the best interleaving of T's right spine with Y (per pair
// the lower node pays its block weight), mergeL likewise on the left, k_l and
// k_r are the outside nodes of each side above B's root (the node both merges
// share), and h is a coupling of X and Y alone (pressure.hpp).
//
// Blocks: a right-spine node s below s' (or below the boundary a) has block
// p_s + W(s', s - 1); a left-spine node r below r' (or below b + 1) has block
// p_r + W(r, r' - 1). The root is on both spines.
//
// Two checks. (1) Exactness of the model: for sampled enclosing intervals,
// read X and Y off the outside parts of the canonical optimal tree, solve,
// and compare the model cost of B's induced tree with the minimum (equal cost
// means the model holds; a different shape at equal cost is a tie).
// (2) Random pressures: solve under randomly drawn outside sequences and
// count distinct shapes, against the frontier measured over enclosing
// intervals (universal_frontier.cpp does this properly).

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

struct ModelCheck final {
    std::size_t contexts = 0;
    std::size_t cost_mismatch = 0;   // the model's minimum is below B's induced tree's penalized cost
    std::size_t right_only = 0;      // contexts with a' = a
    std::size_t right_only_mismatch = 0;
    std::size_t above_minimum = 0;   // mismatches where the induced tree's cost is below the "minimum" (a bug)
    std::size_t shape_ties = 0;      // equal cost, different shape
    std::size_t measured_shapes = 0;
    std::size_t measured_right_shapes = 0;
};

[[nodiscard]] ModelCheck check_model(const Weights& weights, const KnuthTables& tables, std::size_t n, std::size_t a, std::size_t b,
                                     std::size_t samples, std::mt19937_64& random, std::unordered_set<std::uint64_t>& measured,
                                     std::unordered_set<std::uint64_t>& measured_right) {
    PressureSolver solver(weights, tables, a, b);
    ModelCheck check;
    std::uniform_int_distribution<std::size_t> outer_low(0, a);
    std::uniform_int_distribution<std::size_t> outer_high(b, n);
    std::vector<std::size_t> solved;
    std::size_t sample = 0;
    for (sample = 0; sample < samples; sample += 1) {
        // Every fourth context is right-only (a' = a).
        const std::size_t low = sample % 4 == 0 ? a : outer_low(random);
        const std::size_t high = outer_high(random);
        std::vector<std::size_t> depths(high - low, 0);
        depths_in(tables, low, high, 0, depths, low);
        // Outside spines from the top (the helpers list them from the bottom).
        std::vector<Cost> left_pressure = right_spine_blocks(weights, depths, low, low, a);
        std::vector<Cost> right_pressure = left_spine_blocks(weights, depths, low, b, high);
        std::reverse(left_pressure.begin(), left_pressure.end());
        std::reverse(right_pressure.begin(), right_pressure.end());
        const std::vector<std::size_t> block_depths = induced_depths(std::vector<std::size_t>(
            depths.begin() + static_cast<std::ptrdiff_t>(a - low), depths.begin() + static_cast<std::ptrdiff_t>(b - low)));
        const Cost minimum = solver.solve(left_pressure, right_pressure, solved);
        const Cost induced = solver.penalized_cost(block_depths, left_pressure, right_pressure);
        check.contexts += 1;
        const std::uint64_t induced_shape = shape_hash(block_depths);
        measured.insert(induced_shape);
        if (low == a) {
            measured_right.insert(induced_shape);
        }
        check.right_only += low == a ? 1 : 0;
        if (minimum != induced) {
            check.cost_mismatch += 1;
            check.right_only_mismatch += low == a ? 1 : 0;
            check.above_minimum += induced < minimum ? 1 : 0;
        } else if (shape_hash(solved) != induced_shape) {
            check.shape_ties += 1;
        }
    }
    check.measured_shapes = measured.size();
    check.measured_right_shapes = measured_right.size();
    return check;
}

struct Intrinsic final {
    std::size_t pressures = 0;
    std::size_t shapes = 0;
    std::size_t right_shapes = 0;
    std::size_t measured_covered = 0;  // measured shapes also found here
};

// Pressures drawn at random: each side has 0..max_spine blocks with weights
// log-uniform between the block's lightest key-or-gap and its total weight.
[[nodiscard]] Intrinsic sample_intrinsic(const Weights& weights, const KnuthTables& tables, std::size_t a, std::size_t b, std::size_t pressures,
                                         std::size_t max_spine, std::mt19937_64& random, const std::unordered_set<std::uint64_t>& measured) {
    PressureSolver solver(weights, tables, a, b);
    const double heaviest = static_cast<double>(weights.interval(a, b));
    double lightest = heaviest;
    std::size_t key = 0;
    for (key = a + 1; key <= b; key += 1) {
        const Cost weight = key_weight(weights, key);
        if (weight > 0) {
            lightest = std::min(lightest, static_cast<double>(weight));
        }
    }
    std::uniform_int_distribution<std::size_t> spine(0, max_spine);
    std::uniform_real_distribution<double> unit(0.0, 1.0);
    std::unordered_set<std::uint64_t> shapes;
    std::unordered_set<std::uint64_t> right_shapes;
    std::vector<std::size_t> depths;
    std::size_t sample = 0;
    for (sample = 0; sample < pressures; sample += 1) {
        std::vector<Cost> left_pressure;
        std::vector<Cost> right_pressure;
        const bool right_only = sample % 2 == 0;
        const std::size_t left_count = right_only ? 0 : spine(random);
        const std::size_t right_count = spine(random);
        std::size_t index = 0;
        for (index = 0; index < left_count; index += 1) {
            left_pressure.push_back(static_cast<Cost>(lightest * std::pow(heaviest / lightest, unit(random) * 1.5)));
        }
        for (index = 0; index < right_count; index += 1) {
            right_pressure.push_back(static_cast<Cost>(lightest * std::pow(heaviest / lightest, unit(random) * 1.5)));
        }
        solver.solve(left_pressure, right_pressure, depths);
        const std::uint64_t shape = shape_hash(depths);
        shapes.insert(shape);
        if (right_only) {
            right_shapes.insert(shape);
        }
    }
    Intrinsic intrinsic;
    intrinsic.pressures = pressures;
    intrinsic.shapes = shapes.size();
    intrinsic.right_shapes = right_shapes.size();
    for (std::unordered_set<std::uint64_t>::const_iterator it = measured.begin(); it != measured.end(); ++it) {
        intrinsic.measured_covered += shapes.count(*it);
    }
    return intrinsic;
}

} // namespace
} // namespace obst

// Usage: pressure_model <n> <contexts per block> <pressures per block> <seed>
int main(int argc, char** argv) {
    if (argc != 5) {
        std::fprintf(stderr, "usage: pressure_model <n> <contexts per block> <pressures per block> <seed>\n");
        return 64;
    }
    const std::size_t n = static_cast<std::size_t>(std::strtoull(argv[1], nullptr, 10));
    const std::size_t contexts = static_cast<std::size_t>(std::strtoull(argv[2], nullptr, 10));
    const std::size_t pressures = static_cast<std::size_t>(std::strtoull(argv[3], nullptr, 10));
    std::mt19937_64 random(std::strtoull(argv[4], nullptr, 10));
    std::printf("model,family,n,block_keys,contexts,cost_mismatch,right_only,right_only_mismatch,induced_below_minimum,shape_ties,measured_shapes,measured_right_shapes,"
                "intrinsic_pressures,intrinsic_shapes,intrinsic_right_shapes,measured_covered\n");
    const obst::Family families[7] = {obst::Family::zipf,      obst::Family::log_uniform, obst::Family::geometric, obst::Family::random,
                                      obst::Family::keys_only, obst::Family::gaps_only,   obst::Family::uniform};
    std::size_t family = 0;
    for (family = 0; family < 7; family += 1) {
        const obst::Weights weights = obst::make_weights(families[family], n, random);
        const obst::KnuthTables tables(weights, obst::TieRule::leftmost);
        std::size_t keys = 0;
        for (keys = 8; keys <= n / 8; keys *= 2) {
            const std::size_t low = n / 2 - keys / 2;
            std::unordered_set<std::uint64_t> measured;
            std::unordered_set<std::uint64_t> measured_right;
            const obst::ModelCheck check = obst::check_model(weights, tables, n, low, low + keys, contexts, random, measured, measured_right);
            const obst::Intrinsic intrinsic = obst::sample_intrinsic(weights, tables, low, low + keys, pressures, 24, random, measured);
            std::printf("model,%s,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%zu,%zu\n", obst::family_name(families[family]), n, keys,
                        check.contexts, check.cost_mismatch, check.right_only, check.right_only_mismatch, check.above_minimum, check.shape_ties, check.measured_shapes, check.measured_right_shapes, intrinsic.pressures,
                        intrinsic.shapes, intrinsic.right_shapes, intrinsic.measured_covered);
            std::fflush(stdout);
        }
    }
    return 0;
}
