//! bbtree on stx_btree's benchmark workloads (benchmarks/cpp/workload.hpp):
//! the same keys, queries, order and checksums.
//!
//! usage: bbtree-reference-bench <unsync|shared|threads> <u64|uuid|str16|url> <size> <operations> [threads]

use std::borrow::Borrow;
use std::hint::black_box;
use std::ops::ControlFlow;
use std::sync::atomic::{AtomicBool, Ordering};
use std::time::Instant;

const KEY_SALT: u64 = 0x5eed;
const QUERY_SALT: u64 = 0x9a1e;
const REMOVAL_STRIDE: u64 = 7919;

fn mix(value: u64) -> u64 {
    let mut z = value.wrapping_add(0x9e37_79b9_7f4a_7c15);
    z = (z ^ (z >> 30)).wrapping_mul(0xbf58_476d_1ce4_e5b9);
    z = (z ^ (z >> 27)).wrapping_mul(0x94d0_49bb_1331_11eb);
    z ^ (z >> 31)
}

fn query_index(j: u64, size: u64) -> u64 {
    mix(j ^ QUERY_SALT) % size
}

fn removal_index(j: u64, size: u64) -> u64 {
    j.wrapping_mul(REMOVAL_STRIDE) % size
}

fn hex16(word: u64) -> String {
    const DIGITS: &[u8; 16] = b"0123456789abcdef";
    (0..16)
        .map(|index| DIGITS[((word >> (60 - 4 * index)) & 15) as usize] as char)
        .collect()
}

fn decimal_ordered(rank: u64) -> String {
    format!("item/{rank:012}")
}

trait KeyFamily {
    type Key: Ord + Clone + Send + Sync + std::borrow::Borrow<Self::Query>;
    type Query: Ord + ?Sized + Sync;
    const NAME: &'static str;
    fn make(index: u64) -> Self::Key;
    fn ordered(rank: u64) -> Self::Key;
}

struct U64Keys;
impl KeyFamily for U64Keys {
    type Key = u64;
    type Query = u64;
    const NAME: &'static str = "u64";
    fn make(index: u64) -> u64 {
        mix(index ^ KEY_SALT)
    }
    fn ordered(rank: u64) -> u64 {
        rank
    }
}

struct UuidKeys;
impl KeyFamily for UuidKeys {
    type Key = [u8; 16];
    type Query = [u8; 16];
    const NAME: &'static str = "uuid";
    fn make(index: u64) -> [u8; 16] {
        let first = mix(index ^ KEY_SALT);
        let second = mix(first);
        let mut key = [0; 16];
        key[..8].copy_from_slice(&first.to_be_bytes());
        key[8..].copy_from_slice(&second.to_be_bytes());
        key
    }
    fn ordered(rank: u64) -> [u8; 16] {
        let mut key = [0; 16];
        key[..8].copy_from_slice(&0x0190_0000_0000_0000_u64.to_be_bytes());
        key[8..].copy_from_slice(&rank.to_be_bytes());
        key
    }
}

struct Str16Keys;
impl KeyFamily for Str16Keys {
    type Key = String;
    type Query = str;
    const NAME: &'static str = "str16";
    fn make(index: u64) -> String {
        hex16(mix(index ^ KEY_SALT))
    }
    fn ordered(rank: u64) -> String {
        decimal_ordered(rank)
    }
}

struct UrlKeys;
impl KeyFamily for UrlKeys {
    type Key = String;
    type Query = str;
    const NAME: &'static str = "url";
    fn make(index: u64) -> String {
        format!("https://example.org/items/{}", hex16(mix(index ^ KEY_SALT)))
    }
    fn ordered(rank: u64) -> String {
        decimal_ordered(rank)
    }
}

struct Label {
    map: &'static str,
    key: &'static str,
    size: u64,
    threads: u64,
}

fn report(label: &Label, workload: &str, operations: u64, elapsed_ns: u128, checksum: u64) {
    let per_operation = if operations == 0 {
        0.0
    } else {
        elapsed_ns as f64 / operations as f64
    };
    println!(
        "rust,{},{},{},{},{},{},{:.2},{}",
        label.map, label.key, label.size, label.threads, workload, operations, per_operation, checksum
    );
}

fn run_unsync<F: KeyFamily>(size: u64, operations: u64) {
    let label = Label { map: "unsync", key: F::NAME, size, threads: 1 };
    let keys: Vec<F::Key> = (0..size).map(F::make).collect();
    let hits: Vec<F::Key> = (0..operations).map(|j| keys[query_index(j, size) as usize].clone()).collect();
    let misses: Vec<F::Key> = (0..operations).map(|j| F::make(size + query_index(j, size))).collect();

    let mut map = bbtree::unsync::BBTreeMap::<F::Key, u64>::new();
    let start = Instant::now();
    for (index, key) in keys.iter().enumerate() {
        map.insert(key.clone(), index as u64);
    }
    report(&label, "insert_random", size, start.elapsed().as_nanos(), map.len() as u64);

    let mut checksum = 0u64;
    let start = Instant::now();
    for key in &hits {
        let query: &F::Query = key.borrow();
        checksum = checksum.wrapping_add(map.get(black_box(query)).copied().unwrap_or(0));
    }
    report(&label, "get_hit", operations, start.elapsed().as_nanos(), checksum);

    let mut checksum = 0u64;
    let start = Instant::now();
    for key in &misses {
        let query: &F::Query = key.borrow();
        checksum = checksum.wrapping_add(map.get(black_box(query)).copied().unwrap_or(1));
    }
    report(&label, "get_miss", operations, start.elapsed().as_nanos(), checksum);

    let scans = operations / 16;
    let mut checksum = 0u64;
    let start = Instant::now();
    for key in &hits[..scans as usize] {
        let query: &F::Query = key.borrow();
        let bounds = (std::ops::Bound::Included(black_box(query)), std::ops::Bound::Unbounded);
        for (_, value) in map.range::<F::Query, _>(bounds).take(64) {
            checksum = checksum.wrapping_add(*value);
        }
    }
    report(&label, "range64", scans, start.elapsed().as_nanos(), checksum);

    let mut checksum = 0u64;
    let start = Instant::now();
    for (_, value) in map.iter() {
        checksum = checksum.wrapping_add(*value);
    }
    report(&label, "iterate", size, start.elapsed().as_nanos(), checksum);

    let removals = operations.min(size);
    let mut checksum = 0u64;
    let start = Instant::now();
    for j in 0..removals {
        let query: &F::Query = keys[removal_index(j, size) as usize].borrow();
        checksum = checksum.wrapping_add(map.remove(black_box(query)).unwrap_or(0));
    }
    report(&label, "remove_random", removals, start.elapsed().as_nanos(), checksum);

    let ordered: Vec<F::Key> = (0..size).map(F::ordered).collect();
    let mut sequential = bbtree::unsync::BBTreeMap::<F::Key, u64>::new();
    let start = Instant::now();
    for (index, key) in ordered.into_iter().enumerate() {
        sequential.insert(key, index as u64);
    }
    report(&label, "insert_sequential", size, start.elapsed().as_nanos(), sequential.len() as u64);
}


const BATCH: usize = 64;

fn run_shared<F: KeyFamily>(size: u64, operations: u64) {
    let label = Label { map: "shared", key: F::NAME, size, threads: 1 };
    let keys: Vec<F::Key> = (0..size).map(F::make).collect();
    let hits: Vec<F::Key> = (0..operations).map(|j| keys[query_index(j, size) as usize].clone()).collect();
    let misses: Vec<F::Key> = (0..operations).map(|j| F::make(size + query_index(j, size))).collect();

    let map = bbtree::BBTreeMap::<F::Key, u64>::new();
    let start = Instant::now();
    for (index, key) in keys.iter().enumerate() {
        let _ = map.insert(key.clone(), index as u64);
    }
    report(&label, "insert_random", size, start.elapsed().as_nanos(), size);

    let mut checksum = 0u64;
    let start = Instant::now();
    for key in &hits {
        let query: &F::Query = key.borrow();
        checksum = checksum.wrapping_add(map.get_copied(black_box(query)).unwrap_or(0));
    }
    report(&label, "get_hit", operations, start.elapsed().as_nanos(), checksum);

    let mut checksum = 0u64;
    let start = Instant::now();
    for key in &misses {
        let query: &F::Query = key.borrow();
        checksum = checksum.wrapping_add(map.get_copied(black_box(query)).unwrap_or(1));
    }
    report(&label, "get_miss", operations, start.elapsed().as_nanos(), checksum);

    let batched = operations - operations % BATCH as u64;
    let mut checksum = 0u64;
    let start = Instant::now();
    for chunk in hits[..batched as usize].chunks_exact(BATCH) {
        let queries: [&F::Query; BATCH] = core::array::from_fn(|lane| chunk[lane].borrow());
        for value in map.get_many_copied(black_box(queries)) {
            checksum = checksum.wrapping_add(value.unwrap_or(0));
        }
    }
    report(&label, "get_hit_batched", batched, start.elapsed().as_nanos(), checksum);

    let scans = operations / 16;
    let mut checksum = 0u64;
    let start = Instant::now();
    for key in &hits[..scans as usize] {
        let query: &F::Query = key.borrow();
        let mut visited = 0;
        map.scan::<F::Query, ()>((std::ops::Bound::Included(black_box(query)), std::ops::Bound::Unbounded), |_, value| {
            checksum = checksum.wrapping_add(*value);
            visited += 1;
            if visited < 100 { ControlFlow::Continue(()) } else { ControlFlow::Break(()) }
        });
    }
    report(&label, "scan100", scans, start.elapsed().as_nanos(), checksum);

    let mut checksum = 0u64;
    let start = Instant::now();
    for key in &hits {
        let query: &F::Query = key.borrow();
        let found = map.update(black_box(query), |_, value| *value += 1).is_some();
        checksum = checksum.wrapping_add(u64::from(found));
    }
    report(&label, "update", operations, start.elapsed().as_nanos(), checksum);

    let removals = operations.min(size);
    let mut checksum = 0u64;
    let start = Instant::now();
    for j in 0..removals {
        let query: &F::Query = keys[removal_index(j, size) as usize].borrow();
        checksum = checksum.wrapping_add(u64::from(map.remove(black_box(query)).is_some()));
    }
    report(&label, "remove_random", removals, start.elapsed().as_nanos(), checksum);

    let ordered: Vec<F::Key> = (0..size).map(F::ordered).collect();
    let sequential = bbtree::BBTreeMap::<F::Key, u64>::new();
    let start = Instant::now();
    for (index, key) in ordered.into_iter().enumerate() {
        let _ = sequential.insert(key, index as u64);
    }
    report(&label, "insert_sequential", size, start.elapsed().as_nanos(), size);
}

#[derive(Clone, Copy, PartialEq)]
enum ThreadWork {
    Insert,
    GetHalf,
    GetHalfBatched,
    Mixed,
}

fn run_workers<F: KeyFamily>(
    map: &bbtree::BBTreeMap<F::Key, u64>,
    keys: &[F::Key],
    absent: &[F::Key],
    size: u64,
    per_thread: u64,
    threads: u64,
    work: ThreadWork,
) -> (u128, u64) {
    let go = AtomicBool::new(false);
    std::thread::scope(|scope| {
        let handles: Vec<_> = (0..threads)
            .map(|thread| {
                let go = &go;
                scope.spawn(move || {
                    while !go.load(Ordering::Acquire) {
                        std::thread::yield_now();
                    }
                    let first = thread * per_thread;
                    let mut sum = 0u64;
                    match work {
                        ThreadWork::Insert => {
                            for j in first..first + per_thread {
                                let _ = map.insert(keys[j as usize].clone(), j);
                            }
                        }
                        ThreadWork::GetHalf => {
                            for j in first..first + per_thread {
                                let chosen = query_index(j, size) as usize;
                                let key = if j % 2 == 0 { &keys[chosen] } else { &absent[chosen] };
                                sum = sum.wrapping_add(map.get_copied(key.borrow()).unwrap_or(1));
                            }
                        }
                        ThreadWork::GetHalfBatched => {
                            let mut j = first;
                            while j + BATCH as u64 <= first + per_thread {
                                let queries: [&F::Query; BATCH] = core::array::from_fn(|lane| {
                                    let at = j + lane as u64;
                                    let chosen = query_index(at, size) as usize;
                                    let key = if at % 2 == 0 { &keys[chosen] } else { &absent[chosen] };
                                    key.borrow()
                                });
                                for value in map.get_many_copied(queries) {
                                    sum = sum.wrapping_add(value.unwrap_or(1));
                                }
                                j += BATCH as u64;
                            }
                        }
                        ThreadWork::Mixed => {
                            for j in first..first + per_thread {
                                let query: &F::Query = keys[query_index(j, size) as usize].borrow();
                                if j % 10 == 0 {
                                    sum = sum.wrapping_add(u64::from(map.update(query, |_, value| *value += 1).is_some()));
                                } else {
                                    sum = sum.wrapping_add(u64::from(map.get_copied(query).is_some()));
                                }
                            }
                        }
                    }
                    sum
                })
            })
            .collect();
        let start = Instant::now();
        go.store(true, Ordering::Release);
        let total = handles.into_iter().fold(0u64, |total, handle| total.wrapping_add(handle.join().expect("worker")));
        (start.elapsed().as_nanos(), total)
    })
}

fn run_threads<F: KeyFamily>(size: u64, operations: u64, threads: u64) {
    let label = Label { map: "shared", key: F::NAME, size, threads };
    let keys: Vec<F::Key> = (0..size).map(F::make).collect();
    let absent: Vec<F::Key> = (0..size).map(|index| F::make(size + index)).collect();
    let map = bbtree::BBTreeMap::<F::Key, u64>::new();
    let share = size / threads;
    let (elapsed, _) = run_workers::<F>(&map, &keys, &absent, size, share, threads, ThreadWork::Insert);
    for index in share * threads..size {
        let _ = map.insert(keys[index as usize].clone(), index);
    }
    report(&label, "mt_insert", share * threads, elapsed, 0);
    let per_thread = operations - operations % BATCH as u64;
    let (elapsed, checksum) = run_workers::<F>(&map, &keys, &absent, size, per_thread, threads, ThreadWork::GetHalf);
    report(&label, "mt_get_half", per_thread * threads, elapsed, checksum);
    let (elapsed, checksum) = run_workers::<F>(&map, &keys, &absent, size, per_thread, threads, ThreadWork::GetHalfBatched);
    report(&label, "mt_get_half_batched", per_thread * threads, elapsed, checksum);
    let (elapsed, checksum) = run_workers::<F>(&map, &keys, &absent, size, per_thread, threads, ThreadWork::Mixed);
    report(&label, "mt_mixed_90_10", per_thread * threads, elapsed, checksum);
}

fn dispatch<F: KeyFamily>(map: &str, size: u64, operations: u64, threads: u64) {
    match map {
        "unsync" => run_unsync::<F>(size, operations),
        "shared" => run_shared::<F>(size, operations),
        "threads" => run_threads::<F>(size, operations, threads),
        other => panic!("unknown map {other}"),
    }
}

fn main() {
    let arguments: Vec<String> = std::env::args().collect();
    if arguments.len() < 5 {
        eprintln!("usage: {} <unsync|shared> <u64|uuid|str16|url> <size> <operations> [threads]", arguments[0]);
        std::process::exit(2);
    }
    let size: u64 = arguments[3].parse().expect("size");
    let operations: u64 = arguments[4].parse().expect("operations");
    let threads: u64 = arguments.get(5).map_or(1, |text| text.parse().expect("threads"));
    match arguments[2].as_str() {
        "u64" => dispatch::<U64Keys>(&arguments[1], size, operations, threads),
        "uuid" => dispatch::<UuidKeys>(&arguments[1], size, operations, threads),
        "str16" => dispatch::<Str16Keys>(&arguments[1], size, operations, threads),
        "url" => dispatch::<UrlKeys>(&arguments[1], size, operations, threads),
        other => panic!("unknown key {other}"),
    }
}
