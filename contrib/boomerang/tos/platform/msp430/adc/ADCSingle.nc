/*
 * Copyright (c) 2004, Technische Universitaet Berlin
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions 
 * are met:
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright 
 *   notice, this list of conditions and the following disclaimer in the 
 *   documentation and/or other materials provided with the distribution.
 * - Neither the name of the Technische Universitaet Berlin nor the names 
 *   of its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * - Revision -------------------------------------------------------------
 * $Revision: 1.1.1.1 $
 * $Date: 2007/11/05 19:11:31 $
 * @author: Jan Hauer <hauer@tkn.tu-berlin.de>
 * ========================================================================
 */

#include "ADCHIL.h"

interface ADCSingle
{
  /**
    * Initiates one single conversion. The conversion result
    * is signalled in the event <code>dataReady</code>.
    *
    * @return ADC_SUCCESS if the ADC is free and available 
    * to accept the request, error code otherwise (see ADCHIL.h).
    */
  async command adcresult_t getData();

  /**
    * Initiates conversions in repeat mode, ie. continuously.
    * After each conversion an event <code>dataReady</code>
    * is signalled with the conversion result until 
    * the eventhandler returns <code>FAIL</code>.
    *
    * @return ADC_SUCCESS if the ADC is free and available 
    * to accept the request, error code otherwise (see ADCHIL.h).
    */
  async command adcresult_t getDataContinuous();
    
  /**
    * Reserves the ADC for one single conversion.  If this call  
    * succeeds the next call to <code>getData</code> will also succeed 
    * and the corresponding conversion will then be started with a
    * minimum latency.
    *
    * @return ADC_SUCCESS if reservation was successful,
    * to accept the request, error code otherwise (see ADCHIL.h).
    */
  async command adcresult_t reserve();
  
  /**
    * Reserves the ADC for continuous conversions. If this call  
    * succeeds the next call to <code>getDataContinuous/code> will also succeed 
    * and the corresponding conversion will then be started with a
    * minimum latency.
    *
    * @return ADC_SUCCESS if reservation was successful,
    * error code otherwise (see ADCHIL.h).
    */
  async command adcresult_t reserveContinuous();

  /**
    * Cancels a reservation made by <code>reserve</code> or
    * <code>reserveRepeat</code>.
    *
    * @return ADC_SUCCESS if reservation was cancelled successfully,
    * error code otherwise (see ADCHIL.h).
    */
  async command adcresult_t unreserve();
  
  /**
    * Conversion result from call to <code>getData</code> or 
    * <code>getDataRepeat</code> is ready. In the first case
    * the returned value is ignored, in the second it defines
    * whether any further conversions will be made or not.
    *
    * @param result ADC_SUCCESS if the conversion was performed
    * successfully and <code>data</code> is valid, error 
    * code otherwise (see ADCHIL.h).
    * @param data The conversion result, an uninterpreted 
    * 16-bit value.
    *
    * @return SUCCESS continues conversions in continuous mode,
    * FAIL stops further conversions in continuous mode
    * (ignored if not in continuous mode).
    */
  async event result_t dataReady(adcresult_t result, uint16_t data); 
}

