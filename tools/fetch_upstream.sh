#!/bin/sh
# Checks out bbtree at the pinned commit into upstream/bbtree (not part of
# the package; used by the reference benchmark in benchmarks/rust).
set -eu
commit="$(cat benchmarks/rust/UPSTREAM_COMMIT)"
if [ ! -d upstream/bbtree/.git ]; then
    mkdir -p upstream
    git clone https://github.com/XiangpengHao/bbtree.git upstream/bbtree
fi
git -C upstream/bbtree fetch --quiet origin
git -C upstream/bbtree checkout --quiet "$commit"
test "$(git -C upstream/bbtree rev-parse HEAD)" = "$commit"
echo "upstream/bbtree at $commit"
