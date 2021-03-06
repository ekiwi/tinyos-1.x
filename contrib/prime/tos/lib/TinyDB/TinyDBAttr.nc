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
includes Attr;

configuration TinyDBAttr {
  provides interface AttrUse;
  provides interface StdControl;
}

implementation {
  components Attr, AttrPot, AttrGlobal, TinyDBAttrM, TupleRouterM, AttrTime,
  TinyAlloc, NETWORK_MODULE
#ifdef kEEPROM_ATTR
, AttrLog
#endif
#if !defined(PLATFORM_PC)
, AttrVoltage
#endif
#ifdef BOARD_MICASB
, AttrTemp, AttrPhoto
#if !defined(PLATFORM_PC)
    , AttrAccel
# ifdef kUSE_MAGNETOMETER
    , AttrMag
# endif
    , AttrMic
#endif
#endif /* BOARD_MICASB */
#if defined(BOARD_MICAWB) || defined(BOARD_MICAWBDOT)
#ifdef PLATFORM_MICA2DOT
	, AttrHumidity, AttrTaosPhoto, AttrPressure, AttrHamamaTsu // , AttrMelexis
#endif
#endif /* BOARD_MICAWB */
    ;
  AttrUse = Attr.AttrUse;

  AttrGlobal.StdControl = StdControl;
  AttrPot.StdControl = StdControl;
  AttrTime.StdControl = StdControl;
#ifdef kEEPROM_ATTR
  AttrLog.StdControl = StdControl;
#endif
  TinyDBAttrM.StdControl = StdControl;
#if !defined(PLATFORM_PC)
  AttrVoltage.StdControl = StdControl;
#endif

#ifdef BOARD_MICASB
  AttrPhoto.StdControl = StdControl;
  AttrTemp.StdControl = StdControl;
#if !defined(PLATFORM_PC)
  AttrAccel.StdControl = StdControl;
#ifdef kUSE_MAGENTOMETER
  AttrMag.StdControl = StdControl;
#endif
  AttrMic.StdControl = StdControl;
#endif
#endif /* BOARD_MICASB */
#if defined(BOARD_MICAWB) || defined(BOARD_MICAWBDOT)
#ifdef PLATFORM_MICA2DOT
  AttrHumidity.StdControl = StdControl;
  AttrTaosPhoto.StdControl = StdControl;
  AttrPressure.StdControl = StdControl;
  AttrHamamaTsu.StdControl = StdControl;
  // AttrMelexis.StdControl = StdControl;
#endif
#endif /* BOARD_MICAWB */
  TinyDBAttrM.ParentAttr -> Attr.Attr[unique("Attr")];
#ifdef kCONTENT_ATTR
  TinyDBAttrM.ContentionAttr -> Attr.Attr[unique("Attr")];
#endif
  TinyDBAttrM.FreeSpaceAttr -> Attr.Attr[unique("Attr")];
  TinyDBAttrM.QueueLenAttr -> Attr.Attr[unique("Attr")];
  TinyDBAttrM.MHQueueLenAttr -> Attr.Attr[unique("Attr")];
  TinyDBAttrM.DepthAttr -> Attr.Attr[unique("Attr")];
  TinyDBAttrM.QidAttr -> Attr.Attr[unique("Attr")];
  // TinyDBAttrM.XmitCountAttr -> Attr.Attr[unique("Attr")];
  TinyDBAttrM.QualityAttr -> Attr.Attr[unique("Attr")];
  TinyDBAttrM.QueryProcessor -> TupleRouterM;
  TinyDBAttrM.NetworkMonitor -> NETWORK_MODULE;
  TinyDBAttrM.MemAlloc -> TinyAlloc;
}
