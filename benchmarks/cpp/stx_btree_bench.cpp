// Single-thread and multi-thread benchmarks of the C++ maps, matched by
// benchmarks/rust (bbtree). Usage:
//
//   stx_btree_bench <unsync|shared|threads> <u64|uuid|str16|url> <size> <operations> [threads]
//
// "threads" runs the shared map from several threads: operations are per
// thread, the reported time per operation is wall time over all of them.
//
// One process builds one map and runs the workloads in a fixed order,
// printing CSV: implementation, map, key, size, threads, workload,
// operations, nanoseconds per operation, checksum. Checksums equal the Rust
// program's for the same arguments.

#if defined(STX_BTREE_BENCH_ARENA)
#include "../pod/arena_page_allocator.hpp"
#endif
#include "stx_btree/bbtree_map.hpp"
#include "stx_btree/unsync_map.hpp"
#include "workload.hpp"

#include <array>
#include <atomic>
#include <chrono>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <optional>
#include <string>
#include <thread>
#include <vector>

namespace {

using stx_btree_bench::KeySet;
using stx_btree_bench::Uuid;

class Clock final {
public:
    [[nodiscard]] static std::uint64_t now_ns() noexcept {
        const std::chrono::steady_clock::time_point point = std::chrono::steady_clock::now();
        const std::chrono::nanoseconds since = std::chrono::duration_cast<std::chrono::nanoseconds>(point.time_since_epoch());
        return static_cast<std::uint64_t>(since.count());
    }
};

struct RunLabel final {
    const char* map = "";
    const char* key = "";
    std::uint64_t size = 0;
    std::uint64_t threads = 1;
};

class Report final {
public:
    static void line(const RunLabel& label, const char* workload, std::uint64_t operations, std::uint64_t elapsed_ns, std::uint64_t checksum) {
        const double per_operation = operations == 0 ? 0.0 : static_cast<double>(elapsed_ns) / static_cast<double>(operations);
        std::printf("cpp,%s,%s,%llu,%llu,%s,%llu,%.2f,%llu\n", label.map, label.key,
                    static_cast<unsigned long long>(label.size), static_cast<unsigned long long>(label.threads),
                    workload, static_cast<unsigned long long>(operations), per_operation,
                    static_cast<unsigned long long>(checksum));
        std::fflush(stdout);
    }
};

// Key families: a key from an index, an ordered key from a rank, and the
// lookup view of a key.
struct U64Keys final {
    using Key = std::uint64_t;
    static constexpr const char* name = "u64";
    [[nodiscard]] static Key make(std::uint64_t index) {
        return KeySet::u64_key(index);
    }
    [[nodiscard]] static Key ordered(std::uint64_t rank) {
        return KeySet::u64_ordered(rank);
    }
};
struct UuidKeys final {
    using Key = Uuid;
    static constexpr const char* name = "uuid";
    [[nodiscard]] static Key make(std::uint64_t index) {
        return KeySet::uuid_key(index);
    }
    [[nodiscard]] static Key ordered(std::uint64_t rank) {
        return KeySet::uuid_ordered(rank);
    }
};
struct Str16Keys final {
    using Key = std::string;
    static constexpr const char* name = "str16";
    [[nodiscard]] static Key make(std::uint64_t index) {
        return KeySet::str16_key(index);
    }
    [[nodiscard]] static Key ordered(std::uint64_t rank) {
        return KeySet::decimal_ordered(rank);
    }
};
struct UrlKeys final {
    using Key = std::string;
    static constexpr const char* name = "url";
    [[nodiscard]] static Key make(std::uint64_t index) {
        return KeySet::url_key(index);
    }
    [[nodiscard]] static Key ordered(std::uint64_t rank) {
        return KeySet::decimal_ordered(rank);
    }
};

// The unsync map's page allocator: the library's default, or with
// -DSTX_BTREE_BENCH_ARENA the pooled arena of benchmarks/pod (an experiment
// on the cost of the system allocator; never the reported default).
#if defined(STX_BTREE_BENCH_ARENA)
using UnsyncPageAllocator = stx_btree_bench::ArenaPageAllocator;
#else
using UnsyncPageAllocator = stx_btree::GlobalPageAllocator;
#endif

template <typename Family>
class UnsyncBench final {
public:
    using Key = typename Family::Key;
    using Map = stx_btree::unsync::BBTreeMap<Key, std::uint64_t, UnsyncPageAllocator>;
    using Traits = stx_btree::InlineKeyTraits<Key>;

    static void run(std::uint64_t size, std::uint64_t operations) {
        const RunLabel label{.map = "unsync", .key = Family::name, .size = size, .threads = 1};
        // Keys are made before timing, so only the map's work is timed.
        std::vector<Key> keys;
        keys.reserve(size);
        std::uint64_t index = 0;
        for (index = 0; index < size; index += 1) {
            keys.push_back(Family::make(index));
        }
        std::vector<Key> hits;
        std::vector<Key> misses;
        hits.reserve(operations);
        misses.reserve(operations);
        for (index = 0; index < operations; index += 1) {
            const std::uint64_t chosen = KeySet::query_index(index, size);
            hits.push_back(keys[chosen]);
            misses.push_back(Family::make(size + chosen));
        }

        Map map;
        std::uint64_t start = Clock::now_ns();
        for (index = 0; index < size; index += 1) {
            map.insert(keys[index], index);
        }
        std::uint64_t elapsed = Clock::now_ns() - start;
        Report::line(label, "insert_random", size, elapsed, map.size());

        std::uint64_t checksum = 0;
        start = Clock::now_ns();
        for (index = 0; index < operations; index += 1) {
            const std::uint64_t* value = map.find(Traits::query_of(hits[index]));
            checksum += value == nullptr ? 0 : *value;
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "get_hit", operations, elapsed, checksum);

        checksum = 0;
        start = Clock::now_ns();
        for (index = 0; index < operations; index += 1) {
            const std::uint64_t* value = map.find(Traits::query_of(misses[index]));
            checksum += value == nullptr ? 1 : *value;
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "get_miss", operations, elapsed, checksum);

        constexpr std::size_t batch = 64;
        const std::uint64_t batched = operations - operations % batch;
        checksum = 0;
        start = Clock::now_ns();
        std::array<typename Traits::Query, batch> queries;
        for (index = 0; index < batched; index += batch) {
            std::size_t lane = 0;
            for (lane = 0; lane < batch; lane += 1) {
                queries[lane] = Traits::query_of(hits[index + lane]);
            }
            const std::array<std::uint64_t*, batch> values = map.get_many(queries);
            for (lane = 0; lane < batch; lane += 1) {
                checksum += values[lane] == nullptr ? 0 : *values[lane];
            }
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "get_hit_batched", batched, elapsed, checksum);

        const std::uint64_t scans = operations / 16;
        checksum = 0;
        start = Clock::now_ns();
        for (index = 0; index < scans; index += 1) {
            typename Map::Iterator iterator = map.lower_bound(Traits::query_of(hits[index]));
            const typename Map::Iterator end = map.end();
            std::uint64_t step = 0;
            for (step = 0; step < 64 && iterator != end; step += 1) {
                checksum += (*iterator).value;
                ++iterator;
            }
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "range64", scans, elapsed, checksum);

        checksum = 0;
        start = Clock::now_ns();
        typename Map::Iterator walk = map.begin();
        const typename Map::Iterator walk_end = map.end();
        while (walk != walk_end) {
            checksum += (*walk).value;
            ++walk;
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "iterate", size, elapsed, checksum);

        const std::uint64_t removals = operations < size ? operations : size;
        checksum = 0;
        start = Clock::now_ns();
        for (index = 0; index < removals; index += 1) {
            const std::uint64_t chosen = KeySet::removal_index(index, size);
            const std::optional<typename Map::Entry> removed = map.remove(Traits::query_of(keys[chosen]));
            checksum += removed.has_value() ? (*removed).value : 0;
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "remove_random", removals, elapsed, checksum);

        std::vector<Key> ordered;
        ordered.reserve(size);
        for (index = 0; index < size; index += 1) {
            ordered.push_back(Family::ordered(index));
        }
        Map sequential;
        start = Clock::now_ns();
        for (index = 0; index < size; index += 1) {
            sequential.insert(ordered[index], index);
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "insert_sequential", size, elapsed, sequential.size());

        // A fresh map built 16 entries a call (bbtree's insert batches).
        const std::uint64_t whole = size - size % 16;
        Map batched_map;
        start = Clock::now_ns();
        for (index = 0; index < whole; index += 16) {
            std::array<typename Map::Entry, 16> entries;
            std::size_t lane = 0;
            for (lane = 0; lane < 16; lane += 1) {
                entries[lane] = typename Map::Entry{keys[index + lane], index + lane};
            }
            batched_map.insert_many(std::move(entries));
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "insert_random_batched", whole, elapsed, batched_map.size());
    }
};


// Sums a scan's values, up to 100 entries.
template <typename Key>
struct SumHundred final {
    std::uint64_t* checksum = nullptr;
    std::uint64_t visited = 0;
    bool operator()(const Key&, const std::uint64_t& value) {
        *checksum += value;
        visited += 1;
        return visited < 100;
    }
};

template <typename Key>
struct AddOne final {
    void operator()(const Key&, std::uint64_t& value) const noexcept {
        value += 1;
    }
};

// The shared map: one thread through every workload, then threads.
template <typename Family>
class SharedBench final {
public:
    using Key = typename Family::Key;
    using Map = stx_btree::BBTreeMap<Key, std::uint64_t>;
    using Traits = stx_btree::InlineKeyTraits<Key>;
    using Query = typename Traits::Query;
    static constexpr std::size_t batch = 64;

    static void run(std::uint64_t size, std::uint64_t operations) {
        const RunLabel label{.map = "shared", .key = Family::name, .size = size, .threads = 1};
        std::vector<Key> keys;
        keys.reserve(size);
        std::uint64_t index = 0;
        for (index = 0; index < size; index += 1) {
            keys.push_back(Family::make(index));
        }
        std::vector<Key> hits;
        std::vector<Key> misses;
        hits.reserve(operations);
        misses.reserve(operations);
        for (index = 0; index < operations; index += 1) {
            const std::uint64_t chosen = KeySet::query_index(index, size);
            hits.push_back(keys[chosen]);
            misses.push_back(Family::make(size + chosen));
        }

        Map map;
        std::uint64_t start = Clock::now_ns();
        for (index = 0; index < size; index += 1) {
            map.insert(keys[index], index);
        }
        std::uint64_t elapsed = Clock::now_ns() - start;
        Report::line(label, "insert_random", size, elapsed, size);

        std::uint64_t checksum = 0;
        start = Clock::now_ns();
        for (index = 0; index < operations; index += 1) {
            const std::optional<std::uint64_t> value = map.get_copied(Traits::query_of(hits[index]));
            checksum += value.has_value() ? *value : 0;
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "get_hit", operations, elapsed, checksum);

        checksum = 0;
        start = Clock::now_ns();
        for (index = 0; index < operations; index += 1) {
            const std::optional<std::uint64_t> value = map.get_copied(Traits::query_of(misses[index]));
            checksum += value.has_value() ? *value : 1;
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "get_miss", operations, elapsed, checksum);

        const std::uint64_t batched = operations - operations % batch;
        checksum = 0;
        start = Clock::now_ns();
        std::array<Query, batch> queries;
        for (index = 0; index < batched; index += batch) {
            std::size_t lane = 0;
            for (lane = 0; lane < batch; lane += 1) {
                queries[lane] = Traits::query_of(hits[index + lane]);
            }
            const std::array<std::optional<std::uint64_t>, batch> values = map.get_many_copied(queries);
            for (lane = 0; lane < batch; lane += 1) {
                checksum += values[lane].has_value() ? *values[lane] : 0;
            }
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "get_hit_batched", batched, elapsed, checksum);

        const std::uint64_t scans = operations / 16;
        checksum = 0;
        start = Clock::now_ns();
        for (index = 0; index < scans; index += 1) {
            const Query from = Traits::query_of(hits[index]);
            SumHundred<Key> sum{&checksum, 0};
            const typename Map::Bound low{&from, true};
            const typename Map::Bound unbounded{nullptr, true};
            map.scan(low, unbounded, sum);
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "scan100", scans, elapsed, checksum);

        checksum = 0;
        start = Clock::now_ns();
        for (index = 0; index < operations; index += 1) {
            const bool found = map.update(Traits::query_of(hits[index]), AddOne<Key>{});
            checksum += found ? 1 : 0;
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "update", operations, elapsed, checksum);

        const std::uint64_t removals = operations < size ? operations : size;
        checksum = 0;
        start = Clock::now_ns();
        for (index = 0; index < removals; index += 1) {
            const std::uint64_t chosen = KeySet::removal_index(index, size);
            const std::optional<typename Map::Entry> removed = map.remove(Traits::query_of(keys[chosen]));
            checksum += removed.has_value() ? 1 : 0;
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "remove_random", removals, elapsed, checksum);

        std::vector<Key> ordered;
        ordered.reserve(size);
        for (index = 0; index < size; index += 1) {
            ordered.push_back(Family::ordered(index));
        }
        Map sequential;
        start = Clock::now_ns();
        for (index = 0; index < size; index += 1) {
            sequential.insert(ordered[index], index);
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "insert_sequential", size, elapsed, size);

        const std::uint64_t whole = size - size % 16;
        Map batched_map;
        start = Clock::now_ns();
        for (index = 0; index < whole; index += 16) {
            std::array<typename Map::Entry, 16> entries;
            std::size_t lane = 0;
            for (lane = 0; lane < 16; lane += 1) {
                entries[lane] = typename Map::Entry{keys[index + lane], index + lane};
            }
            batched_map.insert_many(std::move(entries));
        }
        elapsed = Clock::now_ns() - start;
        Report::line(label, "insert_random_batched", whole, elapsed, whole);
    }

    // --- Threads ------------------------------------------------------------

    enum class ThreadWork : std::uint8_t { insert, get_half, get_half_batched, mixed };

    struct Worker final {
        Map* map = nullptr;
        const std::vector<Key>* keys = nullptr;
        const std::vector<Key>* absent = nullptr;
        std::uint64_t first = 0;
        std::uint64_t count = 0;
        std::uint64_t size = 0;
        ThreadWork work = ThreadWork::get_half;
        std::atomic<bool>* go = nullptr;
        std::uint64_t* checksum = nullptr;
        void operator()() const {
            while (!(*go).load(std::memory_order_acquire)) {
                std::this_thread::yield();
            }
            std::uint64_t sum = 0;
            std::uint64_t j = 0;
            if (work == ThreadWork::insert) {
                for (j = first; j < first + count; j += 1) {
                    (*map).insert((*keys)[j], j);
                }
            } else if (work == ThreadWork::get_half) {
                for (j = first; j < first + count; j += 1) {
                    const std::uint64_t chosen = KeySet::query_index(j, size);
                    const Key& key = (j % 2 == 0) ? (*keys)[chosen] : (*absent)[chosen];
                    const std::optional<std::uint64_t> value = (*map).get_copied(Traits::query_of(key));
                    sum += value.has_value() ? *value : 1;
                }
            } else if (work == ThreadWork::get_half_batched) {
                std::array<Query, batch> queries;
                for (j = first; j + batch <= first + count; j += batch) {
                    std::size_t lane = 0;
                    for (lane = 0; lane < batch; lane += 1) {
                        const std::uint64_t at = j + lane;
                        const std::uint64_t chosen = KeySet::query_index(at, size);
                        const Key& key = (at % 2 == 0) ? (*keys)[chosen] : (*absent)[chosen];
                        queries[lane] = Traits::query_of(key);
                    }
                    const std::array<std::optional<std::uint64_t>, batch> values = (*map).get_many_copied(queries);
                    for (lane = 0; lane < batch; lane += 1) {
                        sum += values[lane].has_value() ? *values[lane] : 1;
                    }
                }
            } else {
                for (j = first; j < first + count; j += 1) {
                    const std::uint64_t chosen = KeySet::query_index(j, size);
                    const Query query = Traits::query_of((*keys)[chosen]);
                    if (j % 10 == 0) {
                        const bool found = (*map).update(query, AddOne<Key>{});
                        sum += found ? 1 : 0;
                    } else {
                        const std::optional<std::uint64_t> value = (*map).get_copied(query);
                        sum += value.has_value() ? 1 : 0;
                    }
                }
            }
            *checksum = sum;
        }
    };

    static std::uint64_t run_workers(Map& map, const std::vector<Key>& keys, const std::vector<Key>& absent,
                                     std::uint64_t size, std::uint64_t per_thread, std::uint64_t threads,
                                     ThreadWork work, std::uint64_t* checksum) {
        std::atomic<bool> go{false};
        std::vector<std::uint64_t> sums(threads, 0);
        std::vector<std::thread> running;
        std::uint64_t thread_index = 0;
        for (thread_index = 0; thread_index < threads; thread_index += 1) {
            running.emplace_back(Worker{&map, &keys, &absent, thread_index * per_thread, per_thread, size, work, &go, &sums[thread_index]});
        }
        const std::uint64_t start = Clock::now_ns();
        go.store(true, std::memory_order_release);
        for (thread_index = 0; thread_index < threads; thread_index += 1) {
            running[thread_index].join();
        }
        const std::uint64_t elapsed = Clock::now_ns() - start;
        std::uint64_t total = 0;
        for (thread_index = 0; thread_index < threads; thread_index += 1) {
            total += sums[thread_index];
        }
        *checksum = total;
        return elapsed;
    }

    static void run_threads(std::uint64_t size, std::uint64_t operations, std::uint64_t threads) {
        const RunLabel label{.map = "shared", .key = Family::name, .size = size, .threads = threads};
        std::vector<Key> keys;
        std::vector<Key> absent;
        keys.reserve(size);
        absent.reserve(size);
        std::uint64_t index = 0;
        for (index = 0; index < size; index += 1) {
            keys.push_back(Family::make(index));
            absent.push_back(Family::make(size + index));
        }
        Map map;
        std::uint64_t checksum = 0;
        const std::uint64_t share = size / threads;
        std::uint64_t elapsed = run_workers(map, keys, absent, size, share, threads, ThreadWork::insert, &checksum);
        // A remainder the shares left out goes in untimed.
        for (index = share * threads; index < size; index += 1) {
            map.insert(keys[index], index);
        }
        Report::line(label, "mt_insert", share * threads, elapsed, 0);
        const std::uint64_t per_thread = operations - operations % batch;
        elapsed = run_workers(map, keys, absent, size, per_thread, threads, ThreadWork::get_half, &checksum);
        Report::line(label, "mt_get_half", per_thread * threads, elapsed, checksum);
        elapsed = run_workers(map, keys, absent, size, per_thread, threads, ThreadWork::get_half_batched, &checksum);
        Report::line(label, "mt_get_half_batched", per_thread * threads, elapsed, checksum);
        elapsed = run_workers(map, keys, absent, size, per_thread, threads, ThreadWork::mixed, &checksum);
        Report::line(label, "mt_mixed_90_10", per_thread * threads, elapsed, checksum);
    }
};

template <typename Family>
int dispatch_map(const char* map_kind, std::uint64_t size, std::uint64_t operations, std::uint64_t threads) {
    if (std::strcmp(map_kind, "unsync") == 0) {
        UnsyncBench<Family>::run(size, operations);
        return 0;
    }
    if (std::strcmp(map_kind, "shared") == 0) {
        SharedBench<Family>::run(size, operations);
        return 0;
    }
    if (std::strcmp(map_kind, "threads") == 0) {
        SharedBench<Family>::run_threads(size, operations, threads);
        return 0;
    }
    std::fprintf(stderr, "unknown map %s\n", map_kind);
    return 2;
}

} // namespace

int main(int argument_count, char** arguments) {
    if (argument_count < 5) {
        std::fprintf(stderr, "usage: %s <unsync|shared|threads> <u64|uuid|str16|url> <size> <operations> [threads]\n", arguments[0]);
        return 2;
    }
    const char* map_kind = arguments[1];
    const char* key_kind = arguments[2];
    const std::uint64_t size = std::strtoull(arguments[3], nullptr, 10);
    const std::uint64_t operations = std::strtoull(arguments[4], nullptr, 10);
    const std::uint64_t threads = argument_count > 5 ? std::strtoull(arguments[5], nullptr, 10) : 1;
    if (std::strcmp(key_kind, "u64") == 0) {
        return dispatch_map<U64Keys>(map_kind, size, operations, threads);
    }
    if (std::strcmp(key_kind, "uuid") == 0) {
        return dispatch_map<UuidKeys>(map_kind, size, operations, threads);
    }
    if (std::strcmp(key_kind, "str16") == 0) {
        return dispatch_map<Str16Keys>(map_kind, size, operations, threads);
    }
    if (std::strcmp(key_kind, "url") == 0) {
        return dispatch_map<UrlKeys>(map_kind, size, operations, threads);
    }
    std::fprintf(stderr, "unknown key %s\n", key_kind);
    return 2;
}
