
// $Id: HPLCC2420FIFOM.nc,v 1.1.1.1 2007/11/05 19:10:12 jpolastre Exp $

/*									tab:4
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
 *
 * Authors: Alan Broad, Crossbow
 * Date last modified:  $Revision: 1.1.1.1 $
 *
 */

/**
 * Low level hardware access to the CC2420 Rx,Tx fifos
 * @author Alan Broad
 */

module HPLCC2420FIFOM {
  provides {
    interface HPLCC2420FIFO;
  }
}
implementation
{
  norace bool bSpiAvail;                    //true if Spi bus available
  norace uint8_t* txbuf; uint8_t* rxbuf;
  norace uint8_t txlength, rxlength; 
  bool rxbufBusy, txbufBusy;


  task void signalTXdone() {
    uint8_t _txlen;
    uint8_t* _txbuf;

    atomic {
      _txlen = txlength;
      _txbuf = txbuf;
      txbufBusy = FALSE;
    }

    signal HPLCC2420FIFO.TXFIFODone(_txlen, _txbuf);
  }
/**
Returns data buffer from RXFIFO and number of bytes read.
@param rxlength Nofbytes read from RXFIFO (including 1st byte which is usually length
@param rxbuf pointer to buffer
**********************************************************************************/
  task void signalRXdone() {
    uint8_t _rxlen;
    uint8_t* _rxbuf;

    atomic {
      _rxlen = rxlength;
      _rxbuf = rxbuf;
      rxbufBusy = FALSE;
    }

    signal HPLCC2420FIFO.RXFIFODone(_rxlen, _rxbuf);
  }

  /**
   * Writes a series of bytes to the transmit FIFO.
   *
   * @param length nof bytes be written
   * @param msg pointer to first byte of data
   *
   * @return SUCCESS if the bus is free to write to the FIFO
   */
  async command result_t HPLCC2420FIFO.writeTXFIFO(uint8_t len, uint8_t *msg) {
     uint8_t i = 0;
     uint8_t status;
     bool returnFail = FALSE;

     atomic {
       if (txbufBusy)
	 returnFail = TRUE;
       else
	 txbufBusy = TRUE;
     }

     if (returnFail)
       return FAIL;

 //   while (!bSpiAvail){};                      //wait for spi bus 

	atomic {
		bSpiAvail = FALSE;
		txlength = len;
		txbuf = msg;
		TOSH_CLR_CC_CS_PIN();                   //enable chip select
		outp(CC2420_TXFIFO,SPDR);
		while (!(inp(SPSR) & 0x80)){};          //wait for spi xfr to complete
		status = inp(SPDR);
		for (i=0; i < txlength; i++){ 
			outp(*txbuf,SPDR);
			txbuf++;
			while (!(inp(SPSR) & 0x80)){};          //wait for spi xfr to complete
			}
		bSpiAvail = TRUE;
		}  //atomic
	TOSH_SET_CC_CS_PIN();                       //disable chip select
    if (post signalTXdone() == FAIL) {
      atomic txbufBusy = FALSE;
      return FAIL;
    }
    return status;
  }
   
  /**
   * Read from the RX FIFO queue.  Will read bytes from the queue
   * until the length is reached (determined by the first byte read).
   * RXFIFODone() is signalled when all bytes have been read or the
   * end of the packet has been reached.
   *
   * @param length number of bytes requested from the FIFO
   * @param data buffer bytes should be placed into
   *
   * @return SUCCESS if the bus is free to read from the FIFO
   */
  async command result_t HPLCC2420FIFO.readRXFIFO(uint8_t len, uint8_t *msg) {
     uint8_t status,i;
     bool returnFail = FALSE;
     
     atomic {
       if (rxbufBusy)
	 returnFail = TRUE;
       else
	 rxbufBusy = TRUE;
     }
     
     if (returnFail)
       return FAIL;

 //   while (!bSpiAvail){};                      //wait for spi bus 

	atomic {
	  bSpiAvail = FALSE;
      atomic rxbuf = msg;
	  TOSH_CLR_CC_CS_PIN();                   //enable chip select
	  outp(CC2420_RXFIFO | 0x40 ,SPDR);       //output Rxfifo address
	  while (!(inp(SPSR) & 0x80)){};          //wait for spi xfr to complete
	  status = inp(SPDR);
      outp(0, SPDR);
	  while (!(inp(SPSR) & 0x80)){};          //wait for spi xfr to complete
	  rxlength = inp(SPDR);
	  if( rxlength > 0 ) {
		rxbuf[0] = rxlength;
		// total length including the length byte
		rxlength++;
		// protect against writing more bytes to the buffer than we have
		if (rxlength > len) rxlength = len;

		for (i=1; i < rxlength ; i++){ 
			outp(0,SPDR);
			while (!(inp(SPSR) & 0x80)){};          //wait for spi xfr to complete
			rxbuf[i] = inp(SPDR);
		} //i
	  }//rxlength>0

	  bSpiAvail = TRUE;
    } //atomic
    TOSH_SET_CC_CS_PIN();                       //disable chip select
    if (post signalRXdone() == FAIL) {
      atomic rxbufBusy = FALSE;
      return FAIL;
    }
    return SUCCESS;	  //return also indicates completion...
  }// readRXFIFO
} //module



