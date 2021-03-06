/*
 * Copyright (c) 2004, Technische Universität Berlin
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
 * - Neither the name of the Technische Universität Berlin nor the names 
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
 * - Description ----------------------------------------------------------
 * Byte-level interface to control a USART. 
 * <p>The USART can be switched to SPI- or UART-mode. The interface follows
 * the convention of being stateless, thus a higher layer has to maintain
 * state information. I.e. calling <code>tx</done> will transmit a byte of
 * data in the mode (SPI or UART) the USART has been set to before.
 * - Revision -------------------------------------------------------------
 * $Revision: 1.1 $
 * $Date: 2005/07/29 18:29:30 $
 * @author: Jan Hauer (hauer@tkn.tu-berlin.de)
 * ========================================================================
 */
 
interface HPLUSARTControl {

 /**
   * Enables both the Rx and the Tx UART modules.
   */
  async command void enableUART();
  
 /**
   * Disables both the Rx and the Tx UART modules.
   */
  async command void disableUART();
 
 /**
   * Enables the UART TX functionality of the USART module.
   */
  async command void enableUARTTx();

 /**
   * Disables the UART TX module.
   */
  async command void disableUARTTx();

 /**
   * Enables the UART RX functionality of the USART module.
   */
  async command void enableUARTRx();

 /**
   * Disables the UART RX module.
   */
  async command void disableUARTRx();
  
 /**
   * Enables the USART when in SPI mode.
   */
  async command void enableSPI();
  
 /**
   * Disables the USART when in SPI mode.
   */
  async command void disableSPI();
  
 /**
   * Switches USART to SPI mode.
   */
  async command void setModeSPI();
	
 /**
   * Switches USART to UART TX mode (RX pins disabled).
   * Interrupts disabled by default.
   */	
  async command void setModeUART_TX();
	
 /**
   * Switches USART to UART RX mode (TX pins disabled)..
   * Interrupts disabled by default.
   */	
  async command void setModeUART_RX();

 /**
   * Switches USART to UART mode (RX and TX enabled)
   * Interrupts disabled by default.
   */	
  async command void setModeUART();
 
  async command void setClockSource(uint8_t source);

  async command void setClockRate(uint16_t baudrate, uint8_t mctl);

  /* Dis/enabling of UTXIFG / URXIFG */
  async command result_t disableRxIntr();
  async command result_t disableTxIntr();
  async command result_t enableRxIntr();
  async command result_t enableTxIntr();
 
  /**
   * SUCCESS if TX interrupt pending, flag is cleared automatically 
   */
  async command result_t isTxIntrPending();

  /**
   * SUCCESS if RX interrupt pending, flag is cleared automatically 
   */
  async command result_t isRxIntrPending();

  /** 
   * SUCCESS if the TX buffer is empty and all of the bits have been
   * shifted out 
   */
  async command result_t isTxEmpty();

 /**
   * Transmit a byte of data. When the transmission is completed,
   * <code>txDone</done> is generated. Only then a new byte may be
   * transmitted, otherwise the previous byte will be overwritten.
   * The mode of transmission (UART or SPI) depends on the current state
   * of the USART, which must be managed by a higher layer.
   *
   * @return SUCCESS always.
   */
  async command result_t tx(uint8_t data);

  /**
   * Get current value from RX-buffer.
   *
   * @return SUCCESS always.
   */
  async command uint8_t rx();

}

