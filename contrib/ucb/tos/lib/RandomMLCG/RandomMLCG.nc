/*
 * "Copyright (c) 2002-2005 The Regents of the University  of California.  
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
 */
/*
 *
 * Author:		Barbara Hohlt	
 * Date last modified:  02/28/05
 *
 */
/* This code is a fast implementation of the Park-Miller Minimal Standard 
 * Generator for pseudo-random numbers.  It uses the 32 bit multiplicative 
 * linear congruential generator, 
 *
 *		S' = (A x S) mod (2^31 - 1) 
 *
 * for A = 16807.
 */

/**
 * @author Barbara Hohlt 
 */

module RandomMLCG
{
  provides interface Random32;  /* for 32 bit */
}
implementation
{
    uint32_t seed ;

  /* Initialize the seed from the ID of the node */
  async command result_t Random32.init() {
    dbg(DBG_BOOT, "RANDOM_MLCG initialized.\n");
    atomic  seed = (uint32_t)(TOS_LOCAL_ADDRESS + 1);
    
    return SUCCESS;
  }

  /* Initialize with 16-bit seed */ 
  async command result_t Random32.initSeed(uint16_t s) {
    dbg(DBG_BOOT, "RANDOM_MLCG initialized.\n");
    atomic  seed = (uint32_t)(s + 1);
    
    return SUCCESS;
  }

  /* Return the next 32 bit random number */
  async command uint32_t Random32.rand32() {
    uint32_t mlcg,p,q ;
    uint64_t tmpseed  ;
    atomic {
	tmpseed =  (uint64_t)33614U * (uint64_t)seed;
	q = (uint32_t)(tmpseed & 0xFFFFFFFF); 	/* low */
	q = q >> 1;
	p = (uint32_t)(tmpseed >> 32) ;		/* hi */
	mlcg = p + q;
        if (mlcg & 0x80000000) { 
	    mlcg = mlcg & 0x7FFFFFFF;
	    mlcg++;
	}
	seed = mlcg;
    }
    return mlcg; 
  }

 /* Return low 16 bits of 32 bit number */
 inline uint16_t getLow16(uint32_t num) {
    uint16_t l;
    atomic l = (uint16_t)(num & 0xFFFF);
    return l;
 }

  /* Return low 16 bits of next 32 bit random number */
  async command uint16_t Random32.rand16() {
    uint32_t mlcg;

    mlcg = call Random32.rand32();

    return getLow16(mlcg);
  }

#if 0
 /* Return high 16 bits of 32 bit number */
 inline uint16_t getHigh16(uint32_t num) {
    uint16_t h;
    atomic h = (uint16_t)((num >> 16) & 0xFFFF);
    return h;
 }
#endif
}
