// A consumer of the installed package: both maps, through the public
// headers only.

#include "stx_btree/bbtree_map.hpp"
#include "stx_btree/unsync_map.hpp"

#include <cstdint>
#include <cstdio>
#include <optional>
#include <string>

namespace {

struct Count final {
    std::uint64_t* total = nullptr;
    bool operator()(const std::string&, const std::uint64_t& value) const {
        *total += value;
        return true;
    }
};

} // namespace

int main() {
    stx_btree::unsync::BBTreeMap<std::uint64_t, std::string> names;
    names.insert(42, "corro");
    names.insert(7, "ferris");
    const std::string* found = names.find(42);
    if (found == nullptr || *found != "corro" || names.size() != 2) {
        std::fprintf(stderr, "unsync map failed\n");
        return 1;
    }

    stx_btree::BBTreeMap<std::string, std::uint64_t> shared;
    std::uint64_t key = 0;
    for (key = 0; key < 1000; key += 1) {
        shared.insert("key/" + std::to_string(key), key);
    }
    const std::optional<std::uint64_t> copy = shared.get_copied("key/500");
    std::uint64_t total = 0;
    const stx_btree::BBTreeMap<std::string, std::uint64_t>::Bound unbounded{nullptr, true};
    shared.scan(unbounded, unbounded, Count{&total});
    if (!copy.has_value() || *copy != 500 || total != 999 * 1000 / 2) {
        std::fprintf(stderr, "shared map failed\n");
        return 1;
    }
    std::printf("installed consumer ok\n");
    return 0;
}
