/*
 * "Copyright (c) 2001 and The Regents of the University
 * of California.  All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice and the following
 * two paragraphs appear in all copies of this software.
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
 * $\Id$
 */

/**
 * File: ListenServer.java
 *
 * Description:
 * The Listen Server is the heart of the serial forwarder.  Upon
 * instantiation, this class spawns the SerialPortReader and the
 * Multicast threads.  As clients connect, this class spawns
 * ServerReceivingThreads as wells as registers the new connection
 * SerialPortReader.  This class also provides the central
 * point of contact for the GUI, allowing the server to easily
 * be shut down
 *
 * @author <a href="mailto:bwhull@sourceforge.net">Bret Hull</a>
 */
package net.tinyos.sf;

import java.net.*;
import java.io.*;
import javax.comm.*;
import java.util.*;

public class ListenServer extends Thread {

    private static final String CLASS_NAME    = "Listen Server";
    private int                 m_nPort         = 0;
    private boolean             m_bShutdown     = false;
    private ServerSocket        m_serverSocket  = null;
    private Vector              vctServicers  = new Vector();
    private SerialForward sf;
    public ListenServer (SerialForward SF) {
        sf=SF;
        m_nPort       = sf.serverPort;
    }

    public void run () {
        boolean status;
	sf.DEBUG("Listen server running.");
        // open up our server socket
        try {m_serverSocket = new ServerSocket(m_nPort);}
        catch (IOException e) {
            sf.VERBOSE ("Could not listen on port: " + m_nPort);
            if (sf.cntrlWndw != null) {
                sf.cntrlWndw.ClearListenServer ();
            }
            return;
        }
        sf.VERBOSE ("Listening for client connections on port " + m_nPort);
        //if (SerialForward.bSourceSim)
        //{
	SetDataSource();
	sf.InitSerialPortIO();
        //}
        // start listening for connections
        try {
	    ClientServicer rcv;
            Socket currentSocket;
            while (!m_bShutdown) {
                currentSocket = m_serverSocket.accept();
                   ClientServicer newServicer = new ClientServicer (currentSocket, sf, this);
                   newServicer.start();
                   vctServicers.add (newServicer);
            }
            m_serverSocket.close();
        }
        catch (IOException e) {
            /*try { this.sleep(500); }
            catch (Exception e2) { }*/
            sf.VERBOSE ("Server Socket closed");
        }
        finally {
            ShutdownAllClientServicers();
            if(sf.serialPortIO!=null) sf.serialPortIO.Shutdown();
            sf.VERBOSE("--------------------------");
            if (sf.cntrlWndw != null) {
                sf.cntrlWndw.ClearListenServer ();
            }
        }
    }

    private void SetDataSource ()    {
        if (sf.useDummyData) {
            sf.dataSource = new DummySource (sf);
        }
        else if (sf.bSourceSim) {
            sf.dataSource = new SimSource (sf);
        }
	else if (sf.bNidoSerialData) {
	    sf.dataSource = new NidoSerialDataSource(sf);
	}
        else if (sf.bSourceDB) {
            sf.dataSource = new DBSource (sf);
        }
        else {
            sf.dataSource = new SerialSource (sf);
        }
    }

    public void RestartDataSource () {
      SetDataSource();
      sf.InitSerialPortIO();
    }

    public void Shutdown () {
        if (!m_bShutdown) {
            m_bShutdown = true;
            try { if (m_serverSocket != null) m_serverSocket.close(); }
            catch (IOException e) { e.printStackTrace(); }
            this.interrupt();
        }
    }

    public void ShutdownAllClientServicers ( )
    {
        sf.VERBOSE( "CLIENTSERVICER: Shutting down all client connections" );
        ClientServicer crrntServicer;
        while ( vctServicers.size() != 0 )
        {
            crrntServicer = (ClientServicer) vctServicers.firstElement();
            crrntServicer.Shutdown();
            try {  crrntServicer.join(1000); }
            catch (InterruptedException e) { e.printStackTrace(); };
        }
    }

    public void RemoveClientServicer(ClientServicer clientS)
    {
        vctServicers.remove(clientS);
    }

}
