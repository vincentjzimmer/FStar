/*
   Copyright 2015 Michael Hicks, Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include "stack.h"
#include "bitmask.h"

#define check(_p) if (!(_p)) { fprintf(stderr,"Failed check %s:%d\n",__FILE__,__LINE__); fflush(stdout); exit(1); }
#define assert check
#define max(a,b) (a>b?a:b)

#define WORD_SZB sizeof(void*)

typedef struct _Page {
  void* memory;
  void* alloc_ptr;
  void* limit_ptr;
  void** frame_ptr;
  struct _Page *prev;
  unsigned char pointermap[0];
} Page;

#define EXT_MARKER (void **)0x1

/* INVARIANTS:
   frame_ptr == NULL || frame_ptr == EXT_MARKER || location of stored frameptr
 */

static Page *top = NULL;

static inline int align(int n, int blocksize) {
  return n % blocksize == 0 ? n : blocksize * ((n / blocksize) + 1);
}

static inline int word_align(int bytes) {
  return align(bytes,WORD_SZB);
}

static inline int byte_align(int bits) {
  return align(bits,8);
}

static inline int have_space(int sz_b) {
  return (((unsigned long)top->limit_ptr - (unsigned long)top->alloc_ptr) >= sz_b);
}

static void add_page(int sz_b, int is_ext) {
  sz_b = word_align(max(2*sz_b,DEFAULT_PAGE_SZB));
  int mapsz_b = byte_align(sz_b/WORD_SZB)/8;
  Page *region = malloc(sizeof(Page)+mapsz_b);
  printf ("add page size = %d, ext = %d, map size = %d\n", sz_b, is_ext, mapsz_b);
  void* memory = malloc(sz_b);
  check (region != NULL);
  check (memory != NULL);
  region->memory = memory;
  region->alloc_ptr = memory;
  region->limit_ptr = (void *)((unsigned long)memory + (unsigned long)sz_b);
  region->frame_ptr = is_ext ? EXT_MARKER : NULL;
  region->prev = top;
  top = region;
}

void push_frame(int sz_b) {
  sz_b = word_align(sz_b);
  if (top != NULL && have_space(sz_b+sizeof(void*))) { // can continue with current page
    //printf("push frame in page\n");
    *((void **)top->alloc_ptr) = top->frame_ptr;
    top->frame_ptr = top->alloc_ptr;
    top->alloc_ptr = (void *)((unsigned long)top->alloc_ptr + WORD_SZB);
  } else {
    //printf("push frame on new page\n");
    add_page(sz_b,0);
  }
}

void pop_frame() {
  if (top->frame_ptr != NULL && top->frame_ptr != EXT_MARKER) {
    //printf ("pop frame on page\n");
    top->alloc_ptr = top->frame_ptr;
    top->frame_ptr = *((void **)top->alloc_ptr);
  } else {
    Page *prev = top->prev;
    void **fp = top->frame_ptr;
    //printf ("pop frame and free page\n");
    //for debugging:
    //memset(top->memory, 255, ((unsigned long)top->limit_ptr - (unsigned long)top->memory));
    free(top->memory);
    free(top);
    top = prev;
    if (fp == EXT_MARKER) {
      //printf ("recursively pop frame\n");
      pop_frame();
    }
  }
}

void *stack_alloc_mask(int sz_b, int nbits, ...) {
  va_list argp;
  assert(top != NULL);
  sz_b = word_align(sz_b);
 retry: if (have_space(sz_b)) { // can continue with current page
    void *res = top->alloc_ptr;
    //printf("allocated %d bytes\n", sz_b);
    int ofs = res - top->memory; // #words into the page
    int i;
    top->alloc_ptr = (void *)((unsigned long)top->alloc_ptr + sz_b);
    unsetbit_rng(top->pointermap, ofs, sz_b / WORD_SZB);
    va_start(argp, nbits);
    while (nbits != 0) {
      i = va_arg(argp, int);
      setbit(top->pointermap, i+ofs);
      nbits--;
    }
    va_end(argp);
    return res;
  } else {
    //printf("adding page on demand\n");
    add_page(sz_b,1);
    goto retry;
  }
}

void *stack_alloc(int sz_b) {
  return stack_alloc_mask(sz_b, 0);
}

int is_stack_pointer(void *ptr) {
  Page *tmp = top;
  while (tmp != NULL) {
    if (tmp->memory <= ptr && tmp->alloc_ptr > ptr)
      return 1;
    tmp = tmp->prev;
  }
  return 0;
}

// running a callback on each marked word
struct ptrenv { 
  void **memory; 
  ptrfun f;
  void *env;
};

void ptrbitfun(void *env, int index) {
  struct ptrenv *penv = (struct ptrenv *)env;
  void **ptr = &(penv->memory[index]);
  penv->f(penv->env,ptr);
}

void each_marked_pointer(ptrfun f, void *env) {
  Page *tmp = top;
  struct ptrenv penv = { 0, f, env };
  while (tmp != NULL) {
    int maxbit = tmp->alloc_ptr - tmp->memory; // XXX is this right?
    penv.memory = (void**)tmp->memory;
    eachbit(tmp->pointermap, maxbit, ptrbitfun, (void *)&penv);
    tmp = tmp->prev;
  }
}

/* To Test:

- See that it marks the right pointers
- See that clears the map properly

To implement:

- Scanning in terms of each_marked_pointer

*/
