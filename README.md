# stx_btree

### bbtree, in C++

**A cache-conscious ordered map, single-threaded or shared between threads.**

stx_btree is a C++20 form of [**bbtree**](https://github.com/XiangpengHao/bbtree),
the B-tree by [**Xiangpeng Hao**](https://xiangpeng.systems). The data
structures, node layouts, search, prefix upkeep and concurrency protocol are
bbtree's, translated from its Rust source and its design record; see
[how it works](https://bbtree.xiangpeng.systems/post) for the author's account.
This repository provides the same two maps as a header-only C++ library:

- `stx_btree::unsync::BBTreeMap<K, V>`: one thread, iterators, `find`,
  `insert`, `remove`, `pop_first`/`pop_last`, `lower_bound`, and batched
  `get_many`/`insert_many`;
- `stx_btree::BBTreeMap<K, V>`: shared by threads with no locks to hold, no
  epochs and no guards; lookups copy values out (`get_copied`) or run a
  visitor on the entry (`read`, `update`), with scans, `remove_if`,
  `update_or_insert`, and batched `get_many_copied`/`insert_many`.

[Design](docs/DESIGN.md) · [Build](docs/BUILDING.md) ·
[Measurements](docs/MEASUREMENTS.md) · [Provenance](PROVENANCE.md) ·
[License: MIT OR Apache-2.0](LICENSE)

## The construction

Every key has an **inline key**: a fixed-width window of an
order-preserving byte encoding. Nodes keep these windows in a dense array and
search them by counting, in vector lane groups, how many lie below the
query; a key is read only when windows tie. Each node skips the bytes its
**fences** (the separators beside it) share, so windows stay informative on
keys with long common prefixes, and the root keeps what every key shares.
Separator keys live in leaf **heads**, so internal nodes hold only windows
and child pointers in 512-byte pages; leaves are 1 KiB. Leaves pair each key
with its value, and keep a one-byte **hash tag** per string key.

The shared map runs the same tree under **optimistic lock coupling**:
internal nodes are read without latches and validated by version; leaves are
latched; trivially copyable values are copied out without a latch where the
leaf settles the key. A change larger than a leaf takes, without waiting,
exactly the nodes the single-threaded operation will touch, then runs that
operation. Freed pages stay type-stable on free lists until the map is
destroyed, so racing readers never need epochs.

Batched lookups and inserts descend in **lanes**, small state machines that
prefetch the line they read next and yield, so independent cache misses
overlap.

## Example

```cpp
#include "stx_btree/bbtree_map.hpp"
#include "stx_btree/unsync_map.hpp"

#include <cstdint>
#include <optional>
#include <string>

struct Bump final {
    void operator()(const std::string&, std::uint64_t& count) const noexcept {
        count += 1;
    }
};

int main() {
    stx_btree::unsync::BBTreeMap<std::uint64_t, std::string> names;
    names.insert(42, "corro");
    const std::string* found = names.find(42);

    stx_btree::BBTreeMap<std::string, std::uint64_t> counts;   // shared by threads
    counts.insert("requests", 0);
    counts.update("requests", Bump{});
    const std::optional<std::uint64_t> requests = counts.get_copied("requests");
    return (found != nullptr && requests == 1) ? 0 : 1;
}
```

Keys need an `InlineKeyTraits` specialization. `std::uint64_t`,
`std::int64_t`, `std::array<std::uint8_t, N>` and `std::string` (queried by
`std::string_view`) are provided; [the design notes](docs/DESIGN.md#keys)
show how to add a key type.

### Pooled pages

Both maps take a page allocator as their last template argument. The
default, `GlobalPageAllocator`, asks the system for every node page.
`PooledPageAllocator` (`stx_btree/pooled_page_allocator.hpp`) carves pages in
address order from chunks of up to 2 MiB and reuses freed pages; its pool is
shared by copies of the allocator and lives until the last one goes, and
pages go back to the system only then.

```cpp
#include "stx_btree/pooled_page_allocator.hpp"

stx_btree::BBTreeMap<std::uint64_t, std::uint64_t, stx_btree::PooledPageAllocator> map;
```

On macOS it measured the same as the default (within 3%, M4). On Linux,
where glibc spaces aligned 1 KiB pages apart, packing the pages took the
unsync map's 1M-entry inserts from 1.33× to 0.94× bbtree's time in a bench
experiment; the library allocator's own run on Linux is still to come.

## Build

C++20 and CMake 3.21 or later; no dependencies. The library is header-only.

```sh
git clone https://github.com/falseywinchnet/stx_btree.git
cd stx_btree
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
ctest --test-dir build --output-on-failure
```

Install with `cmake --install build --prefix <prefix>`, then
`find_package(stx_btree 0.1 CONFIG REQUIRED)` and link
`stx_btree::stx_btree`. [Building](docs/BUILDING.md) covers the sanitizer tree
and the measured toolchain.

## Against the Rust original

Measured on an Apple M4 (Mac mini) with Homebrew LLVM 23 and nightly Rust,
both at `-mcpu`/`target-cpu=native`, both on the system allocator, with
identical keys, queries and checksums: see
[measurements](docs/MEASUREMENTS.md) for every cell, its spread and the
method. In short, at 1M entries the C++ form tracks bbtree closely (most cells
within ±10%, with string removals, scans and iteration faster in C++); the
shared map at 10M integer keys is 10–27% behind and is the main open gap,
alongside appends and the shared map's batched inserts (a partial,
single-repetition run). On Linux x86-64 with GCC 13 (AMD EPYC 9575F, full
matrix, three repetitions) the C++ form is behind: about 0.70 of bbtree's
speed over all cells, 0.56–0.63 on point lookups, at parity on scans. That
gap is partly diagnosed: most of the integer lookup gap is GCC's code on
x86-64 (Clang 18 builds run u64 lookups at 1.1–1.3× bbtree's time, and a fix
in the node count took GCC's unsync u64 lookups from 1.8× to 1.4×); string
lookups (1.7–1.9×) and writes (1.4–1.7×) are behind with either compiler and
still open. For writes, deterministic counts show the C++ form doing no more
work than bbtree, and a pooled page allocator makes it faster than bbtree at
1M entries on that host.

## Optimal search trees

Beside the maps, not from bbtree: optimal binary search trees for given
search weights, and `OptimalMap`, a static map that packs a weight-optimal
tree into nodes searched the bbtree way. At 8M keys under Zipf access
(s = 1.0–1.2) it answers lookups 1.5–1.6× faster than the unsync map on the
M4; at 1M keys it does not help. The caller picks the construction by what
its weights look like: `knuth` (exact, any weights; 8 bytes a cell and
1.55–2.1× faster than the earlier layout), `knuth_scattered` (the same,
faster when popularity is scattered over the keys), `garsia_wachs` (exact for
gap-only weights, linear memory), `balanced` (exact for constant weights),
`bottom_up` (within 1.7% of optimal in about a thousandth of Knuth's time at
16 384 keys), `weight_balanced`, and the core-sparse Monge layers of the
papers_please `obst` manuscript.
[Optimal trees](docs/OPTIMAL_TREES.md) has the design, the checks and the
numbers.

## Scope

This form covers bbtree's tree core and both maps. File maps, stores and
leaf annexes, the set types, the `entry` API, bulk building and splitting,
and the formal proofs are not translated; [PROVENANCE.md](PROVENANCE.md) lists
every difference. The format of memory is not a stable ABI.

## Credit and license

bbtree is the work of Xiangpeng Hao, whose design record
([design/](https://github.com/XiangpengHao/bbtree/tree/main/design)) explains
and measures every choice this form inherits. stx_btree is offered under the
same terms as bbtree: the MIT License or the Apache License 2.0, at your
option ([LICENSE](LICENSE), [NOTICE](NOTICE)).
