/* LD_PRELOAD census of heap requests, for the pod diagnosis only: counts
 * malloc, calloc, realloc, free, posix_memalign, aligned_alloc and memalign
 * calls by (function, size, alignment), and for aligned requests of 512 or
 * more bytes the lowest and highest address returned and how many fell on a
 * new 4 KiB page. Writes the table to $ALLOC_CENSUS_OUT at exit. Not part of
 * the library or its C++ house style: a C tool at a foreign interface. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { table_size = 256 };

struct census_row {
    const char* function;
    size_t size;
    size_t alignment;
    unsigned long long calls;
};

static struct census_row rows[table_size];
static unsigned long long frees;
static uintptr_t aligned_low = UINTPTR_MAX;
static uintptr_t aligned_high;
static unsigned long long aligned_new_pages;
static uintptr_t last_page = UINTPTR_MAX;
static int busy;

static void note(const char* function, size_t size, size_t alignment) {
    int index;
    if (busy) {
        return;
    }
    for (index = 0; index < table_size; index += 1) {
        if (rows[index].function == function && rows[index].size == size && rows[index].alignment == alignment) {
            rows[index].calls += 1;
            return;
        }
        if (rows[index].function == NULL) {
            rows[index].function = function;
            rows[index].size = size;
            rows[index].alignment = alignment;
            rows[index].calls = 1;
            return;
        }
    }
}

static void note_aligned_address(void* pointer, size_t size) {
    uintptr_t address = (uintptr_t)pointer;
    uintptr_t page = address >> 12;
    if (pointer == NULL || size < 512) {
        return;
    }
    if (address < aligned_low) {
        aligned_low = address;
    }
    if (address > aligned_high) {
        aligned_high = address;
    }
    if (page != last_page) {
        aligned_new_pages += 1;
        last_page = page;
    }
}

static void* (*real_malloc)(size_t);
static void* (*real_calloc)(size_t, size_t);
static void* (*real_realloc)(void*, size_t);
static void (*real_free)(void*);
static int (*real_posix_memalign)(void**, size_t, size_t);
static void* (*real_aligned_alloc)(size_t, size_t);
static void* (*real_memalign)(size_t, size_t);

static void resolve(void) {
    if (real_malloc != NULL) {
        return;
    }
    busy = 1;
    real_malloc = (void* (*)(size_t))dlsym(RTLD_NEXT, "malloc");
    real_calloc = (void* (*)(size_t, size_t))dlsym(RTLD_NEXT, "calloc");
    real_realloc = (void* (*)(void*, size_t))dlsym(RTLD_NEXT, "realloc");
    real_free = (void (*)(void*))dlsym(RTLD_NEXT, "free");
    real_posix_memalign = (int (*)(void**, size_t, size_t))dlsym(RTLD_NEXT, "posix_memalign");
    real_aligned_alloc = (void* (*)(size_t, size_t))dlsym(RTLD_NEXT, "aligned_alloc");
    real_memalign = (void* (*)(size_t, size_t))dlsym(RTLD_NEXT, "memalign");
    busy = 0;
}

/* dlsym may call calloc before resolution finishes: serve it from a small
 * static buffer that free ignores. */
static char bootstrap[4096];
static size_t bootstrap_used;

void* malloc(size_t size) {
    resolve();
    note("malloc", size, 0);
    return real_malloc(size);
}

void* calloc(size_t count, size_t size) {
    if (real_calloc == NULL) {
        void* pointer = bootstrap + bootstrap_used;
        bootstrap_used += (count * size + 15) & ~(size_t)15;
        return pointer;
    }
    note("calloc", count * size, 0);
    return real_calloc(count, size);
}

void* realloc(void* pointer, size_t size) {
    resolve();
    note("realloc", size, 0);
    return real_realloc(pointer, size);
}

void free(void* pointer) {
    if ((char*)pointer >= bootstrap && (char*)pointer < bootstrap + sizeof(bootstrap)) {
        return;
    }
    resolve();
    if (!busy) {
        frees += 1;
    }
    real_free(pointer);
}

int posix_memalign(void** out, size_t alignment, size_t size) {
    int status;
    resolve();
    note("posix_memalign", size, alignment);
    status = real_posix_memalign(out, alignment, size);
    if (status == 0) {
        note_aligned_address(*out, size);
    }
    return status;
}

void* aligned_alloc(size_t alignment, size_t size) {
    void* pointer;
    resolve();
    note("aligned_alloc", size, alignment);
    pointer = real_aligned_alloc(alignment, size);
    note_aligned_address(pointer, size);
    return pointer;
}

void* memalign(size_t alignment, size_t size) {
    void* pointer;
    resolve();
    note("memalign", size, alignment);
    pointer = real_memalign(alignment, size);
    note_aligned_address(pointer, size);
    return pointer;
}

__attribute__((destructor)) static void report(void) {
    const char* path = getenv("ALLOC_CENSUS_OUT");
    FILE* file;
    int index;
    if (path == NULL) {
        return;
    }
    busy = 1;
    file = fopen(path, "w");
    if (file == NULL) {
        return;
    }
    fprintf(file, "function,size,alignment,calls\n");
    for (index = 0; index < table_size && rows[index].function != NULL; index += 1) {
        if (rows[index].calls >= 100) {
            fprintf(file, "%s,%zu,%zu,%llu\n", rows[index].function, rows[index].size, rows[index].alignment, rows[index].calls);
        }
    }
    fprintf(file, "frees,%llu\n", frees);
    fprintf(file, "aligned_span_bytes,%llu\n", (unsigned long long)(aligned_high - aligned_low));
    fprintf(file, "aligned_page_changes,%llu\n", aligned_new_pages);
    fclose(file);
}
