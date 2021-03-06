/*
 * Copyright (c) 2004-2005 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
module MotlleRepM
{
  provides interface MotlleValues as V;
  uses interface MotlleGC as GC;
}
implementation
{
  /* See BaseTypes.h for representation discussion */
  enum {
    kind_int = 0,
    kind_atom = 1,
    kind_ptr = 2
  };

  typedef uint16_t uvalue;

  bool isFloat(mvalue x) {
    return !((x & 1) && (x >> 23) == 511);
  }

  float asFloat(mvalue x) {
    char fun[4];

    fun[0] = x;
    fun[1] = x >> 8;
    fun[2] = x >> 16;
    fun[3] = x >> 24;
    return *(float *)fun;
  }

  uvalue as16(mvalue x) {
    return x >> 3;
  }

  uint8_t kind16(mvalue x) {
    return (x >> 1) & 3;
  }

  mvalue make16(uint8_t kind, uvalue value) {
    return 511L << 23 | value << 3 | kind << 1 | 1;
  }

  msize size_align(msize n) {
    return ALIGN(n, MOTLLE_HEAP_ALIGNMENT);
  }

  command mvalue V.read(svalue *location) {
#ifdef PLATFORM_LITTLE_ENDIAN
    return (mvalue)*location;
#else
    return call V.read_unaligned(location);
#endif
}

  command mvalue V.read_unaligned(svalue *location) {
#if defined(PLATFORM_REQUIRES_ALIGNMENT) || !defined(PLATFORM_LITTLE_ENDIAN)
    uint8_t *loc = (uint8_t *)location;

    return (mvalue)loc[0] | (mvalue)loc[1] << 8 |
      (mvalue)loc[2] << 16 | (mvalue)loc[3] << 24;
#else
    return call V.read(location);
#endif
  }

  command void V.write(svalue *location, mvalue x) {
#ifdef PLATFORM_LITTLE_ENDIAN
    *location = (svalue)x;
#else
    uint8_t *loc = (uint8_t *)location;
    loc[0] = x;
    loc[1] = x >> 8;
    loc[2] = x >> 16;
    loc[3] = x >> 24;
#endif
  }


  // Categories

  // integers (unboxed)
  command bool V.integerp(mvalue x) {
    return !isFloat(x) && kind16(x) == kind_int;
  }

  command ivalue V.integer(mvalue x) {
    return (ivalue)as16(x);
  }

  command mvalue V.make_integer(ivalue x) {
    return make16(kind_int, x);
  }

  // floats (unboxed)
  command bool V.realp(mvalue x) {
    return isFloat(x);
  }

  command float V.real(mvalue x) {
    return asFloat(x);
  }

  command mvalue V.make_real(float x) {
    unsigned char *fun = (unsigned char *)&x;

    return (mvalue)fun[0] | (mvalue)fun[1] << 8 | (mvalue)fun[2] << 16 | (mvalue)fun[3] << 24;
  }

  // atoms
  command bool V.atomp(mvalue x) {
    return !isFloat(x) && kind16(x) == kind_atom;
  }

  command avalue V.atom(mvalue x) {
    return (avalue)as16(x);
  }

  command mvalue V.make_atom(avalue x) {
    return make16(kind_atom, x);
  }

  // boxed objects
  command bool V.pointerp(mvalue x) {
    return !isFloat(x) && kind16(x) == kind_ptr;
  }

  command pvalue V.pointer(mvalue x) {
    return (pvalue)as16(x);
  }

  command mvalue V.make_pointer(pvalue x) {
    return make16(kind_ptr, (uvalue)x);
  }

  /* header, etc as in rep-16 */

  uint8_t *objbase(pvalue x) {
    return call GC.base() + (uvalue)x;
  }

  command void *V.skip_header(uint8_t *baseptr) {
    return baseptr + sizeof(uint16_t);
  }

  uint16_t header(pvalue x) {
    uint8_t *base = objbase(x);

    return (uvalue)base[0] | (uvalue)base[1] << 8;
  }

  command msize V.size(pvalue x) {
    return header(x) >> 4;
  }

  command msize V.fullsize(pvalue x) {
    return size_align(header(x) >> 4) + sizeof(uint16_t);
  }

  command mtype V.ptype(pvalue x) {
    return (header(x) & 0xf) >> 1;
  }

  command void *V.data(pvalue x) {
    return call V.skip_header(objbase(x));
  }

  command pvalue V.make_pvalue(void *x) {
    return (pvalue)((uint8_t *)x - sizeof(uint16_t) - call GC.base());
  }

  command bool V.forwardedp(pvalue x) {
    return header(x) & 1;
  }

  command pvalue V.forward(pvalue old, uint8_t *to, msize gc_offset, msize fullsize) {
    pvalue newv = (pvalue)(to - call GC.base() + gc_offset);
    uint8_t *oldhdr = objbase(old);
    uint16_t fw;

    memcpy(to, oldhdr, fullsize);
    fw = (uvalue)newv | 1;
    oldhdr[0] = fw;
    oldhdr[1] = fw >> 8;

    return newv;
  }

  command pvalue V.forward_get(pvalue old) {
    return (pvalue)(header(old) & ~1);
  }

  // load-time relocation (this is here, because value representation
  // may obviate the need for relocation...)
  command void V.relocate(void *loaded, msize size) {
  }

  command void *V.allocate(mtype type, msize size) {
    uint16_t hdr = size << 4 | type << 1;
    uint8_t *newp = call GC.allocate(size_align(size) + sizeof(uint16_t));

    if (!newp)
      return NULL;

    newp[0] = hdr;
    newp[1] = hdr >> 8;

    return call V.skip_header(newp);
  }

  command bool V.truep(mvalue x) {
    return !(x == call V.make_integer(0) ||
	     (x & ~(1L << 31)) == 0); /* +/-0.0 */
  }

  // Marks. Use the forwarding bits, so don't use if GC can occur!
  command void V.mark(mvalue x) {
    if (call V.pointerp(x))
      {
	uint8_t *hdr = objbase(call V.pointer(x));

	hdr[0] |= 1;
      }
  }

  command void V.unmark(mvalue x) {
    if (call V.pointerp(x))
      {
	uint8_t *hdr = objbase(call V.pointer(x));

	hdr[0] &= ~1;
      }
  }

  command bool V.marked(mvalue x) {
    return call V.pointerp(x) && call V.forwardedp(call V.pointer(x));
  }
}
