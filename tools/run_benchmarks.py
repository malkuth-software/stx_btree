#!/usr/bin/env python3
"""Run the C++/Rust benchmark matrix and record its environment.

Run from the repository root on the measurement host (through m4build on
the owner's machine), after building .build/release and .build/rust-bench:

    python3 -B tools/run_benchmarks.py --output results/<new-name> [--quick]

Every cell is a fresh process. Repetitions interleave the two programs and
alternate which goes first, so drift affects both alike. The runner refuses
an existing output directory, checks that both programs report the same
checksum for every cell, and writes raw.csv, environment.json and
summary.md (medians with the spread of the repetitions).
"""

import argparse
import csv
import json
import os
import platform
import statistics
import subprocess
import sys
import time

CPP = ".build/release/stx_btree_bench"
RUST = ".build/rust-bench/release/bbtree-reference-bench"
UPSTREAM = "upstream/bbtree"

KEYS = ["u64", "uuid", "str16", "url"]
SIZES = [1_000_000, 10_000_000]
THREAD_KEYS = ["u64", "str16"]
THREAD_COUNTS = [1, 2, 4, 8, 10]


def command_output(arguments):
    try:
        completed = subprocess.run(arguments, check=True, capture_output=True, text=True)
    except (OSError, subprocess.CalledProcessError) as error:
        return "unavailable: %s" % error
    return completed.stdout.strip()


def sysctl(name):
    return command_output(["sysctl", "-n", name])


def first_line(text):
    lines = text.splitlines()
    return lines[0] if lines else text


def environment(options):
    record = {
        "recorded_at": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "host": platform.node(),
        "machine": platform.machine(),
        "system": platform.system(),
        "cxx_compiler": first_line(command_output([options.cxx, "--version"])),
        "rustc": first_line(command_output([options.rustc, "--version"])),
        "rust_flags": "-C target-cpu=native, codegen-units=1, lto=fat",
        "thread_counts": options.thread_counts,
        "upstream_commit": command_output(["cat", "benchmarks/rust/UPSTREAM_COMMIT"]),
        "stx_btree_commit": os.environ.get("STX_BTREE_COMMIT", "unrecorded"),
    }
    if platform.system() == "Darwin":
        record.update({
            "cpu": sysctl("machdep.cpu.brand_string"),
            "performance_cores": sysctl("hw.perflevel0.physicalcpu"),
            "efficiency_cores": sysctl("hw.perflevel1.physicalcpu"),
            "memory_bytes": sysctl("hw.memsize"),
            "l2_bytes_performance": sysctl("hw.perflevel0.l2cachesize"),
            "os": command_output(["sw_vers", "-productVersion"]),
            "cxx_flags": "-O3 -DNDEBUG -mcpu=native (CMake Release)",
            "allocator": "system allocator in both programs (macOS libmalloc)",
        })
    else:
        record.update({
            "cpu": command_output(["sh", "-c", "lscpu | grep 'Model name' | sed 's/.*: *//'"]),
            "cpu_quota": command_output(["sh", "-c", "cat /sys/fs/cgroup/cpu.max 2>/dev/null || nproc"]),
            "nproc": command_output(["nproc"]),
            "memory_limit": command_output(["sh", "-c", "cat /sys/fs/cgroup/memory.max 2>/dev/null"]),
            "os": command_output(["sh", "-c", ". /etc/os-release && echo $PRETTY_NAME"]),
            "kernel": command_output(["uname", "-r"]),
            "cxx_flags": "-O3 -DNDEBUG -march=native (CMake Release)",
            "allocator": "system allocator in both programs (glibc malloc)",
        })
    return record


def run_cell(program, arguments):
    completed = subprocess.run([program] + arguments, check=True, capture_output=True, text=True)
    rows = []
    for line in completed.stdout.splitlines():
        fields = line.split(",")
        if len(fields) == 9:
            rows.append(fields)
    return rows


def cells(quick, thread_counts):
    sizes = [100_000, 1_000_000] if quick else SIZES
    operations = 200_000 if quick else 1_000_000
    for size in sizes:
        for key in KEYS:
            for map_kind in ["unsync", "shared"]:
                yield [map_kind, key, str(size), str(operations)]
    thread_size = 1_000_000 if quick else 10_000_000
    thread_operations = 200_000 if quick else 1_000_000
    for key in THREAD_KEYS:
        for threads in thread_counts:
            yield ["threads", key, str(thread_size), str(thread_operations), str(threads)]


def summarize(rows):
    groups = {}
    for row in rows:
        implementation, map_kind, key, size, threads, workload, operations, per_op, checksum = row
        group_key = (map_kind, key, size, threads, workload)
        groups.setdefault(group_key, {}).setdefault(implementation, []).append(float(per_op))
    lines = [
        "| map | key | size | threads | workload | C++ ns/op (median, range) | Rust ns/op (median, range) | Rust/C++ |",
        "| --- | --- | ---: | ---: | --- | ---: | ---: | ---: |",
    ]
    for group_key in sorted(groups, key=lambda item: (item[0], item[1], int(item[2]), int(item[3]), item[4])):
        timings = groups[group_key]
        cpp = timings.get("cpp", [])
        rust = timings.get("rust", [])
        if not cpp or not rust:
            continue
        cpp_median = statistics.median(cpp)
        rust_median = statistics.median(rust)
        ratio = rust_median / cpp_median if cpp_median > 0 else float("nan")
        lines.append("| %s | %s | %s | %s | %s | %.2f (%.2f-%.2f) | %.2f (%.2f-%.2f) | %.2f |" % (
            group_key[0], group_key[1], group_key[2], group_key[3], group_key[4],
            cpp_median, min(cpp), max(cpp), rust_median, min(rust), max(rust), ratio))
    return "\n".join(lines) + "\n"


def check_checksums(rows):
    checksums = {}
    mismatches = []
    for row in rows:
        implementation, map_kind, key, size, threads, workload, operations, per_op, checksum = row
        if workload in ("mt_insert",):
            continue
        cell = (map_kind, key, size, threads, workload)
        previous = checksums.setdefault(cell, checksum)
        if previous != checksum:
            mismatches.append((cell, previous, checksum))
    return mismatches


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True)
    parser.add_argument("--repetitions", type=int, default=3)
    parser.add_argument("--quick", action="store_true")
    parser.add_argument("--thread-counts", default=",".join(str(count) for count in THREAD_COUNTS),
                        help="comma-separated thread counts for the shared map's threaded cells")
    parser.add_argument("--cxx", default="/opt/homebrew/opt/llvm/bin/clang++",
                        help="the C++ compiler the release tree used, for the record")
    parser.add_argument("--rustc", default=os.path.expanduser("~/.cargo/bin/rustc"),
                        help="the rustc the reference bench used, for the record")
    options = parser.parse_args()
    options.thread_counts = [int(count) for count in options.thread_counts.split(",")]
    if os.path.exists(options.output):
        sys.exit("refusing to overwrite %s" % options.output)
    for program in (CPP, RUST):
        if not os.access(program, os.X_OK):
            sys.exit("missing %s: build it first" % program)
    os.makedirs(options.output)
    with open(os.path.join(options.output, "environment.json"), "w") as handle:
        json.dump(environment(options), handle, indent=2)
    rows = []
    raw_path = os.path.join(options.output, "raw.csv")
    with open(raw_path, "w", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["implementation", "map", "key", "size", "threads", "workload",
                         "operations", "ns_per_op", "checksum", "repetition"])
        for repetition in range(options.repetitions):
            for cell in cells(options.quick, options.thread_counts):
                order = [CPP, RUST] if repetition % 2 == 0 else [RUST, CPP]
                for program in order:
                    for row in run_cell(program, cell):
                        rows.append(row)
                        writer.writerow(row + [str(repetition)])
                handle.flush()
                print("repetition %d: %s done" % (repetition, " ".join(cell)), flush=True)
    mismatches = check_checksums(rows)
    with open(os.path.join(options.output, "summary.md"), "w") as handle:
        handle.write(summarize(rows))
        if mismatches:
            handle.write("\nChecksum mismatches:\n")
            for cell, first, other in mismatches:
                handle.write("- %s: %s vs %s\n" % (" ".join(cell), first, other))
    print("checksum mismatches: %d" % len(mismatches))
    return 1 if mismatches else 0


if __name__ == "__main__":
    sys.exit(main())
