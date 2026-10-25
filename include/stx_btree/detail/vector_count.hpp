#pragma once

// The node search: count the inline keys below a target and those equal to
// it, over every slot up to the kind's capacity, then clip to the live
// length (bbtree 04-inline-key.md Q6, D56). Slots past the length hold the
// greatest inline key (all ones), so the counts are exact there without a
// mask per slot; a target of all ones may count padding as equal, which the
// clip removes.
//
// bbtree counts in explicit AVX-512 and NEON, because LLVM's own count
// widened each comparison (or, fully unrolled, packed it into a bit mask and
// counted bits). Here one form serves every 128-bit target: GCC/Clang vector
// extensions over sixteen-byte lane groups, which compile to compare and
// subtract per group (NEON cmhi/cmeq/sub; SSE2 compares) with accumulators of
// the slot's width. A capacity that is not a multiple of the group ends with
// one overlapping group whose already-counted lanes are masked off. Other
// compilers take the plain loop, which gives the same answer.

#include "stx_btree/detail/inlining.hpp"

#include <cstddef>
#include <cstdint>
#include <cstring>

namespace stx_btree::detail {

struct EqualRange final {
    std::size_t begin = 0;
    std::size_t end = 0;
};

template <typename Slot, std::size_t Capacity>
class InlineKeyCount final {
public:
    static constexpr std::size_t group_lanes = 16 / sizeof(Slot);
    static constexpr std::size_t full_groups = Capacity / group_lanes;
    static constexpr std::size_t tail_lanes = Capacity % group_lanes;

    static_assert(Capacity >= group_lanes, "a node holds at least one lane group");
    static_assert(Capacity < (static_cast<std::size_t>(1) << 15),
                  "per-lane counts stay within the slot width");

    // Live keys [begin, end) whose inline keys equal target; begin is the
    // number below it. `slots` holds Capacity slots.
    [[nodiscard]] STX_BTREE_ALWAYS_INLINE static EqualRange equal_range(const Slot* slots, Slot target, std::size_t length) noexcept {
        std::size_t below = 0;
        std::size_t equal = 0;
        count(slots, target, &below, &equal);
        const std::size_t begin = below < length ? below : length;
        const std::size_t through = begin + equal;
        const std::size_t end = through < length ? through : length;
        return EqualRange{.begin = begin, .end = end};
    }

private:
#if defined(__GNUC__) || defined(__clang__)
    typedef Slot Lanes __attribute__((vector_size(16)));

    [[nodiscard]] static Lanes tail_mask() noexcept {
        Lanes keep = {};
        std::size_t lane = 0;
        for (lane = group_lanes - tail_lanes; lane < group_lanes; lane += 1) {
            keep[lane] = static_cast<Slot>(~static_cast<Slot>(0));
        }
        return keep;
    }

    STX_BTREE_ALWAYS_INLINE static void count(const Slot* slots, Slot target, std::size_t* below_out, std::size_t* equal_out) noexcept {
        const Lanes broadcast = Lanes{} + target;
        Lanes below = {};
        Lanes equal = {};
        std::size_t group = 0;
        for (group = 0; group < full_groups; group += 1) {
            Lanes lanes;
            std::memcpy(&lanes, slots + group * group_lanes, sizeof(Lanes));
            // A true comparison is all ones: subtracting it counts one.
            below -= __builtin_convertvector(lanes < broadcast, Lanes);
            equal -= __builtin_convertvector(lanes == broadcast, Lanes);
        }
        if constexpr (tail_lanes != 0) {
            const Lanes keep = tail_mask();
            Lanes lanes;
            std::memcpy(&lanes, slots + (Capacity - group_lanes), sizeof(Lanes));
            below -= __builtin_convertvector(lanes < broadcast, Lanes) & keep;
            equal -= __builtin_convertvector(lanes == broadcast, Lanes) & keep;
        }
        Slot below_total = 0;
        Slot equal_total = 0;
        std::size_t lane = 0;
        for (lane = 0; lane < group_lanes; lane += 1) {
            below_total = static_cast<Slot>(below_total + below[lane]);
            equal_total = static_cast<Slot>(equal_total + equal[lane]);
        }
        *below_out = below_total;
        *equal_out = equal_total;
    }
#else
    static void count(const Slot* slots, Slot target, std::size_t* below_out, std::size_t* equal_out) noexcept {
        std::size_t below = 0;
        std::size_t equal = 0;
        std::size_t index = 0;
        for (index = 0; index < Capacity; index += 1) {
            below += slots[index] < target ? 1 : 0;
            equal += slots[index] == target ? 1 : 0;
        }
        *below_out = below;
        *equal_out = equal;
    }
#endif
};

} // namespace stx_btree::detail
