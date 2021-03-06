/**
 * Copyright (c) 2008 - George Mason University
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs, and the author attribution appear in all copies of this
 * software.
 *
 * IN NO EVENT SHALL GEORGE MASON UNIVERSITY BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF GEORGE MASON
 * UNIVERSITY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *      
 * GEORGE MASON UNIVERSITY SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND GEORGE MASON UNIVERSITY HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 **/

/**
 * @author Leijun Huang <lhuang2@gmu.edu>
 **/

module SystemTimeM {
    provides interface SystemTime;
    uses interface LocalTime; 
}

implementation {

    uint32_t delta = 0;
    bool forward = FALSE;

    command uint32_t SystemTime.getCurrentTimeTicks() {
        uint32_t ticks = call LocalTime.read();
        if (forward == TRUE) ticks += delta;
        else ticks -= delta;
        return ticks;
    }

    command uint32_t SystemTime.getCurrentTimeMillis() {
        uint32_t ticks = call LocalTime.read();
        if (forward == TRUE) ticks += delta;
        else ticks -= delta;
        
        // Telosb uses 32KHz clock.
        // 1 sec = 1024 ms, as used in timers.
        // x / 32 = (x >> 5)

        return (ticks >> 5);
    }

    command void SystemTime.setCurrentTimeTicks(uint32_t ticks) {
        uint32_t localTicks = call LocalTime.read();
        if (localTicks < ticks) {
            delta = ticks - localTicks;
            forward = TRUE;
        } else {
            delta = localTicks - ticks;
            forward = FALSE;
        }
    }
}
