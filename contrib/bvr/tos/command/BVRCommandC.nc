// ex: set tabstop=2 shiftwidth=2 expandtab syn=c:
// $Id: BVRCommandC.nc,v 1.1.1.1 2005/06/19 04:34:38 rfonseca76 Exp $
                                    
/*                                                                      
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
 * Authors:  Rodrigo Fonseca        
 * Date Last Modified: 2005/05/26
 */

configuration BVRCommandC {
  provides {
    interface StdControl;
  }
  uses {
    command result_t routeTo(Coordinates *coords, uint16_t addr, uint8_t mode);
  }
}

implementation {
  components BVRCommandM 
  	       , BVRCommStack as CommandComm //assumes StdControl elsewhere
	         , BVRStateC as BVRState       //assumes StdControl elsewhere
           , ResetC
           , IdentM
           , RandomLFSR as Random
           , LedsC as Leds
           , TimerC //assumes StdControl elsewhere
           ;
#if defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
  components CC1000RadioC;
#endif //PLATFORM_MICA2

  components LinkEstimatorC, CoordinateTableC;
  components LinkEstimatorComm;
  components BVRQueuedSendM;
  
 
  StdControl = BVRCommandM;

  routeTo = BVRCommandM.routeTo;

  BVRCommandM.CmdReceive -> CommandComm.ReceiveMsg[AM_BVR_COMMAND_MSG];
  BVRCommandM.ResponseSend -> CommandComm.SendMsg[AM_BVR_COMMAND_RESPONSE_MSG];

#if defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT)
  BVRCommandM.CC -> CC1000RadioC;
#endif

  BVRCommandM.LinkEstimator -> LinkEstimatorC;
  BVRCommandM.CoordinateTable -> CoordinateTableC;

  /* FreezeThaw interfaces wiring */
  BVRCommandM.LinkEstimatorFT -> LinkEstimatorC;
  BVRCommandM.LinkEstimatorCommFT -> LinkEstimatorComm;
  BVRCommandM.CoordinateTableFT -> CoordinateTableC;
  BVRCommandM.BVRStateFT -> BVRState;

  BVRCommandM.QueueCommand -> BVRQueuedSendM;

  
  BVRCommandM.Random -> Random;
  BVRCommandM.Leds -> Leds;
  BVRCommandM.DelayTimer -> TimerC.Timer[unique("Timer")];
  BVRCommandM.BVRStateCommand -> BVRState;
  BVRCommandM.Reset -> ResetC;
  BVRCommandM.Ident -> IdentM;

}
  

