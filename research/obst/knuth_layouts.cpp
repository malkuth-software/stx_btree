// Knuth's construction in three memory layouts, timed against the library's.
//
//   library   OptimalTreeBuilder::knuth: diagonals by length over a row-major
//             triangle of 128-bit costs plus a root per cell (20 bytes/cell).
//   diagonal  The same schedule; only the previous diagonal's roots kept (one
//             array, overwritten in place: interval (i, j) reads roots i and
//             i + 1, written by the previous length); costs row-major.
//   column    Rows i from the last down, j rising; costs column-major, so the
//             candidates' right terms C(r + 1, j) are one contiguous run of
//             column j next to the cell being written, and the current row's
//             costs C(i, r) are kept in one array. Roots: root(i, j - 1) is the
//             previous cell's, root(i + 1, j) the previous row's, one array.
// The last two drop the root table and recover the final tree's roots after,
// as the leftmost r with C(i, r) + C(r + 1, j) = C(i, j) - W(i, j) (exact
// integers; the leftmost optimum, which Knuth's restricted search also
// returns), and each runs with 64-bit costs (when the total mass times the
// height bound fits) and with 128-bit ones. Recovery is inside the timing.
// Every variant's cost and tree are checked against the library's.
//
// Library convention: keys 0..n-1, gaps 0..n; interval (i, j) holds keys
// i..j-1 and gaps i..j; C(i, i) = 0; roots r in [i, j - 1] split it into
// (i, r) and (r + 1, j).

#include "stx_btree/optimal_tree.hpp"

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <random>
#include <vector>

namespace {

using stx_btree::ExactCost;
using stx_btree::SearchWeights;

struct Outcome final {
    ExactCost cost = 0;
    std::vector<std::size_t> parent;  // parent key of each key, n for the root
    double milliseconds = 0.0;
    double recovery_milliseconds = 0.0;
    std::size_t bytes = 0;
};

template <typename Cost>
std::vector<Cost> prefix_of(const SearchWeights& weights) {
    const std::size_t n = weights.keys.size();
    std::vector<Cost> prefix(n + 1, 0);
    std::size_t key = 0;
    for (key = 0; key < n; key += 1) {
        prefix[key + 1] = prefix[key] + static_cast<Cost>(weights.keys[key]) + static_cast<Cost>(weights.gaps[key + 1]);
    }
    return prefix;
}

// Recovers the final tree's parents by the leftmost root satisfying the
// recurrence with equality; `cell(i, j)` reads C(i, j).
template <typename Cost, typename Cells>
void recover(const SearchWeights& weights, const std::vector<Cost>& prefix, const Cells& cells, std::vector<std::size_t>& parent) {
    const std::size_t n = weights.keys.size();
    parent.assign(n, n);
    struct Pending final {
        std::size_t first;
        std::size_t end;
        std::size_t parent;
    };
    std::vector<Pending> pending;
    pending.push_back(Pending{.first = 0, .end = n, .parent = n});
    while (!pending.empty()) {
        const Pending interval = pending.back();
        pending.pop_back();
        if (interval.first == interval.end) {
            continue;
        }
        const Cost target = cells.at(interval.first, interval.end) -
                            (prefix[interval.end] - prefix[interval.first] + static_cast<Cost>(weights.gaps[interval.first]));
        std::size_t root = interval.first;
        while (cells.at(interval.first, root) + cells.at(root + 1, interval.end) != target) {
            root += 1;
        }
        parent[root] = interval.parent;
        pending.push_back(Pending{.first = interval.first, .end = root, .parent = root});
        pending.push_back(Pending{.first = root + 1, .end = interval.end, .parent = root});
    }
}

template <typename Cost>
struct RowMajor final {
    std::size_t side;  // n + 1
    std::vector<Cost> cells;
    std::vector<std::size_t> offset;

    explicit RowMajor(std::size_t n) : side(n + 1), cells((n + 1) * (n + 2) / 2, 0), offset(n + 1, 0) {
        std::size_t row = 0;
        for (row = 0; row <= n; row += 1) {
            offset[row] = row * side - row * (row - 1) / 2 - row;
        }
    }
    [[nodiscard]] Cost at(std::size_t i, std::size_t j) const noexcept {
        return cells[offset[i] + j];
    }
};

template <typename Cost>
struct ColumnMajor final {
    std::vector<Cost> cells;

    explicit ColumnMajor(std::size_t n) : cells((n + 1) * (n + 2) / 2, 0) {}
    [[nodiscard]] Cost at(std::size_t i, std::size_t j) const noexcept {
        return cells[j * (j + 1) / 2 + i];
    }
};

template <typename Cost>
Outcome diagonal(const SearchWeights& weights) {
    const std::chrono::steady_clock::time_point start = std::chrono::steady_clock::now();
    const std::size_t n = weights.keys.size();
    const std::vector<Cost> prefix = prefix_of<Cost>(weights);
    RowMajor<Cost> table(n);
    std::vector<std::size_t> roots(n + 1, 0);
    std::size_t length = 0;
    for (length = 1; length <= n; length += 1) {
        std::size_t i = 0;
        for (i = 0; i + length <= n; i += 1) {
            const std::size_t j = i + length;
            const std::size_t low = length == 1 ? i : roots[i];
            const std::size_t high = length == 1 ? i : roots[i + 1];
            const Cost* row = table.cells.data() + table.offset[i];
            Cost best = row[low] + table.cells[table.offset[low + 1] + j];
            std::size_t best_root = low;
            std::size_t r = 0;
            for (r = low + 1; r <= high; r += 1) {
                const Cost value = row[r] + table.cells[table.offset[r + 1] + j];
                if (value < best) {
                    best = value;
                    best_root = r;
                }
            }
            table.cells[table.offset[i] + j] = best + prefix[j] - prefix[i] + static_cast<Cost>(weights.gaps[i]);
            roots[i] = best_root;
        }
    }
    Outcome outcome;
    const std::chrono::steady_clock::time_point recovery_start = std::chrono::steady_clock::now();
    recover(weights, prefix, table, outcome.parent);
    outcome.recovery_milliseconds = std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - recovery_start).count();
    outcome.cost = static_cast<ExactCost>(table.at(0, n));
    outcome.milliseconds = std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - start).count();
    outcome.bytes = table.cells.size() * sizeof(Cost);
    return outcome;
}

template <typename Cost>
Outcome column(const SearchWeights& weights) {
    const std::chrono::steady_clock::time_point start = std::chrono::steady_clock::now();
    const std::size_t n = weights.keys.size();
    const std::vector<Cost> prefix = prefix_of<Cost>(weights);
    ColumnMajor<Cost> table(n);
    std::vector<Cost> row(n + 1, 0);           // C(i, r) for the current row i
    std::vector<std::size_t> roots(n + 1, 0);  // roots[j]: root(i + 1, j), then root(i, j)
    std::size_t i = n;
    while (i > 0) {
        i -= 1;
        row[i] = 0;
        std::size_t previous = i;  // root(i, j - 1)
        std::size_t j = 0;
        for (j = i + 1; j <= n; j += 1) {
            const std::size_t low = j == i + 1 ? i : previous;
            const std::size_t high = j == i + 1 ? i : roots[j];
            Cost* const column_j = table.cells.data() + j * (j + 1) / 2;
            Cost best = row[low] + column_j[low + 1];
            std::size_t best_root = low;
            std::size_t r = 0;
            for (r = low + 1; r <= high; r += 1) {
                const Cost value = row[r] + column_j[r + 1];
                if (value < best) {
                    best = value;
                    best_root = r;
                }
            }
            const Cost value = best + prefix[j] - prefix[i] + static_cast<Cost>(weights.gaps[i]);
            column_j[i] = value;
            row[j] = value;
            roots[j] = best_root;
            previous = best_root;
        }
    }
    Outcome outcome;
    const std::chrono::steady_clock::time_point recovery_start = std::chrono::steady_clock::now();
    recover(weights, prefix, table, outcome.parent);
    outcome.recovery_milliseconds = std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - recovery_start).count();
    outcome.cost = static_cast<ExactCost>(table.at(0, n));
    outcome.milliseconds = std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - start).count();
    outcome.bytes = table.cells.size() * sizeof(Cost);
    return outcome;
}

Outcome library(const SearchWeights& weights) {
    const std::chrono::steady_clock::time_point start = std::chrono::steady_clock::now();
    const stx_btree::SearchTree tree = stx_btree::OptimalTreeBuilder::knuth(weights);
    Outcome outcome;
    outcome.milliseconds = std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - start).count();
    outcome.cost = tree.cost;
    const std::size_t n = weights.keys.size();
    outcome.parent.assign(n, n);
    std::size_t key = 0;
    for (key = 0; key < n; key += 1) {
        const stx_btree::KeyIndex left = tree.shape.left[key];
        const stx_btree::KeyIndex right = tree.shape.right[key];
        if (left != stx_btree::no_key) {
            outcome.parent[static_cast<std::size_t>(left)] = key;
        }
        if (right != stx_btree::no_key) {
            outcome.parent[static_cast<std::size_t>(right)] = key;
        }
    }
    outcome.bytes = (n + 1) * (n + 2) / 2 * 20;
    return outcome;
}

SearchWeights make(const char* family, std::size_t n, std::mt19937_64& random) {
    SearchWeights weights;
    weights.keys.assign(n, 0);
    weights.gaps.assign(n + 1, 0);
    std::uniform_int_distribution<std::uint64_t> small(1, 1000);
    std::normal_distribution<double> normal(0.0, 2.0);
    std::size_t index = 0;
    if (std::strcmp(family, "zipf") == 0) {
        std::vector<std::size_t> rank(n, 0);
        for (index = 0; index < n; index += 1) {
            rank[index] = index + 1;
        }
        std::shuffle(rank.begin(), rank.end(), random);
        for (index = 0; index < n; index += 1) {
            weights.keys[index] = static_cast<std::uint64_t>(1.0e6 / static_cast<double>(rank[index])) + 1;
        }
        for (index = 0; index <= n; index += 1) {
            weights.gaps[index] = 1;
        }
    } else if (std::strcmp(family, "log_normal") == 0) {
        for (index = 0; index < n; index += 1) {
            weights.keys[index] = static_cast<std::uint64_t>(std::exp(10.0 + normal(random))) + 1;
        }
        for (index = 0; index <= n; index += 1) {
            weights.gaps[index] = static_cast<std::uint64_t>(std::exp(8.0 + normal(random))) + 1;
        }
    } else if (std::strcmp(family, "laplacian") == 0) {
        const double centre = static_cast<double>(n) / 2.0;
        const double scale = static_cast<double>(n) / 16.0;
        for (index = 0; index < n; index += 1) {
            weights.keys[index] = static_cast<std::uint64_t>(1.0e9 * std::exp(-std::fabs(static_cast<double>(index) - centre) / scale)) + 1;
        }
        for (index = 0; index <= n; index += 1) {
            weights.gaps[index] = static_cast<std::uint64_t>(1.0e8 * std::exp(-std::fabs(static_cast<double>(index) - 0.5 - centre) / scale)) + 1;
        }
    } else if (std::strcmp(family, "increasing") == 0) {
        for (index = 0; index < n; index += 1) {
            weights.keys[index] = index + 1;
        }
    } else if (std::strcmp(family, "uniform") == 0) {
        for (index = 0; index < n; index += 1) {
            weights.keys[index] = 1;
        }
        for (index = 0; index <= n; index += 1) {
            weights.gaps[index] = 1;
        }
    } else {
        for (index = 0; index < n; index += 1) {
            weights.keys[index] = small(random);
        }
        for (index = 0; index <= n; index += 1) {
            weights.gaps[index] = small(random) - 1;
        }
    }
    return weights;
}

double median(std::vector<double> values) {
    std::sort(values.begin(), values.end());
    return values[values.size() / 2];
}

} // namespace

// Usage: knuth_layouts <n> <repetitions> <family...>
int main(int argc, char** argv) {
    if (argc < 4) {
        std::fprintf(stderr, "usage: knuth_layouts <n> <repetitions> <family...>\n");
        return 64;
    }
    const std::size_t n = static_cast<std::size_t>(std::strtoull(argv[1], nullptr, 10));
    const std::size_t repetitions = static_cast<std::size_t>(std::strtoull(argv[2], nullptr, 10));
    std::mt19937_64 random(20261025);
    const char* const names[5] = {"library", "diagonal64", "diagonal128", "column64", "column128"};
    int argument = 0;
    for (argument = 3; argument < argc; argument += 1) {
        const SearchWeights weights = make(argv[argument], n, random);
        std::vector<double> times[5];
        std::vector<double> recovery_times[5];
        std::size_t bytes[5] = {0, 0, 0, 0, 0};
        Outcome reference;
        std::size_t repetition = 0;
        for (repetition = 0; repetition < repetitions; repetition += 1) {
            std::size_t step = 0;
            for (step = 0; step < 5; step += 1) {
                const std::size_t variant = (repetition + step) % 5;
                Outcome outcome;
                switch (variant) {
                case 0:
                    outcome = library(weights);
                    break;
                case 1:
                    outcome = diagonal<std::int64_t>(weights);
                    break;
                case 2:
                    outcome = diagonal<ExactCost>(weights);
                    break;
                case 3:
                    outcome = column<std::int64_t>(weights);
                    break;
                default:
                    outcome = column<ExactCost>(weights);
                    break;
                }
                if (reference.parent.empty()) {
                    reference = library(weights);
                }
                if (outcome.cost != reference.cost || outcome.parent != reference.parent) {
                    std::fprintf(stderr, "%s disagrees with the library on %s n=%zu\n", names[variant], argv[argument], n);
                    return 70;
                }
                times[variant].push_back(outcome.milliseconds);
                recovery_times[variant].push_back(outcome.recovery_milliseconds);
                bytes[variant] = outcome.bytes;
            }
        }
        std::size_t variant = 0;
        for (variant = 0; variant < 5; variant += 1) {
            std::printf("layout,%s,%zu,%s,%.3f,%.3f,%zu\n", argv[argument], n, names[variant], median(times[variant]),
                        median(recovery_times[variant]), bytes[variant]);
        }
        std::fflush(stdout);
    }
    return 0;
}
