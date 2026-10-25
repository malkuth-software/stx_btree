// The unsync map's lookup as one outlined function per key type, so that
// each compiler's descent can be read in full (benchmarks/pod/diagnose.sh).

#include "stx_btree/unsync_map.hpp"

#include <cstdint>
#include <string>
#include <string_view>

using U64Map = stx_btree::unsync::BBTreeMap<std::uint64_t, std::uint64_t>;
using StringMap = stx_btree::unsync::BBTreeMap<std::string, std::uint64_t>;

__attribute__((noinline)) const std::uint64_t* probe_find_u64(const U64Map& map, std::uint64_t key) {
    return map.find(key);
}

__attribute__((noinline)) const std::uint64_t* probe_find_string(const StringMap& map, std::string_view key) {
    return map.find(key);
}
