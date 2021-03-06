package net.tinyos.drain;

import net.tinyos.message.*;
import net.tinyos.util.*;

import org.apache.log4j.*;

import java.io.*; 
import java.text.*;
import java.util.*;
import java.net.*;

public class DrainConnector implements MessageListener {

  public static int TOS_UART_ADDR = 0x7e;
  public static int DEFAULT_MOTE_ID = 0xfffe;
  public static int BCAST_ID = 0xff;
    
  private MoteIF moteIF;

  private Logger log = Logger.getLogger(DrainConnector.class.getName());

  private int spAddr;

  private Hashtable seqNos = new Hashtable();
  private HashMap idTable = new HashMap();

  public DrainConnector() {
    this(DrainLib.setSPAddr(), DrainLib.startMoteIF());
  }

  public DrainConnector(int p_spAddr, MoteIF p_moteIF) {
    spAddr = p_spAddr;
    moteIF = p_moteIF;
    moteIF.registerListener(new DrainMsg(), this);
    log.info("Started myAddr = " + spAddr + ", listening for DrainMsg");
  }

  public void registerListener(int id, MessageListener m) {
    HashSet listenerSet = (HashSet) idTable.get(new Integer(id));
    
    if (listenerSet == null) {
      listenerSet = new HashSet();
      idTable.put(new Integer(id), listenerSet);
    }
    listenerSet.add(m);
    log.info("New Listener for id=" + id);
  }

  public void deregisterListener(int id, MessageListener m) {
    HashSet listenerSet = (HashSet) idTable.get(new Integer(id));
    
    if (listenerSet == null) {
	throw new IllegalArgumentException("No listeners registered for message type "+id);
    }
    listenerSet.remove(m);
  }

  synchronized public void messageReceived(int to, Message m) {

    DrainMsg mhMsg = (DrainMsg)m;

    log.debug("incoming: localDest: " + to +
	      " type:" + mhMsg.get_type() +
	      " hops:" + (16 - mhMsg.get_ttl()) +
	      " seqNo:" + mhMsg.get_seqNo() + 
	      " source:" + mhMsg.get_source() + 
	      " finalDest:" + mhMsg.get_dest());

    //lets assume that the network cannot buffer more than 25 drain msgs from a single source at a time (should be more than reasonable)
    if (seqNos.containsKey(new Integer(mhMsg.get_source()))){
	int oldSeqNo = ((Integer)seqNos.get(new Integer(mhMsg.get_source()))).intValue();
	int upperBound = mhMsg.get_seqNo()+25;
	int wrappedUpperBound = 25 - (255- mhMsg.get_seqNo());
	if ( (oldSeqNo >= mhMsg.get_seqNo() && oldSeqNo < upperBound) ||
	     (oldSeqNo >= 0 && oldSeqNo < wrappedUpperBound) ) {
	    log.debug("Dropping message from " + mhMsg.get_source() + " with duplicate seqNo: " + mhMsg.get_seqNo());
	    return;
	}
    }
    seqNos.put(new Integer(mhMsg.get_source()), new Integer(mhMsg.get_seqNo()));

    if (to != spAddr && to != MoteIF.TOS_BCAST_ADDR && to != TOS_UART_ADDR) {
      log.debug("Dropping message not for me.");
      return;
    }

    HashSet promiscuousSet = (HashSet) idTable.get(new Integer(BCAST_ID));
    HashSet listenerSet = (HashSet) idTable.get(new Integer(mhMsg.get_type()));
    
    if (listenerSet != null && promiscuousSet != null) {
      listenerSet.addAll(promiscuousSet);
    } else if (listenerSet == null && promiscuousSet != null) {
      listenerSet = promiscuousSet;
    }

    if (listenerSet == null) {
      log.debug("No Listener for type: " + mhMsg.get_type());
      return;
    }

    for(Iterator it = listenerSet.iterator(); it.hasNext(); ) {
      MessageListener ml = (MessageListener) it.next();
      ml.messageReceived(to, mhMsg);
    }
  }
  
  public static void main(String args[]) {
    DrainConnector dc = new DrainConnector();
  }
}
