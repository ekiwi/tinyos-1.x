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
 * Authors:  Wei Hong
 *           Intel Research Berkeley Lab
 * Date:     7/1/2002
 *
 */
// component to expose Temperature sensor reading as an attribute
module AttrVoltageM
{
	provides interface StdControl;
	uses 
	{
		interface StdControl as SubControl;
		interface ADC;
		interface AttrRegister;
	}
}
implementation
{
	char *result;
	char *attrName;

	command result_t StdControl.init()
	{
	  if (call AttrRegister.registerAttr("voltage", UINT16, 2) != SUCCESS)
			return FAIL;
		return SUCCESS;
	}

	command result_t StdControl.start()
	{
	  return SUCCESS;
	}

	command result_t StdControl.stop()
	{
	  return SUCCESS;
	}

	event result_t AttrRegister.startAttr()
	{
		return call AttrRegister.startAttrDone();
	}

	event result_t AttrRegister.getAttr(char *name, char *resultBuf, SchemaErrorNo *errorNo)
	{
		result = resultBuf;
		attrName = name;
#ifdef PLATFORM_MICA2DOT
		TOSH_CLR_PW7_PIN();
		TOSH_MAKE_PW7_OUTPUT();
		TOSH_CLR_PW6_PIN();
		TOSH_MAKE_PW6_INPUT();
#endif
		if (call ADC.getData() != SUCCESS)
			return FAIL;
		*errorNo = SCHEMA_RESULT_PENDING;
		return SUCCESS;
	}

	event result_t ADC.dataReady(uint16_t data)
	{
		*(uint16_t*)result = data;
#ifdef PLATFORM_MICA2DOT
		TOSH_SET_PW7_PIN();
		TOSH_MAKE_PW7_INPUT();
#endif
		call AttrRegister.getAttrDone(attrName, result, SCHEMA_RESULT_READY);
		return SUCCESS;
	}

	event result_t AttrRegister.setAttr(char *name, char *attrVal)
	{
		return FAIL;
	}
}
