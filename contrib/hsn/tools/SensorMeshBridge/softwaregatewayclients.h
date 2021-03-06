/*                                                                      tab:4
 *  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.  By
 *  downloading, copying, installing or using the software you agree to
 *  this license.  If you do not agree to this license, do not download,
 *
 */
/*                                                                      tab:4
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
 */
/*                                                                      tab:4
 * Copyright (c) 2003 Intel Corporation
 * All rights reserved Contributions to the above software program by Intel
 * Corporation is program is licensed subject to the BSD License, available at
 * http://www.opensource.org/licenses/bsd-license.html
 *
 */
/*
 * Authors:	Mark Yarvis
 *
 */

#ifndef _SOFTWARE_GATEWAY_CLIENTS_H
#define _SOFTWARE_GATEWAY_CLIENTS_H

#include "clientsocket.h"
#include "packet.h"

class SoftwareGatewayEventClient : public ClientSocket {

public:
	SoftwareGatewayEventClient();
	~SoftwareGatewayEventClient();

	virtual void performService(ConnectionManager* conn);
	virtual const char* getName(){return "Software gateway event client";}

	const short UART_EVENT;
	const short RADIO_EVENT;

};

class SoftwareGatewayCommandClient : public ClientSocket {

public:
	SoftwareGatewayCommandClient();
	~SoftwareGatewayCommandClient();

	virtual void performService(ConnectionManager* conn){}
	virtual const char* getName(){return "Software gateway command client";}

	virtual void sendMsg(unsigned char* data, const short command);

	const short UART_COMMAND;
	const short RADIO_COMMAND;

private:

	void bufferToSimMsg(unsigned char* buffer, short command);
	SimMsg simMsg;

};


#endif

