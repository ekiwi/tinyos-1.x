// $Id: LRXReceive.nc,v 1.4 2006/12/01 00:04:09 binetude Exp $

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
 * Authors:		Sukun Kim, Philip Buonadonna
 * Date last modified:  11/30/06
 *
 */

/**
 * @author Sukun Kim
 * @author Philip Buonadonna
 */

/**
 * Large-scale Reliable Transfer (LRX) Receive
 * 
 * Transfer large amount of data reliably.
 *
 * Trnasfer an array of data blocks, which is called data cluster. Each data
 * block fits into one packet.
 * To start transfer, description of data should be given. Receiver can deny
 * data after looking at the description of data. (for example, receiver
 * already has that data)
 *
 * User of LRXSend should provide buffering. When LRXSend asks for
 * a specific block, user should fill up buffer of LRXSend. When LRXReceive
 * gives a pointer to buffer of LRXReceive, user of LRXReceive should copy
 * content to its own buffer, so that LRXReceive can receive next packet
 * into the buffer of LRXReceive.
 */

interface LRXReceive {
	/**
	 * Transfer is requested. Decide whether to receive <code>numofBlock</code>
	 * blocks from source <code>sourceID</code> with
	 * description(<code>desc</code>) of size(<code>descSize</code>).
	 *
	 * @return SUCCESS if upper layer accepts receive, FAIL otherwise.
	 */
	event result_t transferRequested(uint16_t sourceID, uint8_t numofBlock,
		uint8_t *desc, uint8_t descSize);
	
	/**
	 * Receive completed. <code>success</code> indicates whether the receive
	 * was successful or not.
	 *
	 * @return SUCCESS always.
	 */
	event result_t acceptedTransferDone(result_t success);
	
	/**
	 * Abort receiving.
	 *
	 * @return SUCCESS always.
	 */
	command result_t abortReceive();

	/**
	 * A data block <code>blockNum</code> is received. Its size is
	 * <code>blockSize</code> and its content is in <code>blockBuf</code>.
	 *
	 * @return SUCCESS always.
	 */
	event result_t writeDataBlock(uint8_t blockNum, uint8_t *blockBuf,
		uint8_t blockSize);
}

