// A key type of one's own: an order key of (customer, order), encoded as
// both fields' big-endian bytes, one after the other, so that the encoding
// orders as the keys do (bbtree's InlineKey contract).

#include "stx_btree/bbtree_map.hpp"
#include "stx_btree/unsync_map.hpp"

#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <optional>

struct OrderKey final {
    std::uint32_t customer = 0;
    std::uint32_t order = 0;
};

template <>
struct stx_btree::InlineKeyTraits<OrderKey> final : stx_btree::InlineKeyWindows<stx_btree::InlineKeyTraits<OrderKey>> {
    using Key = OrderKey;
    using Query = OrderKey;
    static constexpr stx_btree::InlineWidth leaf_width = stx_btree::InlineWidth::two;
    static constexpr stx_btree::InlineWidth internal_width = stx_btree::InlineWidth::two;
    static constexpr bool has_hash_tags = false;
    // The key holds its own bytes: a shared map may copy it racing a writer
    // and compare the copy after checking the leaf's version.
    static constexpr bool orders_by_own_bytes = true;
    static constexpr bool tag_is_length = false;
    static constexpr std::size_t encoded_bytes = 8;

    [[nodiscard]] static Query query_of(const Key& key) noexcept {
        return key;
    }
    [[nodiscard]] static stx_btree::InlineWord encoding(const Query& query) noexcept {
        const stx_btree::InlineWord high = query.customer;
        return (high << 32) | query.order;
    }
    // Bytes [offset, offset + 8) of the encoding, zero past its end.
    [[nodiscard]] static stx_btree::InlineWord window(const Query& query, std::size_t offset) noexcept {
        if (offset >= encoded_bytes) {
            return 0;
        }
        return encoding(query) << (8 * offset);
    }
    [[nodiscard]] static int compare_from(const Query& query, const Key& stored, std::size_t) noexcept {
        const stx_btree::InlineWord left = encoding(query);
        const stx_btree::InlineWord right = encoding(stored);
        if (left == right) {
            return 0;
        }
        return left < right ? -1 : 1;
    }
    [[nodiscard]] static bool equal_from(const Query& query, const Key& stored, std::size_t) noexcept {
        return encoding(query) == encoding(stored);
    }
    [[nodiscard]] static std::uint8_t hash_tag(const Query&) noexcept {
        return 0;
    }
    [[nodiscard]] static std::size_t encoded_length(const Query&) noexcept {
        return encoded_bytes;
    }
    [[nodiscard]] static std::size_t common_prefix_length(const Key& a, const Key& b) noexcept {
        return common_prefix_by_windows(a, b, encoded_bytes);
    }
    [[nodiscard]] static std::size_t leading_bytes(const Query& query, std::uint8_t* out, std::size_t capacity) noexcept {
        return leading_bytes_by_windows(query, encoded_bytes, out, capacity);
    }
    [[nodiscard]] static std::size_t shared_length(const Query& query, const std::uint8_t* bytes, std::size_t length) noexcept {
        return shared_length_by_windows(query, bytes, length);
    }
    [[nodiscard]] static int compare_shared(const Query& query, const std::uint8_t* bytes, std::size_t length) noexcept {
        return compare_shared_by_windows(query, bytes, length);
    }
};

int main() {
    stx_btree::unsync::BBTreeMap<OrderKey, std::uint64_t> totals;
    stx_btree::BBTreeMap<OrderKey, std::uint64_t> shared;
    std::uint32_t customer = 0;
    for (customer = 0; customer < 2000; customer += 1) {
        std::uint32_t order = 0;
        for (order = 0; order < 30; order += 1) {
            const OrderKey key{customer, order};
            totals.insert(key, customer * 100 + order);
            shared.insert(key, customer * 100 + order);
        }
    }
    const std::uint64_t* found = totals.find(OrderKey{1234, 7});
    const std::optional<std::uint64_t> copied = shared.get_copied(OrderKey{1234, 7});
    const bool correct = found != nullptr && *found == 123407 && copied == 123407 && totals.size() == 60000;
    std::printf("custom key %s\n", correct ? "ok" : "FAILED");
    return correct ? 0 : 1;
}
