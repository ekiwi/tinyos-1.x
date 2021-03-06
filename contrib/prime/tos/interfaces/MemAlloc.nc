/*									tab:4
 *
 *
 * "Copyright (c) 2000-2002 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 */
/*									tab:4
 *  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.  By
 *  downloading, copying, installing or using the software you agree to
 *  this license.  If you do not agree to this license, do not download,
 *  install, copy or use the software.
 *
 *  Intel Open Source License 
 *
 *  Copyright (c) 2002 Intel Corporation 
 *  All rights reserved. 
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 * 
 *	Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 *	Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 *      Neither the name of the Intel Corporation nor the names of its
 *  contributors may be used to endorse or promote products derived from
 *  this software without specific prior written permission.
 *  
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 *  PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE INTEL OR ITS
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * 
 */
/*
 * Authors:		Sam Madden, Philip Levis
 * Date last modified:  6/25/02
 */

includes MemAlloc;

/**
 * Interface for dynamic memory allocators.
 */
  

interface MemAlloc {

  /**
   * Allocate a memory region.
   *
   * @param handle Handle to memory region (to be filled in).
   *
   * @param size Size of region in bytes.
   *
   * @return SUCCESS if allocated, FAIL otherwise.
   */
  
  command result_t allocate(HandlePtr handle, int16_t size);

  /**
   * Reallocate a region to a new size, copying data over.
   *
   * @param handle Region to resize.
   *
   * @param size New size.
   *
   * @return SUCCESS if reallocated, FAIL otherwise.
   */

  command result_t reallocate(Handle handle, int16_t size);

  /**
   * Lock a memory region from being compacted. This is needed if
   * pointers within it are passed around.
   *
   * @param handle Handle to region to lock.
   *
   * @return SUCCESS if locked successfuly, FAIL otherwise.
   */
  
  command result_t lock(Handle handle);

  /**
   * Unlock a memory region to allow its compaction. 
   *
   * @param handle Handle to region to unlock.
   *
   * @return SUCCESS if unlocked successfuly, FAIL otherwise.
   */
  
  command result_t unlock(Handle handle);

  /**
   * Deallocate a memory region and return it to allocatable memory.
   *
   * @param handle Handle to region to free.
   *
   * @return Size of freed region.
   */
  
  command int16_t free(Handle handle);

  /**
   * Compact the allocated regions to prevent fragmentation.
   *
   * @return Whether the request to compact was accepted.
   */
  
  command result_t compact();

  /**
   * Get the size of a memory region.
   *
   * @param A memory region.
   *
   * @return The region's size.
   */

  command int16_t size(Handle handle);

  /**
   * Get whether a region is locked from compaction.
   *
   * @param handle The region to check.
   *
   * @return Whether the region is locked.
   *
   */

  command bool  isLocked(Handle handle);

  /**
   * Return the number of free bytes available in the
   * heap.  This is the sum of all free blocks; even
   * after compaction, a single block of this size
   * may not be available if there are locked handles
   * in the heap.
   *
   * @return The number of free bytes.
   */
  command uint16_t freeBytes();

  /**
   * Signals when an allocation request has completed.
   *
   * @param handle The handle to the requested region.
   *
   * @param success Whether the allocation was successful.
   *
   * @return Should always return SUCCESS.
   *
   */

  event result_t allocComplete(HandlePtr handle, result_t success);

   /**
   * Signals when an reallocation request has completed.
   *
   * @param handle The handle to the requested region.
   *
   * @param success Whether the reallocation was successful.
   *
   * @return Should always return SUCCESS.
   *
   */
  
  event result_t reallocComplete(Handle handle, result_t success);

 /**
   * Signals when a compaction request has completed.
   *
   * @return Should always return SUCCESS.
   *
   */
  
  event result_t compactComplete();
}

