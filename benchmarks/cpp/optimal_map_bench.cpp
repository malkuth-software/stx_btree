// Lookups under skewed access, and optimal tree construction times.
//
//   optimal_map_bench lookup <keys> <zipf exponent> <queries> <repetitions> <construction> [slack percent]
//   optimal_map_bench construct <keys> <family> <repetitions>
//
// lookup: random 64-bit keys; key ranks follow a random permutation, and a
// query asks for the key of rank r with probability proportional to the
// integer weight round(10^12 / (r + 1)^s), at least 1 (s = 0 is uniform).
// Those same integers are the key weights the skewed map is built for; gap
// weights are 1. Each structure answers the same query stream, values summed
// into a checksum that must agree. Structures:
//   sorted_array       std::lower_bound over sorted (key, value) records
//   bbtree_unsync      stx_btree::unsync::BBTreeMap, find
//   optimal_uniform    OptimalMap built for uniform weights (the shape a
//                      balanced static tree gets), find and find_many
//   optimal_skewed     OptimalMap built for the query weights, find and
//                      find_many
// construction is knuth, monge_layers or weight_balanced, for the skewed map.
//
// construct: the three constructions and the packing on one weight family
// (uniform, zipf, random) at the given size, seconds per build.
//
// One CSV line per measurement: mode, structure, keys, parameter, ns per
// operation (median over repetitions), min, max, and an extra field.

#include "stx_btree/optimal_map.hpp"
#include "stx_btree/unsync_map.hpp"

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <span>
#include <string>
#include <vector>

namespace {

using stx_btree::ExactCost;
using stx_btree::MongeLayerReport;
using stx_btree::OptimalMap;
using stx_btree::OptimalMapPlan;
using stx_btree::OptimalTreeBuilder;
using stx_btree::SearchTree;
using stx_btree::SearchWeight;
using stx_btree::SearchWeights;
using stx_btree::TreeConstruction;
using Clock = std::chrono::steady_clock;
using Map = OptimalMap<std::uint64_t, std::uint64_t>;
using BTree = stx_btree::unsync::BBTreeMap<std::uint64_t, std::uint64_t>;

class Random final {
public:
    explicit Random(std::uint64_t seed) noexcept : state(seed) {}
    [[nodiscard]] std::uint64_t next() noexcept {
        std::uint64_t z = state + 0x9e3779b97f4a7c15ULL;
        state = z;
        z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL;
        z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL;
        return z ^ (z >> 31);
    }

private:
    std::uint64_t state;
};

struct Record final {
    std::uint64_t key;
    std::uint64_t value;
};

struct RecordKeyBelow final {
    bool operator()(const Record& record, std::uint64_t key) const noexcept {
        return record.key < key;
    }
};

struct Summary final {
    double median;
    double minimum;
    double maximum;
};

Summary summarize(std::vector<double> samples) {
    std::sort(samples.begin(), samples.end());
    const Summary summary{.median = samples[samples.size() / 2], .minimum = samples.front(), .maximum = samples.back()};
    return summary;
}

void print_line(const char* mode, const char* structure, std::size_t keys, const std::string& parameter,
                const Summary& summary, const std::string& extra) {
    std::printf("%s,%s,%zu,%s,%.3f,%.3f,%.3f,%s\n", mode, structure, keys, parameter.c_str(), summary.median,
                summary.minimum, summary.maximum, extra.c_str());
    std::fflush(stdout);
}

double seconds_since(Clock::time_point start) {
    const std::chrono::duration<double> elapsed = Clock::now() - start;
    return elapsed.count();
}

std::uint64_t checksum_sorted(const std::vector<Record>& records, const std::vector<std::uint64_t>& queries) {
    std::uint64_t sum = 0;
    std::size_t index = 0;
    for (index = 0; index < queries.size(); index += 1) {
        const std::vector<Record>::const_iterator found =
            std::lower_bound(records.begin(), records.end(), queries[index], RecordKeyBelow{});
        if (found != records.end() && (*found).key == queries[index]) {
            sum += (*found).value;
        }
    }
    return sum;
}

std::uint64_t checksum_btree(const BTree& tree, const std::vector<std::uint64_t>& queries) {
    std::uint64_t sum = 0;
    std::size_t index = 0;
    for (index = 0; index < queries.size(); index += 1) {
        const std::uint64_t* found = tree.find(queries[index]);
        if (found != nullptr) {
            sum += *found;
        }
    }
    return sum;
}

std::uint64_t checksum_map(const Map& map, const std::vector<std::uint64_t>& queries) {
    std::uint64_t sum = 0;
    std::size_t index = 0;
    for (index = 0; index < queries.size(); index += 1) {
        const std::uint64_t* found = map.find(queries[index]);
        if (found != nullptr) {
            sum += *found;
        }
    }
    return sum;
}

std::uint64_t checksum_map_batched(const Map& map, const std::vector<std::uint64_t>& queries,
                                   std::vector<const std::uint64_t*>& results) {
    map.find_many(std::span<const std::uint64_t>(queries.data(), queries.size()),
                  std::span<const std::uint64_t*>(results.data(), results.size()));
    std::uint64_t sum = 0;
    std::size_t index = 0;
    for (index = 0; index < results.size(); index += 1) {
        if (results[index] != nullptr) {
            sum += *results[index];
        }
    }
    return sum;
}

TreeConstruction parse_construction(const char* text) {
    if (std::strcmp(text, "knuth") == 0) {
        return TreeConstruction::knuth;
    }
    if (std::strcmp(text, "monge_layers") == 0) {
        return TreeConstruction::monge_layers;
    }
    return TreeConstruction::weight_balanced;
}

// Expected node visits per search, from the map's packed cost.
std::string visits_per_search(const Map& map, ExactCost total_mass) {
    const double visits = static_cast<double>(map.stats().expected_visits) / static_cast<double>(total_mass);
    char text[128];
    const double packed = static_cast<double>(map.stats().packed_visits) / static_cast<double>(total_mass);
    std::snprintf(text, sizeof(text), "visits=%.4f;packed_visits=%.4f;nodes=%zu;height=%zu", visits, packed,
                  map.stats().nodes, map.stats().height);
    return std::string(text);
}

int run_lookup(std::size_t key_count, double exponent, std::size_t query_count, std::size_t repetitions,
               TreeConstruction construction, const char* construction_name, std::uint32_t slack_percent) {
    Random random(0x5eed0b57ULL + key_count);
    std::vector<std::uint64_t> keys;
    keys.reserve(key_count);
    while (keys.size() < key_count) {
        keys.push_back(random.next());
        if (keys.size() == key_count) {
            std::sort(keys.begin(), keys.end());
            keys.erase(std::unique(keys.begin(), keys.end()), keys.end());
        }
    }
    std::vector<std::uint64_t> values(key_count, 0);
    std::size_t index = 0;
    for (index = 0; index < key_count; index += 1) {
        values[index] = random.next() >> 8;
    }
    // rank_of_key: a random permutation; weight by rank.
    std::vector<std::size_t> key_of_rank(key_count, 0);
    for (index = 0; index < key_count; index += 1) {
        key_of_rank[index] = index;
    }
    for (index = key_count; index > 1; index -= 1) {
        const std::size_t other = static_cast<std::size_t>(random.next() % index);
        const std::size_t swapped = key_of_rank[index - 1];
        key_of_rank[index - 1] = key_of_rank[other];
        key_of_rank[other] = swapped;
    }
    SearchWeights skewed;
    skewed.keys.assign(key_count, 0);
    skewed.gaps.assign(key_count + 1, 1);
    std::vector<SearchWeight> rank_weight(key_count, 0);
    for (index = 0; index < key_count; index += 1) {
        const double scaled = 1e12 / std::pow(static_cast<double>(index + 1), exponent);
        const SearchWeight weight = static_cast<SearchWeight>(std::llround(scaled));
        rank_weight[index] = weight > 0 ? weight : 1;
        skewed.keys[key_of_rank[index]] = rank_weight[index];
    }
    // Queries: sample ranks by their exact integer weights.
    std::vector<ExactCost> cumulative(key_count, 0);
    ExactCost running = 0;
    for (index = 0; index < key_count; index += 1) {
        running += static_cast<ExactCost>(rank_weight[index]);
        cumulative[index] = running;
    }
    std::vector<std::uint64_t> queries(query_count, 0);
    for (index = 0; index < query_count; index += 1) {
        const ExactCost draw = static_cast<ExactCost>(random.next()) % running;
        const std::vector<ExactCost>::const_iterator at = std::upper_bound(cumulative.begin(), cumulative.end(), draw);
        const std::size_t rank = static_cast<std::size_t>(at - cumulative.begin());
        queries[index] = keys[key_of_rank[rank]];
    }

    std::vector<Record> records(key_count, Record{.key = 0, .value = 0});
    for (index = 0; index < key_count; index += 1) {
        records[index] = Record{.key = keys[index], .value = values[index]};
    }
    BTree tree;
    for (index = 0; index < key_count; index += 1) {
        tree.insert(keys[index], values[index]);
    }
    SearchWeights uniform;
    uniform.keys.assign(key_count, 1);
    uniform.gaps.assign(key_count + 1, 1);
    Clock::time_point start = Clock::now();
    const OptimalMapPlan uniform_plan{.tree = TreeConstruction::weight_balanced, .count_layout_slack_percent = slack_percent};
    const Map uniform_map = Map::build(keys, values, uniform, uniform_plan);
    const double uniform_build = seconds_since(start);
    start = Clock::now();
    const OptimalMapPlan skewed_plan{.tree = construction, .count_layout_slack_percent = slack_percent};
    const Map skewed_map = Map::build(keys, values, skewed, skewed_plan);
    const double skewed_build = seconds_since(start);

    std::vector<const std::uint64_t*> results(query_count, nullptr);
    const std::uint64_t expected = checksum_sorted(records, queries);
    std::vector<std::vector<double>> samples(6);
    std::size_t repetition = 0;
    for (repetition = 0; repetition < repetitions; repetition += 1) {
        std::uint64_t sums[6] = {0, 0, 0, 0, 0, 0};
        start = Clock::now();
        sums[0] = checksum_sorted(records, queries);
        samples[0].push_back(seconds_since(start));
        start = Clock::now();
        sums[1] = checksum_btree(tree, queries);
        samples[1].push_back(seconds_since(start));
        start = Clock::now();
        sums[2] = checksum_map(uniform_map, queries);
        samples[2].push_back(seconds_since(start));
        start = Clock::now();
        sums[3] = checksum_map_batched(uniform_map, queries, results);
        samples[3].push_back(seconds_since(start));
        start = Clock::now();
        sums[4] = checksum_map(skewed_map, queries);
        samples[4].push_back(seconds_since(start));
        start = Clock::now();
        sums[5] = checksum_map_batched(skewed_map, queries, results);
        samples[5].push_back(seconds_since(start));
        std::size_t which = 0;
        for (which = 0; which < 6; which += 1) {
            if (sums[which] != expected) {
                std::fprintf(stderr, "checksum mismatch in structure %zu\n", which);
                return 1;
            }
        }
    }
    const char* names[6] = {"sorted_array", "bbtree_unsync", "optimal_uniform", "optimal_uniform_batched",
                            "optimal_skewed", "optimal_skewed_batched"};
    char parameter_text[64];
    std::snprintf(parameter_text, sizeof(parameter_text), "s=%.2f", exponent);
    const ExactCost uniform_mass = static_cast<ExactCost>(2 * key_count + 1);
    const ExactCost skewed_mass = stx_btree::SearchWeightRules::total_mass(skewed);
    std::size_t which = 0;
    for (which = 0; which < 6; which += 1) {
        std::vector<double> per_query;
        std::size_t sample = 0;
        for (sample = 0; sample < samples[which].size(); sample += 1) {
            per_query.push_back(samples[which][sample] * 1e9 / static_cast<double>(query_count));
        }
        std::string extra;
        if (which == 2 || which == 3) {
            extra = visits_per_search(uniform_map, uniform_mass);
            char build_text[48];
            std::snprintf(build_text, sizeof(build_text), ";build_s=%.3f", uniform_build);
            extra += build_text;
        }
        if (which == 4 || which == 5) {
            // The skewed map's visits under the query distribution; the
            // uniform map's under the same distribution is not computed.
            extra = visits_per_search(skewed_map, skewed_mass);
            char build_text[80];
            std::snprintf(build_text, sizeof(build_text), ";build_s=%.3f;construction=%s;slack=%u", skewed_build, construction_name,
                          static_cast<unsigned>(slack_percent));
            extra += build_text;
        }
        print_line("lookup", names[which], key_count, parameter_text, summarize(per_query), extra);
    }
    return 0;
}

int run_construct(std::size_t key_count, const char* family, std::size_t repetitions) {
    Random random(0xc0457ULL + key_count);
    SearchWeights weights;
    weights.keys.assign(key_count, 1);
    weights.gaps.assign(key_count + 1, 1);
    std::size_t index = 0;
    if (std::strcmp(family, "zipf") == 0) {
        for (index = 0; index < key_count; index += 1) {
            const std::size_t rank = static_cast<std::size_t>(random.next() % key_count);
            weights.keys[index] = static_cast<SearchWeight>(1000000 / (rank + 1)) + 1;
        }
    } else if (std::strcmp(family, "random") == 0) {
        for (index = 0; index < key_count; index += 1) {
            weights.keys[index] = 1 + random.next() % 1000;
        }
        for (index = 0; index <= key_count; index += 1) {
            weights.gaps[index] = random.next() % 1000;
        }
    }
    std::vector<double> knuth_seconds;
    std::vector<double> monge_seconds;
    std::vector<double> balanced_seconds;
    std::vector<double> packing_seconds;
    MongeLayerReport report;
    ExactCost optimal = 0;
    ExactCost balanced_cost = 0;
    std::size_t repetition = 0;
    for (repetition = 0; repetition < repetitions; repetition += 1) {
        Clock::time_point start = Clock::now();
        const SearchTree by_knuth = OptimalTreeBuilder::knuth(weights);
        knuth_seconds.push_back(seconds_since(start));
        start = Clock::now();
        const SearchTree by_layers = OptimalTreeBuilder::monge_layers(weights, report);
        monge_seconds.push_back(seconds_since(start));
        start = Clock::now();
        const SearchTree balanced = OptimalTreeBuilder::weight_balanced(weights);
        balanced_seconds.push_back(seconds_since(start));
        start = Clock::now();
        const stx_btree::detail::PackedTree packed =
            stx_btree::detail::TreePacker::pack(by_knuth.shape, weights, Map::node_capacity);
        packing_seconds.push_back(seconds_since(start));
        if (by_knuth.cost != by_layers.cost) {
            std::fprintf(stderr, "knuth and monge_layers disagree\n");
            return 1;
        }
        optimal = by_knuth.cost;
        balanced_cost = balanced.cost;
        (void)packed;
    }
    const std::string parameter(family);
    char extra[192];
    std::snprintf(extra, sizeof(extra), "height_bound=%zu;layers=%zu;fixed_point=%d;largest_core=%zu;witness_slots=%zu",
                  report.height_bound, report.layers, report.reached_fixed_point ? 1 : 0, report.largest_core,
                  report.witness_slots);
    char ratio[64];
    std::snprintf(ratio, sizeof(ratio), "cost_ratio=%.5f", static_cast<double>(balanced_cost) / static_cast<double>(optimal));
    // Seconds, not nanoseconds, for construction lines.
    print_line("construct", "knuth", key_count, parameter, summarize(knuth_seconds), "");
    print_line("construct", "monge_layers", key_count, parameter, summarize(monge_seconds), std::string(extra));
    print_line("construct", "weight_balanced", key_count, parameter, summarize(balanced_seconds), std::string(ratio));
    print_line("construct", "packing", key_count, parameter, summarize(packing_seconds), "");
    return 0;
}

} // namespace

int main(int argc, char** argv) {
    if (argc >= 7 && std::strcmp(argv[1], "lookup") == 0) {
        const std::size_t key_count = std::strtoull(argv[2], nullptr, 10);
        const double exponent = std::strtod(argv[3], nullptr);
        const std::size_t query_count = std::strtoull(argv[4], nullptr, 10);
        const std::size_t repetitions = std::strtoull(argv[5], nullptr, 10);
        const std::uint32_t slack_percent = argc >= 8 ? static_cast<std::uint32_t>(std::strtoul(argv[7], nullptr, 10)) : 2;
        return run_lookup(key_count, exponent, query_count, repetitions, parse_construction(argv[6]), argv[6], slack_percent);
    }
    if (argc >= 5 && std::strcmp(argv[1], "construct") == 0) {
        const std::size_t key_count = std::strtoull(argv[2], nullptr, 10);
        const std::size_t repetitions = std::strtoull(argv[4], nullptr, 10);
        return run_construct(key_count, argv[3], repetitions);
    }
    std::fprintf(stderr,
                 "usage: optimal_map_bench lookup <keys> <zipf s> <queries> <repetitions> <knuth|monge_layers|weight_balanced> [count layout slack percent]\n"
                 "       optimal_map_bench construct <keys> <uniform|zipf|random> <repetitions>\n");
    return 2;
}
