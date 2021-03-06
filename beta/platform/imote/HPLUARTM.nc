/*
 * Copyright (c) 2004, Intel Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * Neither the name of the Intel Corporation nor the names of its contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

// The hardware presentation layer. See hpl.h for the C side.
// Note: there's a separate C side (hpl.h) to get access to the avr macros

// The model is that HPL is stateless. If the desired interface is as stateless
// it can be implemented here (Clock, FlashBitSPI). Otherwise you should
// create a separate component

module HPLUARTM {
    provides interface HPLUART as UART;
    uses interface HPLDMAUart;
}

implementation
{
    
    #define DEFAULT_BAUDRATE eTM_B115200
    
    uint8 *LocalTxByteBuffer, *LocalRxByteBuffer;
    extern tTOSBufferVar *TOSBuffer __attribute__ ((C)); 

    async command result_t UART.init() {
        char *buf;
        result_t ret;
        
        atomic {
          LocalTxByteBuffer = TOSBuffer->UARTTxBuffer;
          LocalRxByteBuffer = TOSBuffer->UARTRxBuffer;
        }

        ret = call HPLDMAUart.init(DEFAULT_BAUDRATE);
        if(ret==SUCCESS){
            atomic buf = LocalRxByteBuffer;
            call HPLDMAUart.start(buf, 1);
        }
        return ret;
    }
    
    async command result_t UART.stop() {
        return call HPLDMAUart.stop();
    }
    
    
    default async event result_t UART.get(uint8 data) { return SUCCESS; }
    
    event uint8* HPLDMAUart.get(uint8 *data, uint16 NumBytes){
        char *ret;

        signal UART.get(*data);
        atomic ret = LocalRxByteBuffer;
        return ret;
    }
  
  default async event result_t UART.putDone() { return SUCCESS; }

  event result_t HPLDMAUart.putDone(uint8 *data){
      return signal UART.putDone();
  }

  async command result_t UART.put(uint8_t data) {
      char *buf;
      atomic {
        *LocalTxByteBuffer = data;
        buf = LocalTxByteBuffer;
      }
      
      call HPLDMAUart.put(buf,1);      
      return SUCCESS;
  }
}
