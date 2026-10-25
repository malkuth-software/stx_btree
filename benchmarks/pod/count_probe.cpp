// The node count kernels at the capacities the maps instantiate, as
// standalone functions, so that each compiler's code for them can be read
// side by side (benchmarks/pod/diagnose.sh emits the assembly).

#include "stx_btree/detail/vector_count.hpp"

#include <cstddef>
#include <cstdint>

using stx_btree::detail::EqualRange;
using stx_btree::detail::InlineKeyCount;

extern "C" {

// u64 keys: two-byte windows, leaf 55 slots, internal 49.
EqualRange probe_u16_leaf55(const std::uint16_t* slots, std::uint16_t target, std::size_t length) {
    return InlineKeyCount<std::uint16_t, 55>::equal_range(slots, target, length);
}

EqualRange probe_u16_internal49(const std::uint16_t* slots, std::uint16_t target, std::size_t length) {
    return InlineKeyCount<std::uint16_t, 49>::equal_range(slots, target, length);
}

// String keys: four-byte internal windows (41), eight-byte leaf windows (24).
EqualRange probe_u32_internal41(const std::uint32_t* slots, std::uint32_t target, std::size_t length) {
    return InlineKeyCount<std::uint32_t, 41>::equal_range(slots, target, length);
}

EqualRange probe_u64_leaf24(const std::uint64_t* slots, std::uint64_t target, std::size_t length) {
    return InlineKeyCount<std::uint64_t, 24>::equal_range(slots, target, length);
}

}
