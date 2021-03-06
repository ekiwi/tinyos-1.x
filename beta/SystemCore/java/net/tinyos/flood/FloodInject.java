package net.tinyos.flood;

import java.io.*;
import net.tinyos.util.*;
import net.tinyos.message.*;

public class FloodInject {

  private MoteIF moteIF;
  private int key;
  private int value;

  public FloodInject() {
    moteIF = new MoteIF(PrintStreamMessenger.err);
  }

  public void send(int id, Message m) {
    FloodMsg msg = new FloodMsg();
    
    msg.set_metadata_id((short)id);
    msg.set_metadata_seqno((byte)0);
  }

  public void inject(int id, int value) {

    FloodMsg msg = new FloodMsg();

    this.key = id;
    msg.set_metadata_id((short)key);
    msg.set_metadata_seqno((byte)0);
    this.value = value;

    for(int i = 0; i < 4; i++) {
      msg.setElement_data(i, (short)((value & (0xff << 8*i)) >> 8*i));
    }
    System.out.println(msg);
    
    send(msg);
  }

  private synchronized void send(Message m) {
    try {
      moteIF.send(MoteIF.TOS_BCAST_ADDR, m);
    } catch (IOException e) {
      e.printStackTrace();
      System.out.println("ERROR: Can't send message");
      System.exit(1);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  public static void usage() {
    System.err.println("Usage: java net.tinyos.tools.FloodInject"+
		       " <channel> <value> ");
  }

  public static void main(String[] argv) throws IOException {

    FloodInject ij = new FloodInject();

    if (argv.length < 2) {
      usage();
      System.exit(-1);
    }
    
    int channel = Integer.parseInt(argv[0]);
    int value = Integer.parseInt(argv[1], 16);

    ij.inject(channel, value);
  }
}




