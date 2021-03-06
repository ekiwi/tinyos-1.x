// $Id: PXA27XHPLDMA.nc,v 1.2 2005/09/06 17:49:09 radler Exp $ 

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
 *
 * Authors:             Phil Buonadonna
 * Authors:		Robbie Adler
 
*/


interface PXA27XHPLDMA
{
  async command void setByteAlignment(uint32_t channel,bool enable);
  async command void mapChannel(uint32_t channel,uint16_t peripheralID);
  async command void unmapChannel(uint32_t channel);
  async command void setDCSR(uint32_t channel, uint32_t val);
  async command uint32_t getDCSR(uint32_t channel);
  async command void setDCMD(uint32_t channel, uint32_t val);
  async command uint32_t getDCMD(uint32_t channel);
  async command void setDDADR(uint32_t channel, uint32_t val);
  async command uint32_t getDDADR(uint32_t channel);
  async command void setDSADR(uint32_t channel, uint32_t val);
  async command uint32_t getDSADR(uint32_t channel);
  async command void setDTADR(uint32_t channel, uint32_t val);
  async command uint32_t getDTADR(uint32_t channel);
  async command void setDPCSR(uint32_t val);
  async command uint32_t getDPCSR();
  
}
