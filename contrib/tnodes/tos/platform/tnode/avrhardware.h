// $Id: avrhardware.h,v 1.1 2006/03/06 10:07:40 palfrey Exp $

/*									tab:4
 * "Copyright (c) 2000-2003 The Regents of the University  of California.  
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
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
/*
 *
 * Authors:             Jason Hill, Philip Levis, Nelson Lee
 *
 *
 */

/**
 * @author Jason Hill
 * @author Philip Levis
 * @author Nelson Lee
 */


#ifndef TOSH_AVRHARDWARE_H
#define TOSH_AVRHARDWARE_H
// check for a new-look avr-libc
#if defined(DTOSTR_ALWAYS_SIGN) && !defined(TOSH_NEW_AVRLIBC)
#define TOSH_NEW_AVRLIBC
#endif

#ifdef TOSH_NEW_AVRLIBC
#include <avr/io.h>
//#include <avr/signal.h>
#include <avr/interrupt.h>
#include <avr/wdt.h>
#include <avr/pgmspace.h>
#include <avr/eeprom.h>
#else
#include <io.h>
#include <sig-avr.h>
#include <interrupt.h>
#include <wdt.h>
#include <pgmspace.h>
#include <eeprom.h>
#endif /* TOSH_NEW_AVRLIBC */

// check for version 3.3 of GNU gcc or later
#if ((__GNUC__ == 3) && (__GNUC_MINOR__ >= 3))
#define __outw(val, port) outw(port, val);
#endif

#ifdef _AVR_PORTPINS_H_
/* we have a very new avr-libc with certain functions deprecated */

 /** \def cbi 	 
     Clear bit \c bit in IO register \c sfr. */ 	 
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit)) 	 
  	 
 /** \def sbi 	 
     Set bit \c bit in IO register \c sfr. */ 	 
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit)) 	 
  	 
 /** \def inb 	 
     <b>Use direct access in new programs</b>. */ 	 
#define inb(sfr) _SFR_BYTE(sfr) 	 
  	 
 /** \def outb 	 
     <b>Use direct access in new programs</b>. 	 
  	 */ 	 
#define outb(sfr, val) (_SFR_BYTE(sfr) = (val)) 	 
  	 
 /** \def inw 	 
     Read a 16-bit word from IO register pair \c sfr. 	 
  	<b>Use direct access in new programs</b>. */ 	 
#define inw(sfr) _SFR_WORD(sfr) 	 
  	 
 /** \def outw 	 
     Write the 16-bit value \c val to IO register pair \c sfr.  Care 	 
     will be taken to write the lower register first.  When used to 	 
     update 16-bit registers where the timing is critical and the 	 
     operation can be interrupted, the programmer is the responsible for 	 
     disabling interrupts before accessing the register pair. 	 
  	 
     <b>Use direct access in new programs</b>. 	*/ 	 
#define outw(sfr, val) (_SFR_WORD(sfr) = (val)) 	 
  	 
 /** \def outp 	 
     <b>Use direct access in new programs</b>. */ 	 
#define outp(val, sfr) outb(sfr, val) 	 
  	 
 /** \def inp 	 
     <b>Use direct access in new programs</b>. */ 	 
#define inp(sfr) inb(sfr)

#define PRG_RDB(x) pgm_read_byte(x)

#endif

#ifndef __inw
#ifndef __SFR_OFFSET
#define __SFR_OFFSET 0
#endif /* !__SFR_OFFSET */
#define __inw(_port) inw(_port)

#define __inw_atomic(__sfrport) ({				\
	uint16_t __t;					\
	bool bStatus;					\
	bStatus = bit_is_set(SREG,7);			\
	cli();						\
	__t = inw(__sfrport);				\
	if (bStatus) sei();				\
	__t;						\
 })

#endif /* __inw */

#define TOSH_ASSIGN_PIN(name, port, bit) \
static inline void TOSH_SET_##name##_PIN() {sbi(PORT##port , bit);} \
static inline void TOSH_CLR_##name##_PIN() {cbi(PORT##port , bit);} \
static inline int TOSH_READ_##name##_PIN() \
  {return (inp(PIN##port) & (1 << bit)) != 0;} \
static inline void TOSH_MAKE_##name##_OUTPUT() {sbi(DDR##port , bit);} \
static inline void TOSH_MAKE_##name##_INPUT() {cbi(DDR##port , bit);} 

#define TOSH_ASSIGN_OUTPUT_ONLY_PIN(name, port, bit) \
static inline void TOSH_SET_##name##_PIN() {sbi(PORT##port , bit);} \
static inline void TOSH_CLR_##name##_PIN() {cbi(PORT##port , bit);} \
static inline void TOSH_MAKE_##name##_OUTPUT() {;} 

#define TOSH_ALIAS_OUTPUT_ONLY_PIN(alias, connector)\
static inline void TOSH_SET_##alias##_PIN() {TOSH_SET_##connector##_PIN();} \
static inline void TOSH_CLR_##alias##_PIN() {TOSH_CLR_##connector##_PIN();} \
static inline void TOSH_MAKE_##alias##_OUTPUT() {} \

#define TOSH_ALIAS_PIN(alias, connector) \
static inline void TOSH_SET_##alias##_PIN() {TOSH_SET_##connector##_PIN();} \
static inline void TOSH_CLR_##alias##_PIN() {TOSH_CLR_##connector##_PIN();} \
static inline char TOSH_READ_##alias##_PIN() {return TOSH_READ_##connector##_PIN();} \
static inline void TOSH_MAKE_##alias##_OUTPUT() {TOSH_MAKE_##connector##_OUTPUT();} \
static inline void TOSH_MAKE_##alias##_INPUT()  {TOSH_MAKE_##connector##_INPUT();} 

// We need slightly different defs than SIGNAL, INTERRUPT
#define TOSH_SIGNAL(signame)					\
void signame() __attribute__ ((signal, spontaneous, C))

#define TOSH_INTERRUPT(signame)				\
void signame() __attribute__ ((interrupt, spontaneous, C))

/* Watchdog Prescaler
 */
enum {
  TOSH_period16 = 0x00, // 47ms
  TOSH_period32 = 0x01, // 94ms
  TOSH_period64 = 0x02, // 0.19s
  TOSH_period128 = 0x03, // 0.38s
  TOSH_period256 = 0x04, // 0.75s
  TOSH_period512 = 0x05, // 1.5s
  TOSH_period1024 = 0x06, // 3.0s
  TOSH_period2048 = 0x07 // 6.0s
};

void TOSH_wait()
{
  asm volatile("nop");
  asm volatile("nop");
}

void TOSH_sleep(void);

// atomic statement runtime support

typedef uint8_t __nesc_atomic_t;

inline __nesc_atomic_t __nesc_atomic_start(void) __attribute__((spontaneous))
{
  __nesc_atomic_t result = inp(SREG);
  cli();
  return result;
}

inline void __nesc_atomic_end(__nesc_atomic_t oldSreg) __attribute__((spontaneous))
{
  outp(oldSreg, SREG);
}

inline void __nesc_enable_interrupt() {
  sei();
}
#endif //TOSH_AVRHARDWARE_H
