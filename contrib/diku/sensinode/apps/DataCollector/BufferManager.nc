/* Copyright (c) 2007, Marcus Chang, Klaus Madsen
   All rights reserved.

   Redistribution and use in source and binary forms, with or without 
   modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
      this list of conditions and the following disclaimer. 

    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation 
      and/or other materials provided with the distribution. 

    * Neither the name of the Dept. of Computer Science, University of 
      Copenhagen nor the names of its contributors may be used to endorse or 
      promote products derived from this software without specific prior 
      written permission. 

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
   POSSIBILITY OF SUCH DAMAGE.
*/  

/*
        Author:         Marcus Chang <marcus@diku.dk>
                        Klaus S. Madsen <klaussm@diku.dk>
        Last modified:  March, 2007
*/


/*
 *
 *
 */
includes BufferManager;

interface BufferManager {

	command void clear();

  /**
   * Locates a free packet in the buffer-pool, and returns it. If
   * there is no free packets NULL is returned, and getFailure is
   * signaled.
   *
   * @return A free packet, or NULL if no free packets exists
   */
	command page_t * get(uint16_t page); 

  /**
   * Returns a packet to the buffer-pool. If successful, the function
   * will return SUCCESS. Otherwise it returns FAIL, and putFailure is
   * signalled.
   *
   * @return SUCCESS, if the packet could be returned.
   */
	command result_t free(uint16_t page);

	command uint8_t freeBuffers();

}
