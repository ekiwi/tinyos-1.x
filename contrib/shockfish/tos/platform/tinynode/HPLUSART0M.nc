/*
 * Copyright (c) 2004-2005, Technische Universitat Berlin
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
 * - Neither the name of the Technische Universitat Berlin nor the names 
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
 * Implementation of USART0 lowlevel functionality - stateless.
 * Setting a mode will by default disable USART-Interrupts.
 * - Revision -------------------------------------------------------------
 * $Revision: 1.2 $
 * $Date: 2005/10/09 21:30:33 $
 * @author: Jan Hauer (hauer@tkn.tu-berlin.de)
 * @author: Joe Polastre
 * ========================================================================
 */

module HPLUSART0M {
  provides interface HPLUSARTControl as USARTControl;
  provides interface HPLUSARTFeedback as USARTData;
  provides interface HPLI2CInterrupt;
}
implementation
{
  MSP430REG_NORACE(IE1);
  MSP430REG_NORACE(ME1);
  MSP430REG_NORACE(IFG1);
  MSP430REG_NORACE(U0TCTL);
  MSP430REG_NORACE(U0TXBUF);
  MSP430REG_NORACE(U1TXBUF);

  uint16_t l_br;
  uint8_t l_mctl;
  uint8_t l_ssel;

  TOSH_SIGNAL(UART0RX_VECTOR) {
    uint8_t temp = U0RXBUF;
    signal USARTData.rxDone(temp);
  }
  
  TOSH_SIGNAL(UART0TX_VECTOR) {
    if (call USARTControl.isI2C())
      signal HPLI2CInterrupt.fired();
    else
      signal USARTData.txDone();
  }

  default async event void HPLI2CInterrupt.fired() { }
  
  async command bool USARTControl.isSPI() {
    bool _ret = FALSE;
    atomic{
      if (ME1 & USPIE0)
	_ret = TRUE;
    }
    return _ret;
  }
  
  async command bool USARTControl.isUART() {
    bool _ret = FALSE;
    atomic {
      if ((ME1 & UTXE0) && (ME1 & URXE0) &&
          TOSH_IS_URXD0_MODFUNC() &&
          TOSH_IS_UTXD0_MODFUNC())
	_ret = TRUE;
    }
    return _ret;
  }

  async command bool USARTControl.isUARTtx() {
    bool _ret = FALSE;
    atomic {
      if ((ME1 & UTXE0) && 
          TOSH_IS_UTXD0_MODFUNC() &&
          TOSH_IS_URXD0_IOFUNC())
	_ret = TRUE;
    }
    return _ret;
  }

  async command bool USARTControl.isUARTrx() {
    bool _ret = FALSE;
    atomic {
      if ((ME1 & URXE0) && 
          TOSH_IS_URXD0_MODFUNC() &&
          TOSH_IS_UTXD0_IOFUNC())
	_ret = TRUE;
    }
    return _ret;
  }
  
  async command bool USARTControl.isI2C() {
    bool _ret = FALSE;
#ifdef __msp430_have_usart0_with_i2c
    atomic {
      if ((U0CTL & I2C) && (U0CTL & SYNC) && (U0CTL & I2CEN))
	_ret = TRUE;
    }
#endif
    return _ret;
  }

  async command msp430_usartmode_t USARTControl.getMode() {
    if (call USARTControl.isUART())
      return USART_UART;
    else if (call USARTControl.isUARTrx())
      return USART_UART_RX;
    else if (call USARTControl.isUARTtx())
      return USART_UART_TX;
    else if (call USARTControl.isSPI())
      return USART_SPI;
    else if (call USARTControl.isI2C())
      return USART_I2C;
    else
      return USART_NONE;
  }

  /**
   * Sets the USART mode to one of the options from msp430_usartmode_t
   * defined in MSP430USART.h
   */
  async command void USARTControl.setMode(msp430_usartmode_t _mode) {
    switch (_mode) {
    case USART_UART:
      call USARTControl.setModeUART();
      break;
    case USART_UART_RX:
      call USARTControl.setModeUART_RX();
      break;
    case USART_UART_TX:
      call USARTControl.setModeUART_TX();
      break;
    case USART_SPI:
      call USARTControl.setModeSPI();
      break;
    case USART_I2C:
      call USARTControl.setModeI2C();
      break;
    default:
      break;
    }
  }

  async command void USARTControl.enableUART() {
      TOSH_SEL_UTXD0_MODFUNC();
      TOSH_SEL_URXD0_MODFUNC();
      ME1 |= (UTXE0 | URXE0);   // USART0 UART module enable
  }
  
  async command void USARTControl.disableUART() {
      ME1 &= ~(UTXE0 | URXE0);   // USART0 UART module enable
      TOSH_SEL_UTXD0_IOFUNC();
      TOSH_SEL_URXD0_IOFUNC();
  }

  async command void USARTControl.enableUARTTx() {
      TOSH_SEL_UTXD0_MODFUNC();
      ME1 |= UTXE0;   // USART0 UART Tx module enable
  }

  async command void USARTControl.disableUARTTx() {
      ME1 &= ~UTXE0;   // USART0 UART Tx module enable
      TOSH_SEL_UTXD0_IOFUNC();
  }

  async command void USARTControl.enableUARTRx() {
      TOSH_SEL_URXD0_MODFUNC();
      ME1 |= URXE0;   // USART0 UART Rx module enable
  }

  async command void USARTControl.disableUARTRx() {
      ME1 &= ~URXE0;  // USART0 UART Rx module disable
      TOSH_SEL_URXD0_IOFUNC();
  }

  async command void USARTControl.enableSPI() {
      TOSH_SEL_SIMO0_MODFUNC();
      TOSH_SEL_SOMI0_MODFUNC();
      TOSH_SEL_UCLK0_MODFUNC();
      ME1 |= USPIE0;   // USART0 SPI module enable
  }
  
  async command void USARTControl.disableSPI() {
      ME1 &= ~USPIE0;   // USART0 SPI module disable
      TOSH_SEL_SIMO0_IOFUNC();
      TOSH_SEL_SOMI0_IOFUNC();
      TOSH_SEL_UCLK0_IOFUNC();
  }
  
  async command void USARTControl.enableI2C() {
#ifdef __msp430_have_usart0_with_i2c   
    atomic U0CTL |= I2C | I2CEN | SYNC;
#endif
  }

  async command void USARTControl.disableI2C() {
#ifdef __msp430_have_usart0_with_i2c
    if (call USARTControl.isI2C())
      atomic U0CTL &= ~(I2C | I2CEN | SYNC);
#endif
  }

  async command void USARTControl.setModeSPI() {
    // check if we are already in SPI mode
    if (call USARTControl.getMode() == USART_SPI) 
      return;
      
    call USARTControl.disableUART();
    call USARTControl.disableI2C();

    atomic {
      TOSH_SEL_SIMO0_MODFUNC();
      TOSH_SEL_SOMI0_MODFUNC();
      TOSH_SEL_UCLK0_MODFUNC();

      IE1 &= ~(UTXIE0 | URXIE0);  // interrupt disable    

      U0CTL = SWRST;
      U0CTL |= CHAR | SYNC | MM;  // 8-bit char, SPI-mode, USART as master
      U0CTL &= ~(0x20); 

      U0TCTL = STC ;     // 3-pin
      U0TCTL |= CKPH;    // half-cycle delayed UCLK

      if (l_ssel & 0x80) {
        U0TCTL &= ~(SSEL_0 | SSEL_1 | SSEL_2 | SSEL_3);
        U0TCTL |= (l_ssel & 0x7F); 
      }
      else {
        U0TCTL &= ~(SSEL_0 | SSEL_1 | SSEL_2 | SSEL_3);
        U0TCTL |= SSEL_SMCLK; // use SMCLK, assuming 1MHz
      }

      if (l_br != 0) {
        U0BR0 = l_br & 0x0FF;
        U0BR1 = (l_br >> 8) & 0x0FF;
      }
      else {
        U0BR0 = 0x02;   // as fast as possible
        U0BR1 = 0x00;
      }
      U0MCTL = 0;

      ME1 &= ~(UTXE0 | URXE0); //USART UART module disable
      ME1 |= USPIE0;   // USART SPI module enable
      U0CTL &= ~SWRST;  

      IFG1 &= ~(UTXIFG0 | URXIFG0);
      IE1 &= ~(UTXIE0 | URXIE0);  // interrupt disabled    
    }
    return;
  }
  
  void setUARTModeCommon() {
    atomic {
      U0CTL = SWRST;  
      U0CTL |= CHAR;  // 8-bit char, UART-mode

      U0RCTL &= ~URXEIE;  // even erroneous characters trigger interrupts

      
      U0CTL = SWRST;
      U0CTL |= CHAR;  // 8-bit char, UART-mode

      if (l_ssel & 0x80) {
        U0TCTL &= ~(SSEL_0 | SSEL_1 | SSEL_2 | SSEL_3);
        U0TCTL |= (l_ssel & 0x7F); 
      }
      else {
        U0TCTL &= ~(SSEL_0 | SSEL_1 | SSEL_2 | SSEL_3);
        U0TCTL |= SSEL_ACLK; // use ACLK, assuming 32khz
      }

      if ((l_mctl != 0) || (l_br != 0)) {
        U0BR0 = l_br & 0x0FF;
        U0BR1 = (l_br >> 8) & 0x0FF;
        U0MCTL = l_mctl;
      }
      else {
        U0BR0 = 0x03;   // 9600 baud
        U0BR1 = 0x00;
        U0MCTL = 0x4A;
      }

      ME1 &= ~USPIE0;   // USART0 SPI module disable
      ME1 |= (UTXE0 | URXE0); //USART0 UART module enable;
      
      U0CTL &= ~SWRST;

      IFG1 &= ~(UTXIFG0 | URXIFG0);
      IE1 &= ~(UTXIE0 | URXIE0);  // interrupt disabled
    }
    return;
  }
  
  async command void USARTControl.setModeUART_TX() {
    // check if we are already in UART mode
    if (call USARTControl.getMode() == USART_UART_TX) 
      return;

    call USARTControl.disableSPI();
    call USARTControl.disableI2C();
    call USARTControl.disableUART();

    atomic {   
      TOSH_SEL_UTXD0_MODFUNC();     
      TOSH_SEL_URXD0_IOFUNC();    
    }
    setUARTModeCommon();  
    return;
  }
  
  async command void USARTControl.setModeUART_RX() {
    // check if we are already in UART mode
    if (call USARTControl.getMode() == USART_UART_RX) 
      return;

    call USARTControl.disableSPI();
    call USARTControl.disableI2C();
    call USARTControl.disableUART();

    atomic {
      TOSH_SEL_URXD0_MODFUNC(); 
      TOSH_SEL_UTXD0_IOFUNC(); 
    }
    setUARTModeCommon(); 
    return;
  }

  async command void USARTControl.setModeUART() {
    // check if we are already in UART mode
    if (call USARTControl.getMode() == USART_UART) 
      return;

    call USARTControl.disableSPI();
    call USARTControl.disableI2C();
    call USARTControl.disableUART();

    atomic {
      TOSH_SEL_UTXD0_MODFUNC();
      TOSH_SEL_URXD0_MODFUNC();
    }
    setUARTModeCommon();
    return;
  }

  // i2c enable bit is not set by default
  async command void USARTControl.setModeI2C() {
#ifdef __msp430_have_usart0_with_i2c
    // check if we are already in I2C mode
    if (call USARTControl.getMode() == USART_I2C) 
      return;

    call USARTControl.disableUART();
    call USARTControl.disableSPI();

    atomic {
      TOSH_MAKE_SIMO0_INPUT();
      TOSH_MAKE_UCLK0_INPUT();
      TOSH_SEL_SIMO0_MODFUNC();
      TOSH_SEL_UCLK0_MODFUNC();

      IE1 &= ~(UTXIE0 | URXIE0);  // interrupt disable    

      U0CTL = SWRST;
      U0CTL |= SYNC | I2C;  // 7-bit addr, I2C-mode, USART as master
      U0CTL &= ~I2CEN;

      U0CTL |= MST;

      I2CTCTL = I2CSSEL_2;        // use 1MHz SMCLK as the I2C reference

      I2CPSC = 0x00;              // I2C CLK runs at 1MHz/10 = 100kHz
      I2CSCLH = 0x03;
      I2CSCLL = 0x03;
      
      I2CIE = 0;                 // clear all I2C interrupt enables
      I2CIFG = 0;                // clear all I2C interrupt flags
    }
#endif
    return;
  }
 
  async command void USARTControl.setClockSource(uint8_t source) {
      atomic {
        l_ssel = source | 0x80;
        U0TCTL &= ~(SSEL_0 | SSEL_1 | SSEL_2 | SSEL_3);
        U0TCTL |= (l_ssel & 0x7F); 
      }
  }

  async command void USARTControl.setClockRate(uint16_t baudrate, uint8_t mctl) {
    atomic {
      l_br = baudrate;
      l_mctl = mctl;
      U0BR0 = baudrate & 0x0FF;
      U0BR1 = (baudrate >> 8) & 0x0FF;
      U0MCTL = mctl;
    }
  }

  async command result_t USARTControl.isTxIntrPending(){
    if (IFG1 & UTXIFG0){
      IFG1 &= ~UTXIFG0;
      return SUCCESS;
    }
    return FAIL;
  }

  async command result_t USARTControl.isTxEmpty(){
    if (U0TCTL & TXEPT) {
      return SUCCESS;
    }
    return FAIL;
  }

  async command result_t USARTControl.isRxIntrPending(){
    if (IFG1 & URXIFG0){
      IFG1 &= ~URXIFG0;
      return SUCCESS;
    }
    return FAIL;
  }

  async command result_t USARTControl.disableRxIntr(){
    IE1 &= ~URXIE0;    
    return SUCCESS;
  }

  async command result_t USARTControl.disableTxIntr(){
    IE1 &= ~UTXIE0;  
    return SUCCESS;
  }

  async command result_t USARTControl.enableRxIntr(){
    atomic {
      IFG1 &= ~URXIFG0;
      IE1 |= URXIE0;  
    }
    return SUCCESS;
  }

  async command result_t USARTControl.enableTxIntr(){
    atomic {
      IFG1 &= ~UTXIFG0;
      IE1 |= UTXIE0;
    }
    return SUCCESS;
  }
  
  async command result_t USARTControl.tx(uint8_t data){
    U0TXBUF = data;
    return SUCCESS;
  }
  
  async command uint8_t USARTControl.rx(){
    uint8_t value;
    value = U0RXBUF;
    return value;
  }

  default async event result_t USARTData.txDone() { return SUCCESS; }

  default async event result_t USARTData.rxDone(uint8_t data) { return SUCCESS; }
}
