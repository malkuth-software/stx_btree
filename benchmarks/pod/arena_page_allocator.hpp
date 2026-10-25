#pragma once

// A page allocator for benchmark experiments only: pages of each size class
// come from 64 MiB chunks, handed out in address order and recycled through a
// free list per class, zeroed like GlobalPageAllocator's. Used by
// stx_btree_bench when built with -DSTX_BTREE_BENCH_ARENA, to measure what the
// system allocator's aligned allocations and page placement cost the unsync
// map. Single-threaded; the arena lives until the process ends.

#include "stx_btree/page_allocator.hpp"

#include <cstddef>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <new>
#include <vector>

namespace stx_btree_bench {

class PageArena final {
public:
    static constexpr std::size_t chunk_bytes = static_cast<std::size_t>(64) << 20;
    static constexpr std::size_t chunk_alignment = static_cast<std::size_t>(2) << 20;

    [[nodiscard]] static PageArena& instance() {
        static PageArena arena;
        return arena;
    }

    [[nodiscard]] void* take(std::size_t bytes, std::size_t alignment) {
        SizeClass& size_class = class_for(bytes, alignment);
        if (!size_class.free_pages.empty()) {
            void* page = size_class.free_pages.back();
            size_class.free_pages.pop_back();
            return page;
        }
        const std::size_t step = round_up(bytes, alignment);
        if (size_class.next == nullptr || size_class.next + step > size_class.end) {
            std::byte* chunk = static_cast<std::byte*>(std::aligned_alloc(chunk_alignment, chunk_bytes));
            if (chunk == nullptr) {
                throw std::bad_alloc();
            }
            chunks.push_back(chunk);
            size_class.next = chunk;
            size_class.end = chunk + chunk_bytes;
        }
        void* page = size_class.next;
        size_class.next += step;
        return page;
    }

    void give_back(void* page, std::size_t bytes, std::size_t alignment) {
        SizeClass& size_class = class_for(bytes, alignment);
        size_class.free_pages.push_back(page);
    }

    PageArena(const PageArena&) = delete;
    PageArena& operator=(const PageArena&) = delete;

    ~PageArena() {
        std::size_t index = 0;
        for (index = 0; index < chunks.size(); index += 1) {
            std::free(chunks[index]);
        }
    }

private:
    PageArena() = default;

    struct SizeClass final {
        std::size_t bytes = 0;
        std::size_t alignment = 0;
        std::byte* next = nullptr;
        std::byte* end = nullptr;
        std::vector<void*> free_pages;
    };

    [[nodiscard]] static std::size_t round_up(std::size_t bytes, std::size_t alignment) noexcept {
        return (bytes + alignment - 1) / alignment * alignment;
    }

    [[nodiscard]] SizeClass& class_for(std::size_t bytes, std::size_t alignment) {
        std::size_t index = 0;
        for (index = 0; index < classes.size(); index += 1) {
            if (classes[index].bytes == bytes && classes[index].alignment == alignment) {
                return classes[index];
            }
        }
        classes.push_back(SizeClass{.bytes = bytes, .alignment = alignment, .next = nullptr, .end = nullptr, .free_pages = {}});
        return classes.back();
    }

    std::vector<SizeClass> classes;
    std::vector<std::byte*> chunks;
};

class ArenaPageAllocator final {
public:
    [[nodiscard]] void* allocate_page(stx_btree::PageKind, std::size_t bytes, std::size_t alignment) const {
        void* page = PageArena::instance().take(bytes, alignment);
        std::memset(page, 0, bytes);
        return page;
    }

    void deallocate_page(stx_btree::PageKind, void* page, std::size_t bytes, std::size_t alignment) const {
        PageArena::instance().give_back(page, bytes, alignment);
    }

    [[nodiscard]] bool operator==(const ArenaPageAllocator&) const noexcept {
        return true;
    }
};

} // namespace stx_btree_bench
