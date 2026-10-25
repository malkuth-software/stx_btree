#pragma once

// Batched lookups (bbtree tree/batch.rs, latched/batch.rs; D53, D55). A
// lookup is a chain of dependent cache misses; one key's chain does not
// overlap the next one's. Here each key descends in its own lane: a small
// state machine that, before reading a line it may not have, prefetches it
// and yields, so that a round-robin over the lanes overlaps their waits.
//
// bbtree writes lanes as Rust async blocks polled by a private executor;
// the house style excludes coroutines, so each lane is an explicit state
// machine with the same stages:
//
//   before the lane reads    it prefetches, then yields
//   the root's search        the query's window (byte strings)
//   a chosen edge            that edge's line
//   a child internal node    the child's header line
//   its leaf                 the leaf's header line
//   a unique leaf candidate  the candidate's entry
//
// Prefetch hints are issued here and nowhere else in the library (D46).

#include "stx_btree/detail/inlining.hpp"
#include "stx_btree/detail/latched_tree.hpp"
#include "stx_btree/detail/node.hpp"
#include "stx_btree/detail/root_page.hpp"

#include <bit>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <new>
#include <optional>

namespace stx_btree::detail {

// The one place that issues a software prefetch: a read hint for the line
// a lane reads next. A no-op where the compiler has no hint.
class Prefetcher final {
public:
    STX_BTREE_ALWAYS_INLINE static void hint(const void* line) noexcept {
#if defined(__GNUC__) || defined(__clang__)
        __builtin_prefetch(line, 0, 3);
#else
        (void)line;
#endif
    }
};

// Lanes are run in groups of at most this many, one live bit each.
inline constexpr std::size_t lanes_per_round = 64;

enum class LaneState : std::uint8_t { start, route, follow, child, leaf, candidate, done };

// Whether a tree of this many entries is past about an L2 of leaf pages,
// below which lanes cost more than they save (bbtree Tree::batches).
template <typename Shape>
class BatchCutoff final {
public:
    [[nodiscard]] static bool batches(std::size_t length) noexcept {
        const std::size_t page_count = (1024 * 1024) / Shape::leaf.page_bytes;
        const std::size_t pages_in_l2 = page_count > 0 ? page_count : 1;
        const std::size_t entries_per_leaf = Shape::leaf.capacity * 7 / 10 + 1;
        return length >= pages_in_l2 * entries_per_leaf;
    }
};

// The unsync map's batched lookup.
template <typename Shape>
class UnsyncBatch final {
public:
    using Key = typename Shape::KeyType;
    using Value = typename Shape::ValueType;
    using Query = typename Shape::Query;
    using Traits = typename Shape::Traits;
    using Leaf = LeafNode<Shape>;
    using Internal = InternalNode<Shape>;

    struct Lane final {
        const Query* query = nullptr;
        std::byte* node = nullptr;
        std::size_t index = 0;
        LaneState state = LaneState::start;
    };

    // results[i] gets query i's value pointer or null. `root` is the tree's
    // root (non-null), an internal node.
    static void find_many(NodePointer root, const Query* queries, Value** results, std::size_t count) noexcept {
        std::size_t first = 0;
        while (first < count) {
            const std::size_t remaining = count - first;
            const std::size_t group = remaining < lanes_per_round ? remaining : lanes_per_round;
            run_group(root, queries + first, results + first, group);
            first += group;
        }
    }

private:
    static void run_group(NodePointer root, const Query* queries, Value** results, std::size_t count) noexcept {
        Lane lanes[lanes_per_round];
        std::uint64_t live = 0;
        std::size_t index = 0;
        for (index = 0; index < count; index += 1) {
            lanes[index] = Lane{.query = queries + index, .node = root.page(), .index = 0, .state = LaneState::start};
            results[index] = nullptr;
            live |= static_cast<std::uint64_t>(1) << index;
        }
        while (live != 0) {
            std::uint64_t round = live;
            while (round != 0) {
                const unsigned lane_index = static_cast<unsigned>(std::countr_zero(round));
                round &= round - 1;
                step(root, lanes[lane_index], results[lane_index]);
                if (lanes[lane_index].state == LaneState::done) {
                    live &= ~(static_cast<std::uint64_t>(1) << lane_index);
                }
            }
        }
    }

    // One stage; ends having prefetched what the next stage reads.
    STX_BTREE_ALWAYS_INLINE static void step(NodePointer root, Lane& lane, Value*& result) noexcept {
        const Query& query = *lane.query;
        switch (lane.state) {
        case LaneState::start: {
            const RootPage<Shape> root_page = RootPage<Shape>{root.page()};
            const std::size_t length = root_page.shared_length();
            if (length != 0 && Traits::compare_shared(query, root_page.shared_bytes(), length) != 0) {
                lane.state = LaneState::done;
                return;
            }
            lane.state = LaneState::route;
            return;
        }
        case LaneState::route: {
            const Internal node = Internal{lane.node};
            const typename Internal::SearchResult result_at = node.search(query);
            if (result_at.found) {
                const Leaf head_leaf = node.head_leaf(result_at.index);
                result = &head_leaf.head_value();
                lane.state = LaneState::done;
                return;
            }
            lane.index = result_at.index;
            Prefetcher::hint(node.edges() + result_at.index);
            lane.state = LaneState::follow;
            return;
        }
        case LaneState::follow: {
            const NodePointer child = Internal{lane.node}.edge(lane.index);
            lane.node = child.page();
            Prefetcher::hint(child.page());
            lane.state = child.is_leaf() ? LaneState::leaf : LaneState::route;
            return;
        }
        case LaneState::leaf: {
            const Leaf leaf = Leaf{lane.node};
            const EqualRange range = leaf.candidates(query);
            const std::size_t candidates = range.end - range.begin;
            if (candidates == 0) {
                lane.state = LaneState::done;
                return;
            }
            if (candidates == 1) {
                lane.index = range.begin;
                Prefetcher::hint(leaf.entry(range.begin + 1));
                lane.state = LaneState::candidate;
                return;
            }
            const std::size_t found = leaf.find(query);
            result = found == Leaf::absent ? nullptr : &leaf.value(found);
            lane.state = LaneState::done;
            return;
        }
        case LaneState::candidate: {
            const Leaf leaf = Leaf{lane.node};
            const std::size_t equal_length = leaf.prefix_length() + Leaf::width;
            const bool equal = Traits::equal_from(query, leaf.key(lane.index), equal_length);
            result = equal ? &leaf.value(lane.index) : nullptr;
            lane.state = LaneState::done;
            return;
        }
        case LaneState::child:
        case LaneState::done:
            break;
        }
        lane.state = LaneState::done;
    }
};

// The shared map's batched copies: lanes read internal nodes and their
// leaf's inline keys optimistically, and hold no latch across a yield
// (D55); a failed check starts the lane over from the root, alone.
template <typename Shape, typename Allocator>
class LatchedBatch final {
public:
    using Key = typename Shape::KeyType;
    using Value = typename Shape::ValueType;
    using Query = typename Shape::Query;
    using Traits = typename Shape::Traits;
    using Leaf = LeafNode<Shape>;
    using Internal = InternalNode<Shape>;
    using Tree = LatchedTree<Shape, Allocator>;

    struct Lane final {
        const Query* query = nullptr;
        std::byte* node = nullptr;
        std::byte* pending = nullptr;
        Version version;
        std::size_t index = 0;
        bool at_separator = false;
        bool at_root = true;
        LaneState state = LaneState::start;
    };

    static void get_many_copied(const Tree& tree, const Query* queries, std::optional<Value>* results, std::size_t count) noexcept {
        if (count < 2 || !batches(tree)) {
            std::size_t index = 0;
            for (index = 0; index < count; index += 1) {
                look_up_alone(tree, queries[index], results[index]);
            }
            return;
        }
        std::size_t first = 0;
        while (first < count) {
            const std::size_t remaining = count - first;
            const std::size_t group = remaining < lanes_per_round ? remaining : lanes_per_round;
            run_group(tree, queries + first, results + first, group);
            first += group;
        }
    }

    // Three internal levels or more, about an L2 of leaf pages (the shared
    // map keeps no length to estimate from).
    [[nodiscard]] static bool batches(const Tree& tree) noexcept {
        const NodePointer root = tree.load_root();
        if (root.is_null() || root.is_leaf()) {
            return false;
        }
        const Internal top = Internal::at(root);
        const Version version = NodeLatch::of(top.page).read_version();
        if (!(tree.load_root() == root)) {
            return false;
        }
        const NodePointer child = top.edge(0);
        if (!NodeLatch::of(top.page).is_unchanged(version) || child.is_null() || child.is_leaf()) {
            return false;
        }
        const NodePointer grandchild = Internal::at(child).edge(0);
        return !grandchild.is_null() && !grandchild.is_leaf();
    }

private:
    static void look_up_alone(const Tree& tree, const Query& query, std::optional<Value>& result) noexcept {
        alignas(Value) std::byte storage[sizeof(Value)];
        Value* const value = reinterpret_cast<Value*>(storage);
        if (tree.get_copied(query, value)) {
            result.emplace(*std::launder(value));
        }
    }

    static void run_group(const Tree& tree, const Query* queries, std::optional<Value>* results, std::size_t count) noexcept {
        Lane lanes[lanes_per_round];
        std::uint64_t live = 0;
        std::size_t index = 0;
        for (index = 0; index < count; index += 1) {
            lanes[index] = Lane{
                .query = queries + index, .node = nullptr, .pending = nullptr, .version = Version{},
                .index = 0, .at_separator = false, .at_root = true, .state = LaneState::start};
            live |= static_cast<std::uint64_t>(1) << index;
        }
        while (live != 0) {
            std::uint64_t round = live;
            while (round != 0) {
                const unsigned lane_index = static_cast<unsigned>(std::countr_zero(round));
                round &= round - 1;
                step(tree, lanes[lane_index], results[lane_index]);
                if (lanes[lane_index].state == LaneState::done) {
                    live &= ~(static_cast<std::uint64_t>(1) << lane_index);
                }
            }
        }
    }

    static void restart(Lane& lane) noexcept {
        lane.state = LaneState::start;
        lane.at_separator = false;
        lane.at_root = true;
    }

    STX_BTREE_ALWAYS_INLINE static void step(const Tree& tree, Lane& lane, std::optional<Value>& result) noexcept {
        const Query& query = *lane.query;
        switch (lane.state) {
        case LaneState::start: {
            const NodePointer root = tree.load_root();
            if (root.is_leaf()) {
                look_up_alone(tree, query, result);
                lane.state = LaneState::done;
                return;
            }
            const Internal node = Internal::at(root);
            const Version version = NodeLatch::of(node.page).read_version();
            if (!(tree.load_root() == root)) {
                return;
            }
            SharedPrefixBytes shared;
            RootPage<Shape>{root.page()}.copy_shared_prefix(&shared);
            if (Tree::place_against(shared, query) != DescentOutcome::inside) {
                if (NodeLatch::of(node.page).is_unchanged(version)) {
                    lane.state = LaneState::done;
                }
                return;
            }
            lane.node = node.page;
            lane.version = version;
            lane.state = LaneState::route;
            return;
        }
        case LaneState::route: {
            const Internal node = Internal{lane.node};
            Routed routed;
            if (!Tree::route_racing(node, lane.version, query, &routed)) {
                restart(lane);
                return;
            }
            lane.at_separator = lane.at_separator || routed.at_separator;
            lane.index = routed.edge;
            Prefetcher::hint(node.edges() + routed.edge);
            lane.state = LaneState::follow;
            return;
        }
        case LaneState::follow: {
            const Internal node = Internal{lane.node};
            const NodePointer child = node.edge(lane.index);
            if (child.is_null()) {
                restart(lane);
                return;
            }
            if (lane.at_root && !NodeLatch::of(node.page).is_unchanged(lane.version)) {
                restart(lane);
                return;
            }
            lane.at_root = false;
            lane.pending = child.page();
            Prefetcher::hint(child.page());
            lane.state = child.is_leaf() ? LaneState::leaf : LaneState::child;
            return;
        }
        case LaneState::child: {
            const Version child_version = NodeLatch::of(lane.pending).read_version();
            if (!NodeLatch::of(lane.node).is_unchanged(lane.version)) {
                restart(lane);
                return;
            }
            lane.node = lane.pending;
            lane.version = child_version;
            lane.state = LaneState::route;
            return;
        }
        case LaneState::leaf: {
            const Version leaf_version = NodeLatch::of(lane.pending).read_version();
            if (!NodeLatch::of(lane.node).is_unchanged(lane.version)) {
                restart(lane);
                return;
            }
            lane.node = lane.pending;
            lane.version = leaf_version;
            const Leaf leaf = Leaf{lane.node};
            if (lane.at_separator) {
                settle_latched(tree, lane, result);
                return;
            }
            const std::size_t racing_length = leaf.length();
            const std::size_t length = racing_length < Leaf::capacity ? racing_length : Leaf::capacity;
            const InlineWord word = Shape::window_word(query, leaf.prefix_length());
            const EqualRange range = Leaf::Count::equal_range(leaf.inline_keys(), Leaf::slot_of(word), length);
            const std::size_t candidates = range.end - range.begin;
            if (candidates == 0) {
                if (NodeLatch::of(leaf.page).is_unchanged(lane.version)) {
                    lane.state = LaneState::done;
                } else {
                    restart(lane);
                }
                return;
            }
            if (candidates == 1) {
                lane.index = range.begin;
                Prefetcher::hint(leaf.entry(range.begin + 1));
                lane.state = LaneState::candidate;
                return;
            }
            settle_latched(tree, lane, result);
            return;
        }
        case LaneState::candidate: {
            const Leaf leaf = Leaf{lane.node};
            if constexpr (Traits::orders_by_own_bytes) {
                alignas(Key) std::byte key_copy[sizeof(Key)];
                alignas(Value) std::byte value_copy[sizeof(Value)];
                std::memcpy(key_copy, leaf.entry(lane.index + 1), sizeof(Key));
                std::memcpy(value_copy, leaf.entry(lane.index + 1) + Shape::leaf.value_offset, sizeof(Value));
                if (!NodeLatch::of(leaf.page).is_unchanged(lane.version)) {
                    restart(lane);
                    return;
                }
                const Key* stored = std::launder(reinterpret_cast<const Key*>(key_copy));
                if (Traits::compare_from(query, *stored, 0) == 0) {
                    result.emplace(*std::launder(reinterpret_cast<const Value*>(value_copy)));
                }
                lane.state = LaneState::done;
                return;
            } else {
                settle_latched(tree, lane, result);
                return;
            }
        }
        case LaneState::done:
            break;
        }
        lane.state = LaneState::done;
    }

    // Settles the lane with its leaf latched shared at the version it read;
    // a leaf that changed starts the lane over.
    static void settle_latched(const Tree& tree, Lane& lane, std::optional<Value>& result) noexcept {
        (void)tree;
        const Query& query = *lane.query;
        const Leaf leaf = Leaf{lane.node};
        const NodeLatch latch = NodeLatch::of(leaf.page);
        latch.lock_shared();
        if (!latch.is_unchanged(lane.version)) {
            latch.unlock_shared();
            restart(lane);
            return;
        }
        if (lane.at_separator) {
            if (!Tree::is_head(leaf, query)) {
                latch.unlock_shared();
                restart(lane);
                return;
            }
            result.emplace(leaf.head_value());
            latch.unlock_shared();
            lane.state = LaneState::done;
            return;
        }
        const std::size_t found = leaf.find(query);
        if (found != Leaf::absent) {
            result.emplace(leaf.value(found));
        }
        latch.unlock_shared();
        lane.state = LaneState::done;
    }
};

} // namespace stx_btree::detail
