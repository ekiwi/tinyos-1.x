// $Id: SerialByteSource.java,v 1.1.1.1 2007/11/05 19:08:59 jpolastre Exp $

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


package net.tinyos.packet;

import java.util.*;
import java.io.*;
import net.tinyos.comm.*;

/**
 * A serial port byte source, with extra special hack to deal with
 * broken javax.comm implementations (IBM's javax.comm does not set the
 * port to raw mode, on Linux, at least in some implementations - call
 * an external program (tinyos-serial-configure) to "fix" this)
 */
public class SerialByteSource extends StreamByteSource implements SerialPortListener
{
    private SerialPort serialPort;
    private String portName;
    private int baudRate;

    public SerialByteSource(String portName, int baudRate) {
	this.portName = portName;
	this.baudRate = baudRate;
    }

    public void openStreams() throws IOException {
	try {
          if(true)
          {
            //tosserial
            serialPort = new TOSSerial(portName);
          }
/*
          else
          {
            //javaserial
            javax.comm.CommPortIdentifier portId;
            try {
              portId = javax.comm.CommPortIdentifier.getPortIdentifier(portName);
            }
            catch(javax.comm.NoSuchPortException e) {
              throw new IOException("Invalid port. "+allPorts());
            }
            javax.comm.SerialPort sp = (javax.comm.SerialPort)portId.open( 
              "SerialByteSource", javax.comm.CommPortIdentifier.PORT_SERIAL
            );
            serialPort = new JavaxCommSerialPort(sp);
          }
*/
	}
	catch (Exception e) {
	    throw new IOException("Could not open " + portName + ": " + e.getMessage());
	}

	try {
	    //serialPort.setFlowControlMode(SerialPort.FLOWCONTROL_NONE);
	    serialPort.setSerialPortParams(baudRate,
					   8,
					   SerialPort.STOPBITS_1,
					   false );

	    serialPort.addListener(this);
	    serialPort.notifyOn( SerialPortEvent.DATA_AVAILABLE, true );
	}
	catch (Exception e) {
	    serialPort.close();
	    throw new IOException("Could not configure " + portName + ": " + e.getMessage() );
	}

	// Try & run external program to setup serial port correctly
	// (necessary on Linux, IBM's javax.comm leaves port in cooked mode)
//	try {
//	    Runtime.getRuntime().exec("tinyos-serial-configure " + portName);
//	}
//	catch (IOException e) { }

	is = serialPort.getInputStream();
	os = serialPort.getOutputStream();
    }

    public void closeStreams() throws IOException {
	serialPort.close();
    }

    public String allPorts() {
      /*
	Enumeration ports = CommPortIdentifier.getPortIdentifiers();
	if (ports == null)
	    return "No comm ports found!";

	boolean  noPorts = true;
	String portList = "Known serial ports:\n";
	while (ports.hasMoreElements()) {
	    CommPortIdentifier port = (CommPortIdentifier)ports.nextElement();

	    if (port.getPortType() == CommPortIdentifier.PORT_SERIAL) {
		portList += "- " + port.getName() + "\n";
		noPorts = false;
	    }
	}
	if (noPorts)
	    return "No comm ports found!";
	else
	    return portList;
      */
      return "Listing available comm ports is no longer supported.";
    }

    Object sync = new Object();

    public byte readByte() throws IOException {
	// On Linux at least, javax.comm input streams are not interruptible.
	// Make them so, relying on the DATA_AVAILABLE serial event.
	synchronized (sync) {
	    while (is.available() == 0) {
		try {
		    sync.wait();
		}
		catch (InterruptedException e) {
		    close();
		    throw new IOException("interrupted");
		}
	    }
	}

	return super.readByte();
    }

    public void serialEvent(SerialPortEvent ev) {
	synchronized (sync) {
	    sync.notify();
	}
    }

    protected void finalize() {
      System.out.println("SerialByteSource finalize");
      serialPort.close();
    }

}
