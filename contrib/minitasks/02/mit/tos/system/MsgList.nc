/*
 * Copyright (c) 2002, Vanderbilt University
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE VANDERBILT UNIVERSITY BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE VANDERBILT
 * UNIVERSITY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE VANDERBILT UNIVERSITY SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE VANDERBILT UNIVERSITY HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 *
 * Author: Miklos Maroti, Gabor Pap
 * Date last modified: 5/14/03
 */

interface MsgList {
    /*
     This method must always be called first on a list!
    */
    command void init(TOS_MsgList *list);
    
    command bool isEmpty(TOS_MsgList *list);
    
    command TOS_MsgPtr getFirst(TOS_MsgList *list);
    
    command TOS_MsgPtr next(TOS_MsgPtr elem);
    
    command void addFirst(TOS_MsgList *list, TOS_MsgPtr elem);
    
    command void addLast(TOS_MsgList *list, TOS_MsgPtr elem);
    
    command void addAll(TOS_MsgList *list, TOS_MsgPtr first, uint8_t size);
    
    command TOS_MsgPtr removeFirst(TOS_MsgList *list);
}
