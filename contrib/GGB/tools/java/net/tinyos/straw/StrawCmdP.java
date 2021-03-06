// $Id: StrawCmdP.java,v 1.1 2006/12/01 05:34:56 binetude Exp $

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

/**
 * File: StrawCmdP.java
 *
 * @author <a href="mailto:binetude@cs.berkeley.edu">Sukun Kim</a>
 */

package net.tinyos.straw;

class Arg {
  static final short NO_ARG =5; // change when new arg is added
  static final String[] nm = new String[NO_ARG];
 
  static final short DEST = 0; {nm[DEST] = "dest";}
  static final short NSAMPLES =1; {nm[NSAMPLES] = "nSamples";}
  static final short INTRV = 2; {nm[INTRV] = "intrv";}
  static final short CHNLNO = 3; {nm[CHNLNO] = "chnlNo";}
  static final short SAMPLENO = 4; {nm[SAMPLENO] = "sampleNo";}

  static String getString(short arg) {
    return "<" + nm[arg] + ">";
  }
};



class Optn {
  static final short NO_OPTN = 6; // change when new optn is added
  static final String[] nm = new String[NO_OPTN];
  static final boolean[] arg = new boolean[NO_OPTN];
 
  static final short DEST = 0; {nm[DEST] = "dest";
    arg[DEST] = true;}
  static final short CHNLSELECT = 1; {nm[CHNLSELECT] = "chnlSelect";
    arg[CHNLSELECT] = true;}
  static final short SAMPLESTOAVG  = 2; {nm[SAMPLESTOAVG] = "samplesToAvg";
    arg[SAMPLESTOAVG] = true;}
  static final short NM  = 3; {nm[NM] = "nm";
    arg[NM] = true;}
  static final short TOUART = 4; {nm[TOUART] = "toUART";
    arg[TOUART] = false;}
  static final short VERBOSE = 5; {nm[VERBOSE] = "verbose";
    arg[VERBOSE] = false;}

  static String getString(short optn) {
    String outString = "[-" + nm[optn];
    if (arg[optn]) outString += " " + nm[optn];
    outString += "]";
    return outString;
  }
};



class Cmd {

  static final short NO_CMD = 3; // change when new cmd is added
  static final String[] nm = new String[NO_CMD];
  static final short[] argNo = new short[NO_CMD];
  static final short[][] argList= new short[NO_CMD][];
  static final short[] optnNo = new short[NO_CMD];
  static final short[][] optnList = new short[NO_CMD][];

  static final short PINGNODE = 0; {nm[PINGNODE] = "pingNode";
    argNo[PINGNODE] = 1;
    argList[PINGNODE] = new short[argNo[PINGNODE]];
    argList[PINGNODE][0] = Arg.DEST;
    
    optnNo[PINGNODE] = 2;
    optnList[PINGNODE] = new short[optnNo[PINGNODE]];
    optnList[PINGNODE][0] = Optn.TOUART;
    optnList[PINGNODE][1] = Optn.VERBOSE;
  }

  static final short READDATA = 1; {nm[READDATA] = "readData";
    argNo[READDATA] = 1;
    argList[READDATA] = new short[argNo[READDATA]];
    argList[READDATA][0] = Arg.DEST;
    
    optnNo[READDATA] = 2;
    optnList[READDATA] = new short[optnNo[READDATA]];
    optnList[READDATA][0] = Optn.TOUART;
    optnList[READDATA][1] = Optn.VERBOSE;
  }

  static final short HELP = 2; {nm[HELP] = "help";
    argNo[HELP] = 0;
    argList[HELP] = new short[argNo[HELP]];
    
    optnNo[HELP] = 1;
    optnList[HELP] = new short[optnNo[HELP]];
    optnList[HELP][0] = Optn.VERBOSE;
  }

  static String getString(short cmd) {
    String outString = nm[cmd];
    for (short i = 0; i < argNo[cmd]; i++)
      outString += " " + Arg.getString(argList[cmd][i]);
    for (short i = 0; i < optnNo[cmd]; i++) {
      outString += " " + Optn.getString(optnList[cmd][i]);
    }
    return outString;
  }

};



class StrawCmdP {

  //  Command parameters  //
  short cmd = Cmd.NO_CMD;

  boolean broadcasting = true;
  int dest = TosP.TOS_BCAST_ADDR;

  long nSamples = 0;
  long intrv = 0;

  short chnlNo = 0;
  long sampleNo = 0;  

  short chnlSelect = 1;
  int samplesToAvg = 1;
  boolean spclNm = false;
  String nm = null;
  short toUART = 0;
  boolean verbose = false;

  private int init() {
    cmd = Cmd.NO_CMD;
  
    broadcasting = true;
    dest = TosP.TOS_BCAST_ADDR;
  
    nSamples = 0;
    intrv = 0;
  
    chnlNo = 0;
    sampleNo = 0;  
  
    chnlSelect = 1;
    samplesToAvg = 1;
    spclNm = false;
    nm = null;
    toUART = 0;
    verbose = false;

    return 0;
  }



  private int procArg(String[] args, int argsIndex, short arg) {
    switch (arg) {
    case Arg.DEST:
      broadcasting = false;
      dest = Integer.parseInt(args[argsIndex]);
      break;
    case Arg.NSAMPLES:
      nSamples = Long.parseLong(args[argsIndex]);
      break;
    case Arg.INTRV:
      intrv = Long.parseLong(args[argsIndex]);
      break;
    case Arg.CHNLNO:
      chnlNo = Short.parseShort(args[argsIndex]);
      break;
    case Arg.SAMPLENO:
      sampleNo = Long.parseLong(args[argsIndex]);
      break;
    default:
      System.out.println("ERROR: CmdP.procArg");
      break;
    }
    return 0;
  }

  private int procOptn(String[] args, int argsIndex, short optn) {
    switch (optn) {
    case Optn.DEST:
      broadcasting = false;
      dest = Integer.parseInt(args[argsIndex + 1]);
      break;
    case Optn.CHNLSELECT:
      chnlSelect = Short.parseShort(args[argsIndex + 1]);
      break;
    case Optn.SAMPLESTOAVG:
      samplesToAvg = Integer.parseInt(args[argsIndex + 1]);
      break;
    case Optn.NM:
      spclNm = true;
      nm = args[argsIndex + 1];
      break;
    case Optn.TOUART:
      toUART = 1;
      break;
    case Optn.VERBOSE:
      verbose = true;
      break;
    default:
      System.out.println("ERROR: CmdP.procOptn");
      break;
    }
    return 0;
  }

  int parse(String[] args) {
    int argsIndex = 0;
    short i;
    init();

    //  Parse cmd  //
    if (args.length < 1) {
      System.out.println(getUsage());
      return 1;
    }
    for (i = 0; i < Cmd.NO_CMD; i++)
      if (args[argsIndex].equals(Cmd.nm[i]))
	break;
    if (i == Cmd.NO_CMD) {
      System.out.println(getUsage());
      return 2;
    }
    cmd = i;
    ++argsIndex;


    //  Parse arg  //
    if (args.length < argsIndex + Cmd.argNo[cmd]) {
      System.out.println(getSpecificUsage(cmd));
      return 3;
    }
    for (i = 0; i < Cmd.argNo[cmd]; i++) {
      procArg(args, argsIndex, Cmd.argList[cmd][i]);
      ++argsIndex;
    }

    //  Parse optn  //
    boolean[] optnCheck = new boolean[Optn.NO_OPTN];
    for (i = 0; i < Optn.NO_OPTN; i++) optnCheck[i] = false;
    while (argsIndex < args.length) {
      for (i = 0; i < Optn.NO_OPTN; i++)
        if (args[argsIndex].equals("-" + Optn.nm[i]))
	  break;
	  
      if ((i == Optn.NO_OPTN)
        || (Optn.arg[i] && (args.length < argsIndex + 2))
	|| optnCheck[i]) {
        System.out.println(getSpecificUsage(cmd));
        return 4;
      }
      short j = 0;
      for (j = 0; j < Cmd.optnNo[cmd]; j++) {
        if (Cmd.optnList[cmd][j] == i)
	  break;
      }
      if (j == Cmd.optnNo[cmd]) {
        System.out.println(getSpecificUsage(cmd));
        return 5;
      }
      
      procOptn(args, argsIndex, i);
      ++argsIndex;
      if (Optn.arg[i]) ++argsIndex;
      optnCheck[i] = true;
    }

    if (cmd == Cmd.HELP) System.out.println(getUsage());
    else System.out.println("********  " + Cmd.nm[cmd] + "  ********");
    return 0;
  }



  static final Arg dummyArg = new Arg();
  static final Optn dummyOptn = new Optn();
  static final Cmd dummyCmd = new Cmd();
  private String getUsage() {
    String outString = "Usage: java net.tinyos.SMT.DataCenter"
      + " <command> <arguments> [options] where" + "\n"
      + "\t" + "<command> <arguments> [options] can be"
      + " one of the following:" + "\n\n";
    for (short i = 0; i < Cmd.NO_CMD; i++)
      outString += Cmd.getString(i) + "\n";
    return outString;
  }
  private String getSpecificUsage(short aCmd) {
    return "Usage: java net.tinyos.SMT.DataCenter " + Cmd.getString(aCmd)
      + "\n";
  }

  public String toString() {
    String outString = "";
    outString += "cmd = " + cmd + "\n"
      + "broadcasting = " + broadcasting + ", dest = " + dest + "\n"
      + "nSamples = " + nSamples + ", intrv = " + intrv + "\n"
      + "chnlNo = " + chnlNo + ", sampleNo = " + sampleNo + "\n"
      + "chnlSelect = " + chnlSelect + ", samplesToAvg = " + samplesToAvg + "\n"
      + "spclNm = " + spclNm + ", nm = " + nm + "\n"
      + "toUART = " + toUART + ", verbose = " + verbose + "\n";
    return outString;
  }

}

