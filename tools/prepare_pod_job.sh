#!/bin/sh
# Assembles .build/pod-job for the Fable compute pod: a snapshot of this
# commit, the pinned bbtree snapshot, the reference bench's vendored crates
# and benchmarks/pod/run.sh. Needs .build/rust-vendor (cargo vendor --locked,
# made on the Mac mini, where cargo lives). Submit once the pod is free:
#
#   ~/.local/bin/fable-compute submit "$(pwd)/.build/pod-job" -- bash run.sh
set -eu
job=.build/pod-job
commit="$(git rev-parse HEAD)"
upstream="$(cat benchmarks/rust/UPSTREAM_COMMIT)"
test -d .build/rust-vendor || { echo "missing .build/rust-vendor" >&2; exit 1; }
test "$(git -C upstream/bbtree rev-parse HEAD)" = "$upstream"
rm -rf "$job"
mkdir -p "$job/stx_btree/upstream/bbtree" "$job/stx_btree/benchmarks/rust/.cargo"
git archive "$commit" | tar -x -C "$job/stx_btree"
# The bbtree crate alone: its workspace manifest names members not shipped.
git -C upstream/bbtree archive "$upstream" README.md LICENSE bbtree/Cargo.toml bbtree/LICENSE bbtree/src \
    | tar -x -C "$job/stx_btree/upstream/bbtree"
cp -R .build/rust-vendor "$job/stx_btree/benchmarks/rust/vendor"
printf '[source.crates-io]\nreplace-with = "vendored-sources"\n\n[source.vendored-sources]\ndirectory = "vendor"\n' \
    > "$job/stx_btree/benchmarks/rust/.cargo/config.toml"
cp benchmarks/pod/run.sh "$job/run.sh"
echo "$commit" > "$job/STX_BTREE_COMMIT"
du -sh "$job"
echo "prepared $job at $commit"
