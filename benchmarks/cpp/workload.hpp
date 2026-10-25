#pragma once

// The benchmark workloads, defined identically in benchmarks/rust: keys are
// generated from indexes by the SplitMix64 finalizer, so both programs build
// the same maps, issue the same queries and report the same checksums.

#include <array>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <string>

namespace stx_btree_bench {

class Mix final {
public:
    [[nodiscard]] static std::uint64_t mix(std::uint64_t value) noexcept {
        std::uint64_t z = value + 0x9e3779b97f4a7c15ULL;
        z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9ULL;
        z = (z ^ (z >> 27)) * 0x94d049bb133111ebULL;
        return z ^ (z >> 31);
    }
};

inline constexpr std::uint64_t key_salt = 0x5eed;
inline constexpr std::uint64_t query_salt = 0x9a1e;
// Multiplying by this prime permutes [0, size) for sizes it does not divide.
inline constexpr std::uint64_t removal_stride = 7919;

using Uuid = std::array<std::uint8_t, 16>;

class KeySet final {
public:
    [[nodiscard]] static std::uint64_t u64_key(std::uint64_t index) noexcept {
        return Mix::mix(index ^ key_salt);
    }
    [[nodiscard]] static std::uint64_t u64_ordered(std::uint64_t rank) noexcept {
        return rank;
    }

    static void write_big_endian(std::uint64_t word, std::uint8_t* out) noexcept {
        std::size_t index = 0;
        for (index = 0; index < 8; index += 1) {
            out[index] = static_cast<std::uint8_t>(word >> (56 - 8 * index));
        }
    }
    [[nodiscard]] static Uuid uuid_key(std::uint64_t index) noexcept {
        Uuid key{};
        const std::uint64_t first = Mix::mix(index ^ key_salt);
        const std::uint64_t second = Mix::mix(first);
        write_big_endian(first, key.data());
        write_big_endian(second, key.data() + 8);
        return key;
    }
    [[nodiscard]] static Uuid uuid_ordered(std::uint64_t rank) noexcept {
        Uuid key{};
        write_big_endian(0x0190000000000000ULL, key.data());
        write_big_endian(rank, key.data() + 8);
        return key;
    }

    [[nodiscard]] static std::string hex16(std::uint64_t word) {
        static constexpr char digits[] = "0123456789abcdef";
        std::string text(16, '0');
        std::size_t index = 0;
        for (index = 0; index < 16; index += 1) {
            text[index] = digits[(word >> (60 - 4 * index)) & 15];
        }
        return text;
    }
    // Random 16-character strings: no shared prefixes.
    [[nodiscard]] static std::string str16_key(std::uint64_t index) {
        return hex16(Mix::mix(index ^ key_salt));
    }
    // URLs behind a 26-byte common head: prefix stripping's case.
    [[nodiscard]] static std::string url_key(std::uint64_t index) {
        return std::string("https://example.org/items/") + hex16(Mix::mix(index ^ key_salt));
    }
    [[nodiscard]] static std::string decimal_ordered(std::uint64_t rank) {
        std::string text = "item/000000000000";
        std::size_t position = text.size();
        std::uint64_t remaining = rank;
        while (position > 5) {
            position -= 1;
            text[position] = static_cast<char>('0' + remaining % 10);
            remaining /= 10;
        }
        return text;
    }

    // The j-th lookup's key index, uniform over [0, size).
    [[nodiscard]] static std::uint64_t query_index(std::uint64_t j, std::uint64_t size) noexcept {
        return Mix::mix(j ^ query_salt) % size;
    }
    [[nodiscard]] static std::uint64_t removal_index(std::uint64_t j, std::uint64_t size) noexcept {
        return (j * removal_stride) % size;
    }
};

} // namespace stx_btree_bench
