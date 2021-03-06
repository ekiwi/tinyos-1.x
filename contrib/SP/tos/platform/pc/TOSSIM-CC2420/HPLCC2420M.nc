// $Id: HPLCC2420M.nc,v 1.1 2006/04/14 00:15:38 binetude Exp $

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
 * @author Joe Polastre, Yang Zhang
 *
 * Authors: Joe Polastre, Yang Zhang
 * Date last modified:  $Revision: 1.1 $
 *
 */

// NOTES
// Currently, an ack is always being sent, since autoack is always enabled in
// CC2420Lib.

includes HPLCC2420;
includes simplatform;

// monitor the on/off status of the radio
#define DBG_STDCTL DBG_USR1
// high-level indicator that a packet was successfully received and accepted
#define DBG_TRANSMIT DBG_USR1

module HPLCC2420M {
  provides {
    interface StdControl;
    interface HPLCC2420;
    interface HPLCC2420RAM;
    interface HPLCC2420FIFO;
    interface HPLCC2420Interrupt as FIFOP;
    interface HPLCC2420Interrupt as FIFO;
    interface HPLCC2420Interrupt as CCA;
    interface HPLCC2420Capture as SFD;
  }
  uses {
    interface PowerState;
  }
}

implementation
{

  DebugMode dbgStdControl = {TRUE,  DBG_USR1, DbgBlue, "HPL.StdControl"};
  DebugMode dbgTransmit   = {TRUE,  DBG_USR1, DbgBlue, "HPL.Transmit"};
  DebugMode dbgReceive    = {FALSE, DBG_USR1, DbgBlue, "HPL.Receive"};
  DebugMode dbgFail       = {TRUE,  DBG_USR1, DbgBrightRed, "HPL.Fail"};

  // TODO try making all the events instantaneous instead of posted?
  // TODO it is not completely safe to turn off the radio at any random time. for instance, we might break if we turn it off while sending a frame, or the opposite side might get a packet successfully, or.... analyze/address these possibilities?

  // Container for structure for a packet, along with various metadata.
  typedef struct FrameData {
    uint8_t length; // The true, full length of frame.
    uint16_t sourceId;
    uint8_t* frame;
    double rssi;
    double lqi;
    bool isAck;

    // Set by the recipient; whether the packet currently being received
    // has the correct address. This is the result of the address recognition
    // routine.
    bool isDestAddrCorrect;

    // Set by the recipient; whether the packet's length field is corrupt,
    // due to interference with concurrent radio signals.
    bool wasLengthCorrupt;
  } FrameData;

  // State change data. Helps ensure the consistency of state changes. For instance,
  // if we experience a STX while in RX_CALIBRATE, then we want to make sure that
  // the RxCalibrated event does not register. This is achieved by using state
  // session numbers, which is incremented every time we change the state.
  typedef struct StateChangeData {
    uint32_t stateSession;
  } StateChangeData;

  // Neighbor data. A mote is a neighbor for the currently transmitting frame if it
  // will be able to hear the frame.
  typedef struct Neighbor {
    bool isNeighbor;
    double rssi;
    double lqi;
  } Neighbor;

  // Generic transmission data to identify the source.
  typedef struct SourceData {
    uint16_t sourceId;
    double rssi;
  } SourceData;

  // TODO change these all to const's.

  // TODO these really belong in the CC2420Const.h
#define CC2420_IOCFG1_CCAMUX_START CC2420_IOCFG1_CCAMUX
#define CC2420_IOCFG1_CCAMUX_END 4
#define CC2420_IOCFG0_FIFOTHR_START CC2420_IOCFG0_FIFOTHR
#define CC2420_IOCFG0_FIFOTHR_END 6
#define CC2420_RSSI_CCA_THRESH_START CC2420_RSSI_CCA_THRESH
#define CC2420_RSSI_CCA_THRESH_END 15
#define CC2420_MDMCTRL0_CCAMODE_START CC2420_MDMCTRL0_CCAMODE
#define CC2420_MDMCTRL0_CCAMODE_END 7
#define CC2420_TXCTRL_PAPWR_START CC2420_TXCTRL_PAPWR
#define CC2420_TXCTRL_PAPWR_END 4

  // The number of radio configuration registers.
#define REGISTER_COUNT 0x40
  // The size in bytes of the radio's RAM.
#define RAM_SIZE 368
  // The size in bytes of the radio's queues (both RX and TX are this length).
#define QUEUE_SIZE 128
  // The voltage regulator startup time, in seconds.
#ifndef VREG_ON_LATENCY
#define VREG_ON_LATENCY .000600
#endif // VREG_ON_LATENCY
  // The crystal oscillator startup time, in seconds.
#ifndef OSCILLATOR_ON_LATENCY
#define OSCILLATOR_ON_LATENCY .002100
#endif // OSCILLATOR_ON_LATENCY
  // The ACK TX calibration time, in symbols.
#define TX_ACK_CALIBRATE_LATENCY 12
  // The default FIFO threshold, in bytes.
#define DEFAULT_FIFO_THRESHOLD 64
  // The default CCA mode.
  // TODO is this correct?
#define DEFAULT_CCA_MODE 3
  // The default CCA threshold, in dB.
#define DEFAULT_CCA_THRESHOLD -77
  // The default TX calibration time, in symbols.
#define DEFAULT_TX_TURNAROUND 12
  // The RX calibration time, in symbols.
#define RX_CALIBRATION_LATENCY 12
  // The transmit bit rate, in bits per second.
#define TX_TRANSMIT_BIT_RATE 250000
  // The length of the preamble, in bytes.
#define PREAMBLE_LENGTH 4
  // The length of the SFD, in bytes.
#define SFD_LENGTH 1
  // The preamble and SFD transmit time, in seconds.
#define PREAMBLE_SFD_TRANSMIT_LATENCY calculateTransmitTime(PREAMBLE_LENGTH + SFD_LENGTH)
  // The preamble and SFD transmit time, in seconds.
#define ADDRESS_TRANSMIT_LATENCY calculateTransmitTime(LENGTH_BYTE_NUMBER)

  // TODO check that the latency is approx. correct (packet sniffer said .0009 seconds per packet).

  // TODO Should I be using these? (search for TODO on MANOR) What's the correct
  // size?
#define BIT_COUNT 16
#define CC2420_BIT_XOSC16M_PD 0
#define CC2420_BIT_BIAS_PD 1
  norace bool bits[BIT_COUNT];

  // The radio state machine (see figure 23). The state is in register FSMSTATE.
#define STATE_VREG_OFF         100
#define STATE_VREG_POWERUP     101
#define STATE_IDLE               0
#define STATE_XOSC_POWERUP     102
#define STATE_XOSC_ON            1
#define STATE_RX_CALIBRATE       2 // 40
#define STATE_RX_SFD_SEARCH      3 // 4 5 6
#define STATE_RX_FRAME          16 // 40
#define STATE_RX_WAIT           14
#define STATE_TX_ACK_CALIBRATE  48
#define STATE_TX_ACK_PREAMBLE   49 // 50 51
#define STATE_TX_ACK            52 // 53 54
#define STATE_TX_CALIBRATE      32
#define STATE_TX_PREAMBLE       34 // 35 36
#define STATE_TX_FRAME          37 // 38 39
#define MAX_REAL_STATE         100 // anything > 100 has no state ID
  norace uint8_t radioState = STATE_VREG_OFF;

  // This is a hack so that we know if the radio is on.
  // It's needed because TOSSIM doesn't let us initialize our fields
  // until the mote boots.
  // However, states are just static variables in app.c, so they're
  // guaranteed to be zero; hasInitialized will always start off as FALSE.
  norace bool hasInitialized = FALSE;

  // The configuration registers on the chip.
  norace uint16_t registers[REGISTER_COUNT];
  // The contents of the memory, cleared every time the system is reset.
  norace uint8_t ram[RAM_SIZE];
  // A circular buffer which holds the messages that have arrived.
  norace uint8_t* rxQueue;
  // Byte offset specifying the first empty byte of rxQueue.
  norace uint8_t rxQueueEnd = 0;
  // A circular buffer which holds the message to be sent.
  norace uint8_t* txQueue;
  // Byte offset specifying the first empty byte of rxQueue.
  norace uint8_t txQueueEnd = 0;
  // The radio's status register.
  norace uint8_t statusReg = 0;

  // Storage for the frame being received.
  norace FrameData* receivingFrame = NULL;
  // Storage for the frame being transmitted.
  norace FrameData* transmittingFrame = NULL;
  // Whether motes will be able to hear the currently transmitting packet.
  norace Neighbor* neighbors = NULL;
  // Status of the channel.
  norace double channelEnergy = 0;
  norace uint16_t channelSourceCount = 0;
  norace bool isReceivingInterference = FALSE;

  // Ack-related state: this information must be saved across event time for
  // sending acks to work. (TODO this can be moved into the event.)
  // TODO how do we know who the ACK is being sent to? i guess it's not necessary
  // since we're broadcasting this, but then that means some nodes might misinterpret
  // the ack as responding to their own packets.
  norace uint8_t ackDsn = 0;
  // The hard-coded length of an ack, obtained by sniffing actual ack traffic.
  // This is what the packet actually says, so it doesn't include the length
  // field itself.
#define ACK_LENGTH 5

  // Interrupt mechanisms.
  norace bool fifopEnabled   = FALSE;
  norace bool fifopLowToHigh = FALSE;
  norace bool fifoEnabled    = FALSE;
  norace bool fifoLowToHigh  = FALSE;
  norace bool ccaEnabled     = FALSE;
  norace bool ccaLowToHigh   = FALSE;
  norace bool sfdEnabled     = FALSE;
  norace bool sfdLowToHigh   = FALSE;

  // Storage for receiving and transmitting data.
  norace uint8_t* rxbuf     = NULL;
  norace uint8_t* txbuf     = NULL;
  norace uint8_t* rambuf    = NULL;
  norace uint8_t* rxrambuf  = NULL;
  norace uint8_t txlen      = 0;
  norace uint8_t rxlen      = 0;
  norace uint8_t ramlen     = 0;
  norace uint16_t ramaddr   = 0;
  norace uint8_t rxramlen   = 0;
  norace uint16_t rxramaddr = 0;

  norace uint32_t stateSession = 0;

  // A data table that maps from distance to various stats for loss rate,
  // LQI, and RSSI.

#define TABLE_SIZE   24
#define TABLE_FIELDS 7

//  static double table[TABLE_SIZE][TABLE_FIELDS] = {
//    // { distance, recv mean, recv stddev, lqi mean, lqi stddev, rssi mean, rssi stddev }
//    { 1.00e+00, 1.00e+00, 0.00e+00, 9.32e-01, 4.07e-03, -5.00e+00, 0.00e+00 },
//    { 3.00e+00, 1.00e+00, 0.00e+00, 9.32e-01, 3.82e-03, -3.70e+01, 5.44e+00 },
//    { 9.00e+00, 1.00e+00, 0.00e+00, 9.28e-01, 4.89e-03, -3.76e+01, 3.71e+00 },
//    { 1.20e+01, 1.00e+00, 0.00e+00, 9.26e-01, 6.66e-03, -5.23e+01, 2.35e+00 },
//    { 1.50e+01, 1.00e+00, 0.00e+00, 9.27e-01, 6.01e-03, -5.82e+01, 3.49e+00 },
//    { 2.00e+01, 9.98e-01, 1.52e-06, 9.24e-01, 7.76e-03, -5.98e+01, 3.85e+00 },
//    { 2.50e+01, 9.93e-01, 1.60e-02, 9.11e-01, 3.15e-02, -6.28e+01, 3.52e+00 },
//    { 3.00e+01, 9.92e-01, 1.67e-02, 9.03e-01, 3.99e-02, -6.89e+01, 4.13e+00 },
//    { 3.50e+01, 9.71e-01, 8.58e-02, 8.78e-01, 9.75e-02, -7.06e+01, 3.45e+00 },
//    { 5.00e+01, 9.90e-01, 3.12e-02, 8.96e-01, 4.10e-02, -7.14e+01, 4.52e+00 },
//    { 5.50e+01, 9.00e-01, 1.59e-01, 7.96e-01, 1.70e-01, -7.06e+01, 7.69e+00 },
//    { 6.50e+01, 9.29e-01, 2.04e-01, 8.37e-01, 1.25e-01, -7.11e+01, 1.30e+01 },
//    { 7.50e+01, 6.71e-01, 2.77e-01, 5.87e-01, 1.75e-01, -7.02e+01, 1.73e+01 },
//    { 8.50e+01, 7.09e-01, 3.74e-01, 6.62e-01, 2.84e-01, -7.10e+01, 2.14e+01 },
//    { 9.50e+01, 7.73e-01, 2.57e-01, 6.36e-01, 1.80e-01, -7.03e+01, 1.49e+01 },
//    { 1.05e+02, 6.07e-01, 3.27e-01, 4.96e-01, 2.04e-01, -7.10e+01, 3.20e+01 },
//    { 1.15e+02, 4.84e-01, 1.16e-01, 3.31e-01, 1.21e-01, -7.00e+01, 2.35e+01 },
//    { 1.25e+02, 6.68e-01, 4.28e-01, 5.38e-01, 2.53e-01, -7.12e+01, 1.50e+00 },
//    { 1.35e+02, 5.07e-01, 3.13e-01, 3.55e-01, 1.41e-01, -7.61e+01, 1.40e+01 },
//    { 1.50e+02, 5.36e-01, 3.62e-01, 4.44e-01, 1.92e-01, -7.88e+01, 8.34e+00 },
//    { 1.75e+02, 3.67e-01, 2.98e-01, 3.69e-01, 1.56e-01, -8.00e+01, 3.43e+00 },
//    { 1.90e+02, 2.50e-01, 1.35e-01, 2.77e-01, 1.09e-01, -8.02e+01, 7.92e+00 },
//    { 2.00e+02, 1.24e-01, 2.67e-01, 1.47e-01, 3.37e-02, -8.20e+01, 1.40e+01 },
//    { 2.25e+02, 0.00e+00, 0.00e+00, 0.00e+00, 0.00e+00, -8.60e+01, 2.02e+00 }
//  };

  static double table[TABLE_SIZE][TABLE_FIELDS];

  //
  // Temporary debug items.
  //

  bool dbgstate[1000];
  double dbgrssi[1000];
  void DBGSTATE(uint16_t moteId, bool isSending, double rssi) {
    assert(dbgstate[moteId] == !isSending);
    if (isSending == TRUE) {
      dbgrssi[moteId] = rssi;
    } else {
      assert( dbgrssi[moteId] == rssi );
    }
    dbgstate[moteId] = isSending;
  }

  //
  // Declarations.
  //

  void setCca();
  void clearCca();
  void setSfd();
  void clearSfd();
  void setFifo();
  void clearFifo();
  void setFifop();
  void clearFifop();
  bool isFifopInverted();
  void initializeMetastate();
  void checkInitialized();
  void setState(uint8_t nextState);
  void handleVregOnEvent(event_t* ev, struct TOS_state* state);
  void cleanupVregOnEvent(event_t* ev);
  void createVregOnEvent();
  void setRegister(uint8_t reg, uint16_t value);
  void setRegisterBits(uint8_t reg, uint8_t start, uint8_t end, uint16_t value);
  uint16_t getRegisterBits(uint8_t reg, uint8_t start, uint8_t end);
  bool getRegisterBit(uint8_t reg, uint8_t bit);
  void updateNeighbors();
  Neighbor* getNeighbor(uint16_t moteId);
  FrameData* createFrame(uint16_t moteId);
  void setNeighbor(uint16_t moteId, bool isNeighbor, double lqi, double rssi);
  void removeChannelSource(double rssi, uint16_t source);
  void createTxCalibratedEvent();
  SourceData* createSourceData(uint16_t moteId);
  double getDecodedRssi(int8_t rssi);
  void createOscillatorOnEvent();
  int8_t getEncodedRssi(double rssi);
  int8_t getEncodedLqi(double lqi);
  void updateCca();
  bool getStatusReg(uint8_t bit);
  double fromDbm(double value);

  //
  // General utility functions.
  //

#define STR_LENGTH 200

  // Convenience function for outputting debug information.
  // TODO should i be using DBG_AM instead?
  void pp(const char *fmt, ...) {
    va_list argp;
    char str[MAX_BUF];
    char timeStr[128];

    va_start(argp, fmt);
    vsnprintf(str, MAX_BUF, fmt, argp);
    va_end(argp);

    printTime(timeStr, 128);
    dbg(DBG_PACKET, "HPLCC2420 (%s): %s\n", timeStr, str);
  }

  // Convenience function for outputting debug information.
  void p(const char *str) {
    pp("%s", str);
  }

  // Returns the time in seconds to transmit the given number of bytes.
  double calculateTransmitTime(uint8_t byteCount) {
    return ((double) byteCount * 8) / ((double) TX_TRANSMIT_BIT_RATE);
  }

  // Gets the MAC short address.
  uint16_t getMacAddr() {
    uint16_t addr = ((uint16_t) ram[CC2420_RAM_SHORTADR]);
    return fromLSB16(addr);
  }

  //
  // Packet-parsing functions.
  //

  // Gets the frame type.
  uint8_t getFrameType(TOS_MsgPtr msg) {
    return msg->fcfhi & 0x07;
  }

  // Checks if the frame type is valid.
  bool isValidFrameType(uint8_t type) {
    return type < 4;
  }

  // Gets the source PAN ID.
  // TODO I don't know how to find the source pan ID
  uint16_t getSrcPan(TOS_MsgPtr msg) {
    return 0;
  }

  // Gets the destination PAN ID.
  uint16_t getDestPan(TOS_MsgPtr msg) {
    return msg->destpan;
  }

  // Gets the destination short address.
  uint16_t getDestAddr(TOS_MsgPtr msg) {
    return msg->addr;
  }

  // Gets the MAC PAN ID.
  // TODO I don't know how to find the MAC pan ID
  uint16_t getMacPan(TOS_MsgPtr msg) {
    return 0;
  }

  // Performs the address recognition routine.
  // TODO what the heck are we supposed to do with ACKs? see below...
  bool isAddressCorrect(TOS_MsgPtr msg) {
    uint8_t frameType = getFrameType(msg);
//    if (!getRegisterBit(CC2420_MDMCTRL0, CC2420_MDMCTRL0_ADRDECODE)) {
//      return TRUE;
//    }
    if (!isValidFrameType(frameType)) {
      return FALSE;
    }
    if (frameType == CC2420_DEF_FCF_TYPE_BEACON &&
        !(getSrcPan(msg) == getMacPan(msg) || getMacPan(msg) == 0xFFFF)) {
      return FALSE;
    }
    if (!(getDestPan(msg) == getMacPan(msg) || getDestPan(msg) == 0xFFFF)) {
      return FALSE;
    }
    // Make sure that the address is actually present. Otherwise,
    // handleAddressReceivedEvent() should never be called, and thus neither
    // should isAddressCorrect(). In other words, acks will never get here.
    assert(msg->length + 1 >= offsetof(struct TOS_Msg, type));
    if (!(getDestAddr(msg) == getMacAddr() || getDestAddr(msg) == 0xFFFF)) {
      return FALSE;
    }
    // TODO If only source addressing fields are included in a data or MAC
    // command frame, the frame shall only be accepted if the device is a PAN
    // coordinator and the source PAN identifier matches macPANId.
    return TRUE;
  }

  // Sets the specified bits of a 16-bit integer.
  uint16_t setBits(uint16_t regValue, uint8_t start, uint8_t end, uint16_t value) {
    uint8_t mask;

    // Check for sanity.
    assert(start < 16 && end < 16 && start <= end);

    // Clear out the bits already there.
    mask = (1 << (end - start + 1)) - 1;
    regValue &= value;

    // Write in the new bits (shifted to the correct position).
    regValue |= value << start;
    return regValue;
  }

  // Gets the specified bits of a 16-bit integer.
  uint16_t getBits(uint16_t regValue, uint8_t start, uint8_t end) {
    uint8_t mask;

    // Check for sanity.
    assert(start < 16 && end < 16 && start <= end);

    // Mask out the bits we want, then shift it over.
    mask = (1 << (end - start + 1)) - 1;
    return ((regValue >> start) & mask);
  }

  // Gets the specified bit of a 16-bit integer.
  bool getBit(uint16_t regValue, uint8_t bit) {
    uint16_t value = getBits(regValue, bit, bit);
    assert(value < 2);
    return value == 1;
  }

  // Creates a StateChangeData.
  StateChangeData* createStateChangeData() {
    // Freed in handleVregOnEvent(),
    // handleOscillatorOnEvent(),
    // handleRxCalibratedEvent().
    StateChangeData* data = alloc(sizeof(StateChangeData));
    data->stateSession = stateSession;
    return data;
  }

  //
  // StdControl.
  //

  // Initializes the component.
  command result_t StdControl.init() {
    pppp(dbgStdControl, "enter StdControl.init()");

    // Note: this is never freed.
    neighbors = (Neighbor*) alloc(sizeof(Neighbor) * tos_state.num_nodes);

    return SUCCESS;
  }

  // Starts the component.
  command result_t StdControl.start() {
    uint16_t i;

    pppp(dbgStdControl, "enter StdControl.start()");

    checkInitialized();

    // TODO also part of the below hack
    dbg(DBG_POWER, "POWER: Mote %d RADIO_STATE ON at %lld \n", NODE_NUM,
        tos_state.tos_time - secondsToTicks(((double) 600) * 0.000001));
    // TODO this should be bound with VREN, somehow
    setState(STATE_VREG_POWERUP);
    // TODO note that TOSH_wait doesn't actually do anything!
    // so this timeout mechanism *will not* work
    //createVregOnEvent();
    // TODO this is a temporary workaround
    {
      event_t* ev = alloc(sizeof(event_t));
      ev->data = createStateChangeData();
      ev->cleanup = cleanupVregOnEvent;
      handleVregOnEvent(ev, NULL);
    }

    // Clear all pins.
    TOSH_CLR_CC_SFD_PIN();
    TOSH_CLR_RADIO_CCA_PIN();
    TOSH_CLR_CC_FIFO_PIN();
    TOSH_CLR_CC_FIFOP_PIN();

    // Reset the RAM.
    for (i = 0; i < RAM_SIZE; i++) {
      ram[i] = 0;
    }

    // Initialize neighbor table.
    for (i = 0; i < tos_state.num_nodes; i++) {
      setNeighbor(i, FALSE, 0, 0);
    }

    // Initialize register values (to their defaults).
    for (i = 0; i < REGISTER_COUNT; i++) {
      registers[i] = 0;
    }
    setRegisterBits(CC2420_RSSI, CC2420_RSSI_CCA_THRESH_START,
        CC2420_RSSI_CCA_THRESH_END, DEFAULT_CCA_THRESHOLD);
    setRegisterBits(CC2420_IOCFG0, CC2420_IOCFG0_FIFOTHR_START,
        CC2420_IOCFG0_FIFOTHR_END, DEFAULT_FIFO_THRESHOLD);
    setRegisterBits(CC2420_MDMCTRL0, CC2420_MDMCTRL0_CCAMODE_START,
        CC2420_MDMCTRL0_CCAMODE_END, DEFAULT_CCA_MODE);
    statusReg = 0;

    // Initialize buffer markers and event pointers.
    rxQueueEnd     = 0;
    txQueueEnd     = 0;
    rxbuf          = NULL;
    txbuf          = NULL;
    rambuf         = NULL;
    rxrambuf       = NULL;
    txlen          = 0;
    rxlen          = 0;
    ramlen         = 0;
    ramaddr        = 0;
    rxramlen       = 0;
    rxramaddr      = 0;;

    // Initialize interrupt mechanism state.
    fifopEnabled   = FALSE;
    fifopLowToHigh = FALSE;
    fifoEnabled    = FALSE;
    fifoLowToHigh  = FALSE;
    ccaEnabled     = FALSE;
    ccaLowToHigh   = FALSE;
    sfdEnabled     = FALSE;
    sfdLowToHigh   = FALSE;

    // Initialize various state information.
    ackDsn                   = 0;
    receivingFrame           = NULL;
    transmittingFrame        = NULL;

    return SUCCESS;
  }

  // Stops the component.
  command result_t StdControl.stop() {
    pppp(dbgStdControl, "enter StdControl.stop()");
    setState(STATE_VREG_OFF);
    if (receivingFrame != NULL) {
      free(receivingFrame->frame);
      free(receivingFrame);
      receivingFrame = NULL;
    }
    return SUCCESS;
  }

  //
  // Radio state.
  //

  // Initializes state variables that do not correspond to states actually
  // in the radio chip.
  void initializeMetastate() {
    hasInitialized = TRUE;
    radioState = STATE_VREG_OFF;
    channelEnergy            = 0; // TODO find a better starting value?
    channelSourceCount       = 0;
    isReceivingInterference  = FALSE;
    txQueue = ram;
    rxQueue = ram + QUEUE_SIZE;

    // TODO note that this is a hack around CIL's inability to parse the table structure that is commented out near the start of this file.
    table[ 0][0] = 1.00e+00; table[ 0][1] = 1.00e+00; table[ 0][2] = 0.00e+00; table[ 0][3] = 9.32e-01; table[ 0][4] = 4.07e-03; table[ 0][5] = -5.00e+00; table[ 0][6] = 0.00e+00;
    table[ 1][0] = 3.00e+00; table[ 1][1] = 1.00e+00; table[ 1][2] = 0.00e+00; table[ 1][3] = 9.32e-01; table[ 1][4] = 3.82e-03; table[ 1][5] = -3.70e+01; table[ 1][6] = 5.44e+00;
    table[ 2][0] = 9.00e+00; table[ 2][1] = 1.00e+00; table[ 2][2] = 0.00e+00; table[ 2][3] = 9.28e-01; table[ 2][4] = 4.89e-03; table[ 2][5] = -3.76e+01; table[ 2][6] = 3.71e+00;
    table[ 3][0] = 1.20e+01; table[ 3][1] = 1.00e+00; table[ 3][2] = 0.00e+00; table[ 3][3] = 9.26e-01; table[ 3][4] = 6.66e-03; table[ 3][5] = -5.23e+01; table[ 3][6] = 2.35e+00;
    table[ 4][0] = 1.50e+01; table[ 4][1] = 1.00e+00; table[ 4][2] = 0.00e+00; table[ 4][3] = 9.27e-01; table[ 4][4] = 6.01e-03; table[ 4][5] = -5.82e+01; table[ 4][6] = 3.49e+00;
    table[ 5][0] = 2.00e+01; table[ 5][1] = 9.98e-01; table[ 5][2] = 1.52e-06; table[ 5][3] = 9.24e-01; table[ 5][4] = 7.76e-03; table[ 5][5] = -5.98e+01; table[ 5][6] = 3.85e+00;
    table[ 6][0] = 2.50e+01; table[ 6][1] = 9.93e-01; table[ 6][2] = 1.60e-02; table[ 6][3] = 9.11e-01; table[ 6][4] = 3.15e-02; table[ 6][5] = -6.28e+01; table[ 6][6] = 3.52e+00;
    table[ 7][0] = 3.00e+01; table[ 7][1] = 9.92e-01; table[ 7][2] = 1.67e-02; table[ 7][3] = 9.03e-01; table[ 7][4] = 3.99e-02; table[ 7][5] = -6.89e+01; table[ 7][6] = 4.13e+00;
    table[ 8][0] = 3.50e+01; table[ 8][1] = 9.71e-01; table[ 8][2] = 8.58e-02; table[ 8][3] = 8.78e-01; table[ 8][4] = 9.75e-02; table[ 8][5] = -7.06e+01; table[ 8][6] = 3.45e+00;
    table[ 9][0] = 5.00e+01; table[ 9][1] = 9.90e-01; table[ 9][2] = 3.12e-02; table[ 9][3] = 8.96e-01; table[ 9][4] = 4.10e-02; table[ 9][5] = -7.14e+01; table[ 9][6] = 4.52e+00;
    table[10][0] = 5.50e+01; table[10][1] = 9.00e-01; table[10][2] = 1.59e-01; table[10][3] = 7.96e-01; table[10][4] = 1.70e-01; table[10][5] = -7.06e+01; table[10][6] = 7.69e+00;
    table[11][0] = 6.50e+01; table[11][1] = 9.29e-01; table[11][2] = 2.04e-01; table[11][3] = 8.37e-01; table[11][4] = 1.25e-01; table[11][5] = -7.11e+01; table[11][6] = 1.30e+01;
    table[12][0] = 7.50e+01; table[12][1] = 6.71e-01; table[12][2] = 2.77e-01; table[12][3] = 5.87e-01; table[12][4] = 1.75e-01; table[12][5] = -7.02e+01; table[12][6] = 1.73e+01;
    table[13][0] = 8.50e+01; table[13][1] = 7.09e-01; table[13][2] = 3.74e-01; table[13][3] = 6.62e-01; table[13][4] = 2.84e-01; table[13][5] = -7.10e+01; table[13][6] = 2.14e+01;
    table[14][0] = 9.50e+01; table[14][1] = 7.73e-01; table[14][2] = 2.57e-01; table[14][3] = 6.36e-01; table[14][4] = 1.80e-01; table[14][5] = -7.03e+01; table[14][6] = 1.49e+01;
    table[15][0] = 1.05e+02; table[15][1] = 6.07e-01; table[15][2] = 3.27e-01; table[15][3] = 4.96e-01; table[15][4] = 2.04e-01; table[15][5] = -7.10e+01; table[15][6] = 3.20e+01;
    table[16][0] = 1.15e+02; table[16][1] = 4.84e-01; table[16][2] = 1.16e-01; table[16][3] = 3.31e-01; table[16][4] = 1.21e-01; table[16][5] = -7.00e+01; table[16][6] = 2.35e+01;
    table[17][0] = 1.25e+02; table[17][1] = 6.68e-01; table[17][2] = 4.28e-01; table[17][3] = 5.38e-01; table[17][4] = 2.53e-01; table[17][5] = -7.12e+01; table[17][6] = 1.50e+00;
    table[18][0] = 1.35e+02; table[18][1] = 5.07e-01; table[18][2] = 3.13e-01; table[18][3] = 3.55e-01; table[18][4] = 1.41e-01; table[18][5] = -7.61e+01; table[18][6] = 1.40e+01;
    table[19][0] = 1.50e+02; table[19][1] = 5.36e-01; table[19][2] = 3.62e-01; table[19][3] = 4.44e-01; table[19][4] = 1.92e-01; table[19][5] = -7.88e+01; table[19][6] = 8.34e+00;
    table[20][0] = 1.75e+02; table[20][1] = 3.67e-01; table[20][2] = 2.98e-01; table[20][3] = 3.69e-01; table[20][4] = 1.56e-01; table[20][5] = -8.00e+01; table[20][6] = 3.43e+00;
    table[21][0] = 1.90e+02; table[21][1] = 2.50e-01; table[21][2] = 1.35e-01; table[21][3] = 2.77e-01; table[21][4] = 1.09e-01; table[21][5] = -8.02e+01; table[21][6] = 7.92e+00;
    table[22][0] = 2.00e+02; table[22][1] = 1.24e-01; table[22][2] = 2.67e-01; table[22][3] = 1.47e-01; table[22][4] = 3.37e-02; table[22][5] = -8.20e+01; table[22][6] = 1.40e+01;
    table[23][0] = 2.25e+02; table[23][1] = 0.00e+00; table[23][2] = 0.00e+00; table[23][3] = 0.00e+00; table[23][4] = 0.00e+00; table[23][5] = -8.60e+01; table[23][6] = 2.02e+00;
  }

  // If the mote has not been turned on before, then we had better initialize the values!
  void checkInitialized() {
    if (!hasInitialized) {
      initializeMetastate();
    }
  }

  // Gets the state of the system.
  uint8_t getState() {
    return radioState;
  }

  // Gets the string representation of the specified state.
  char* getStateStr(uint8_t state) {
    char* stateStr = NULL;
    switch (state) {
      case STATE_VREG_OFF:
        stateStr = "STATE_VREG_OFF";
        break;
      case STATE_VREG_POWERUP:
        stateStr = "STATE_VREG_POWERUP";
        break;
      case STATE_IDLE:
        stateStr = "STATE_IDLE";
        break;
      case STATE_XOSC_POWERUP:
        stateStr = "STATE_XOSC_POWERUP";
        break;
      case STATE_XOSC_ON:
        stateStr = "STATE_XOSC_ON";
        break;
      case STATE_RX_CALIBRATE:
        stateStr = "STATE_RX_CALIBRATE";
        break;
      case STATE_RX_SFD_SEARCH:
        stateStr = "STATE_RX_SFD_SEARCH";
        break;
      case STATE_RX_FRAME:
        stateStr = "STATE_RX_FRAME";
        break;
      case STATE_RX_WAIT:
        stateStr = "STATE_RX_WAIT";
        break;
      case STATE_TX_ACK_CALIBRATE:
        stateStr = "STATE_TX_ACK_CALIBRATE";
        break;
      case STATE_TX_ACK_PREAMBLE:
        stateStr = "STATE_TX_ACK_PREAMBLE";
        break;
      case STATE_TX_ACK:
        stateStr = "STATE_TX_ACK";
        break;
      case STATE_TX_CALIBRATE:
        stateStr = "STATE_TX_CALIBRATE";
        break;
      case STATE_TX_PREAMBLE:
        stateStr = "STATE_TX_PREAMBLE";
        break;
      case STATE_TX_FRAME:
        stateStr = "STATE_TX_FRAME";
        break;
      default:
        fail("not a valid state");
    }

    return stateStr;
  }

  // Update the state of the radio, stored in register FSMSTATE.
  void setState(uint8_t nextState) {
    // Check that the transition from the current state to the next one is
    // valid.
    switch (nextState) {
      case STATE_VREG_OFF:
        // TODO implement/fix
        call PowerState.radioStop();
        break;
      case STATE_VREG_POWERUP:
        assert(radioState == STATE_VREG_OFF);
        call PowerState.radioStart();
        break;
      case STATE_IDLE:
        // In case we were coming in from some non-powerup state.
        call PowerState.radioStart();
        break;
      case STATE_XOSC_POWERUP:
        assert(radioState == STATE_IDLE);
        call PowerState.radio("OSC_ON");
        break;
      case STATE_XOSC_ON:
        assert(radioState != STATE_IDLE);
        call PowerState.radio("OSC_ON");
        break;
      case STATE_RX_CALIBRATE:
        // TODO so apparently, we can accept multiple (quick) calls to SRXON, right?
        // (see TuneManual, followed by RxMode, in lib)
        call PowerState.radioRxMode();
        assert(radioState == STATE_XOSC_ON ||
            radioState == STATE_RX_CALIBRATE ||
            radioState == STATE_TX_FRAME ||
            radioState == STATE_TX_ACK);
        break;
      case STATE_RX_SFD_SEARCH:
        // TODO so apparently, we can accept multiple (quick) calls to SRXON, right?
        // (see TuneManual, followed by RxMode, in lib)
        // TODO this is dangerous since we can have several overlapping calibration events!
        assert(radioState == STATE_RX_CALIBRATE ||
            radioState == STATE_RX_SFD_SEARCH ||
            radioState == STATE_RX_WAIT);
        break;
      case STATE_RX_FRAME:
        assert(radioState == STATE_RX_SFD_SEARCH);
        break;
      case STATE_RX_WAIT:
        assert(radioState == STATE_RX_FRAME);
        break;
      case STATE_TX_ACK_CALIBRATE:
        call PowerState.radioTxMode();
        assert(radioState == STATE_RX_FRAME ||
            radioState == STATE_RX_SFD_SEARCH);
        break;
      case STATE_TX_ACK_PREAMBLE:
        assert(radioState == STATE_TX_ACK_CALIBRATE);
        break;
      case STATE_TX_ACK:
        assert(radioState == STATE_TX_ACK_PREAMBLE);
        break;
      case STATE_TX_CALIBRATE:
        call PowerState.radioTxMode();
        assert(radioState == STATE_TX_ACK ||
            radioState == STATE_RX_CALIBRATE ||
            radioState == STATE_RX_SFD_SEARCH ||
            radioState == STATE_RX_FRAME ||
            radioState == STATE_RX_WAIT);
        break;
      case STATE_TX_PREAMBLE:
        assert(radioState == STATE_TX_CALIBRATE);
        break;
      case STATE_TX_FRAME:
        assert(radioState == STATE_TX_PREAMBLE);
        break;
      default:
        fail("Not a valid state");
    }
    stateSession++;

    pp("setState( from %s to %s )", getStateStr(radioState), getStateStr(nextState));

    if (nextState < MAX_REAL_STATE) {
      registers[CC2420_FSMSTATE] = nextState;
    }
    radioState = nextState;
  }

  //
  // Registers.
  //

  // Verifies that the register ID is valid.
  void checkRegisterId(uint8_t reg) {
    assert(reg < 64);
  }

  // Gets the value (all bits) of a register.
  uint16_t getRegister(uint8_t reg) {
    checkRegisterId(reg);
    return registers[reg];
  }

  // Sets the value (all bits) of a register.
  void setRegister(uint8_t reg, uint16_t value) {
    uint16_t oldValue;
    checkRegisterId(reg);
    oldValue = registers[reg];
    registers[reg] = value;
    switch (reg) {
      case CC2420_IOCFG0:
        {
          // Check the polarity.
          bool wasInverted = getBit(oldValue, CC2420_IOCFG0_FIFOPPOL);
          bool isInverted = isFifopInverted();
          if (wasInverted != isInverted) {
            // Flip the pin.
            if (TOSH_READ_CC_FIFOP_PIN() == 0) {
              setFifop();
            } else {
              clearFifop();
            }
          }
          break;
        }
      case CC2420_IOCFG1:
        {
          // Check the function of the CCA pin.
          uint8_t ccaMux = getRegisterBits(CC2420_IOCFG1,
              CC2420_IOCFG1_CCAMUX_START, CC2420_IOCFG1_CCAMUX_END);
          switch (ccaMux) {
            case 0:
              updateCca();
              break;
            case 24:
              if (getStatusReg(CC2420_XOSC16M_STABLE)) {
                setCca();
              } else {
                clearCca();
              }
              break;
          }
          break;
        }
      case CC2420_TXCTRL:
        {
          uint8_t powerLevel = getRegisterBits(CC2420_TXCTRL,
              CC2420_TXCTRL_PAPWR_START, CC2420_TXCTRL_PAPWR_END);
          int8_t powerLevelDbm;
          uint8_t powerState;
          switch (powerLevel) {
            case 31:
              powerLevelDbm = 0;
              powerState = 0;
              break;
            case 27:
              powerLevelDbm = -1;
              powerState = 1;
              break;
            case 23:
              powerLevelDbm = -3;
              powerState = 2;
              break;
            case 19:
              powerLevelDbm = -5;
              powerState = 3;
              break;
            case 15:
              powerLevelDbm = -7;
              powerState = 4;
              break;
            case 11:
              powerLevelDbm = -10;
              powerState = 5;
              break;
            case 7:
              powerLevelDbm = -15;
              powerState = 6;
              break;
            case 3:
              powerLevelDbm = -25;
              powerState = 7;
              break;
            default:
              fail("invalid power level!");
              break;
          }
          call PowerState.radioRFPower(powerState);
        }
        break;
    }
  }

  // Sets the specified bits of a register between start and end, inclusive.
  void setRegisterBits(uint8_t reg, uint8_t start, uint8_t end, uint16_t value) {
    uint16_t regValue = getRegister(reg);
    regValue = setBits(regValue, start, end, value);
    setRegister(reg, regValue);
  }

  // Gets the specified bits of a register between start and end, inclusive.
  uint16_t getRegisterBits(uint8_t reg, uint8_t start, uint8_t end) {
    return getBits(getRegister(reg), start, end);
  }

  // Gets the specified bit of a register.
  bool getRegisterBit(uint8_t reg, uint8_t bit) {
    uint16_t value;
    checkRegisterId(reg);
    value = getRegisterBits(reg, bit, bit);
    assert(value < 2);
    return value == 1;
  }

  // Checks to see if the specified bit is a valid one in the status register.
  void checkStatusRegBit(uint8_t bit) {
    bool bitValid;
    switch (bit) {
      case CC2420_XOSC16M_STABLE:
      case CC2420_TX_UNDERFLOW:
      case CC2420_ENC_BUSY:
      case CC2420_TX_ACTIVE:
      case CC2420_LOCK:
      case CC2420_RSSI_VALID:
        bitValid = 1;
        break;
      default:
        bitValid = 0;
    }
    assert(bitValid);
  }

  // Gets the specified bit of the status register.
  bool getStatusReg(uint8_t bit) {
    checkStatusRegBit(bit);
    return statusReg & (1 << bit) ? TRUE : FALSE;
  }

  // Sets the specified bit of the status register.
  void setStatusReg(uint8_t bit, bool value) {
    checkStatusRegBit(bit);
    if (value) {
      statusReg |= (1 << bit);
    } else {
      statusReg &= ~(1 << bit);
    }
  }

  //
  // Clear channel assessment.
  //

  // Update the CCA pin, using the two procedures specified in the datasheet.
  void updateCca() {
    bool isChannelClear = FALSE;
    uint8_t ccaMux;
    uint8_t ccaMode = getRegisterBits(CC2420_MDMCTRL0,
        CC2420_MDMCTRL0_CCAMODE_START, CC2420_MDMCTRL0_CCAMODE_END);
    int8_t ccaThresholdEncoded = getRegisterBits(CC2420_RSSI, // TODO is this a valid cast?
        CC2420_RSSI_CCA_THRESH_START, CC2420_RSSI_CCA_THRESH_END);
    double ccaThreshold = fromDbm(getDecodedRssi(ccaThresholdEncoded));
    switch (ccaMode) {
      case 0:
        fail("reserved CCA mode.");
        break;
      case 1:
        isChannelClear = channelEnergy < ccaThreshold;
        break;
      case 2:
        // If there's only one source, then the data is valid.
        // Otherwise, then the data is not valid, so the channel is clear.
        isChannelClear = channelSourceCount != 1;
        break;
      case 3:
        isChannelClear = channelSourceCount != 1 && channelEnergy < ccaThreshold;
        break;
      default:
        fail("not a valid CCA mode.");
        break;
    }

    ccaMux = getRegisterBits(CC2420_IOCFG1,
        CC2420_IOCFG1_CCAMUX_START, CC2420_IOCFG1_CCAMUX_END);
    if (ccaMux == 0) {
      if (isChannelClear) {
        setCca();
      } else {
        clearCca();
      }
    }
  }

  // Converts from the value from dBm to mW.
  // Here are some example values, in the form (dBm: mW):
  // -86: 5e-5
  // -77: 1.42e-4
  // -5:  0.56234
  double fromDbm(double value) {
    return pow(10, value / 20);
  }

  // This adjusts the CCA observed by the current node by the given energy level.
  void removeChannelSource(double rssi, uint16_t source) {
    if (channelSourceCount == 0) {
      dbg(DBG_USR3, "==0: source=%hd, count=%hd", channelSourceCount, source);
      fail("trying to remove a source when we have 0 sources");
    }
    channelSourceCount--;
    channelEnergy -= fromDbm(rssi);
    if (channelSourceCount == 0) {
      if (!(channelEnergy < 1e-10 &&
          channelEnergy > -1e-10)) {
        dbg(DBG_USR3, "!=0: count=%hd, energy=%f, source=%hd", channelSourceCount, channelEnergy, source);
        fail("0 sources but non-0 energy");
      }
      isReceivingInterference = FALSE;
      if (getState() != STATE_VREG_OFF) {
        clearSfd();
      }
    }
    {
      char timeStr[128];
      printTime(timeStr, 128);
      //dbg(DBG_USR3, "%s removeChannelSource(): count=%hd, source=%hd, energy=%f\n", timeStr, channelSourceCount, source, channelEnergy);
    }
    if (getState() != STATE_VREG_OFF) {
      updateCca();
    }
  }

  // TODO is there any other situation in which the channel data could be invalidated, aside from multiple sources talking?
  // This adjusts the CCA observed by the current node by the given energy level.
  void addChannelSource(double rssi, uint16_t source) {
    channelSourceCount++;
    channelEnergy += fromDbm(rssi);
    if (channelSourceCount > 0) {
      if (!(channelSourceCount < 100)) {
        printf(">=100: %hd, %hd, %f, %hd", NODE_NUM, channelSourceCount, channelEnergy, source);
        exit(1);
      }
    }
    if (channelSourceCount > 1) {
      isReceivingInterference = TRUE;
    }
    {
      char timeStr[128];
      printTime(timeStr, 128);
      dbg(DBG_USR3, "%s addChannelSource(): count=%hd, source=%hd, energy=%f\n", timeStr, channelSourceCount, source, channelEnergy);
    }
    if (getState() != STATE_VREG_OFF) {
      updateCca();
    }
  }

  //
  // Packet loss.
  //

  // Accessor function.
  Neighbor* getNeighbor(uint16_t moteId) {
    return &neighbors[moteId];
  }

  // Accessor function.
  void setNeighbor(uint16_t moteId, bool isNeighbor, double lqi, double rssi) {
    neighbors[moteId].isNeighbor = isNeighbor;
    neighbors[moteId].lqi = lqi;
    neighbors[moteId].rssi = rssi;
  }

  // Determines whether the packet should be dropped, using the giant
  // table above to calculate the probability.
  bool canSend(int receiver, double* lqi, double* rssi) {
    static uint8_t DISTANCE     = 0;
    static uint8_t RECV_MEAN    = 1;
    static uint8_t RECV_STDDEV  = 2;
    static uint8_t LQI_MEAN     = 3;
    static uint8_t LQI_STDDEV   = 4;
    static uint8_t RSSI_MEAN    = 5;
    static uint8_t RSSI_STDDEV  = 6;

    static uint8_t ADC_LOCATION_X = 128;
    static uint8_t ADC_LOCATION_Y = 129;

    // Divide by SCALE, and multiply by mote scale width/height.
    // This was deduced from CoordinateTransformer.java,
    // (reflect/)SimObject.java, and LocationPlugin.java.
    uint16_t senderX = generic_adc_read(NODE_NUM, ADC_LOCATION_X, 0) / 65535.0 * 100;
    uint16_t senderY = generic_adc_read(NODE_NUM, ADC_LOCATION_Y, 0) / 65535.0 * 100;
    uint16_t receiverX = generic_adc_read(receiver, ADC_LOCATION_X, 0) / 65535.0 * 100;
    uint16_t receiverY = generic_adc_read(receiver, ADC_LOCATION_Y, 0) / 65535.0 * 100;

    double distance = sqrt(pow(senderX - receiverX, 2) + pow(senderY - receiverY, 2));

    double prob;
    double rval;
    bool shouldSend;

    // Look for the right distance in the table
    uint8_t table_index;
    for (table_index = 0; table_index < TABLE_SIZE; table_index++) {
      if (distance <= table[table_index][DISTANCE]) {
        break;
      }
    }
    if (table_index == TABLE_SIZE) {
      table_index--;
    }

    // Generate values for the LQI and RSSI.
    // TODO generate random values
    *lqi = table[table_index][LQI_MEAN];
    *rssi = table[table_index][RSSI_MEAN];

    prob = table[table_index][RECV_MEAN];
    rval = (rand()*1.0) / (RAND_MAX*1.0);
    shouldSend = rval <= prob;

    pp("canSend(to=%d): senderX = %d, senderY = %d, receiverX = %d, receiverY = %d, "
        "distance = %f, recv = %f, rval = %f, lqi = %f, rssi = %f, %s",
        receiver, senderX, senderY, receiverX, receiverY, distance, prob, rval,
        *lqi, *rssi, shouldSend ? "should send" : "should NOT send");

    return shouldSend;
  }

  // Update the neighbors list.
  void updateNeighbors() {
    uint16_t moteId;
    double lqi = 0;
    double rssi = 0;
    for (moteId = 0; moteId < tos_state.num_nodes; moteId++) {
      bool result = canSend(moteId, &lqi, &rssi);
      setNeighbor(moteId, result, lqi, rssi);
    }
  }

  // Converts the specified energy level (in dB) to its encoding in the packet.
  // The RSSI is going to be something between -5 dB and -90 dB.
  // Adding 45 centers this about 0 (from 40 to -45).
  int8_t getEncodedRssi(double rssi) {
    double value = rssi + 45;
    assert(value >= INT8_MIN && value <= INT8_MAX);
    return (int8_t) value;
  }

  // Converts the specified LQI value to its encoding in the packet.
  // The encoded range is from 106 to 65
  // This is actually a 7-bit value.
  int8_t getEncodedLqi(double lqi) {
    double value = (110 - 65) * lqi + 65;
    assert(value >= 0 && value < (UINT8_MAX >> 1));
    return (uint8_t) value;
  }

  // Converts the RSSI from its packet-encoded representation to dBm.
  double getDecodedRssi(int8_t rssi) {
    double value = rssi - 45;
    return value;
  }

//  //
//  // Finish-receive events.
//  //
//
//  // Finish-receive data.
//  typedef struct FinishReceiveEventData {
//    uint16_t src;
//    TOS_MsgPtr msg;
//  } FinishReceiveEventData;
//
//  // Handles finish-receive events by firing the appropriate pins, writing to
//  // the queue, and sending an ack.
//  void handleFinishReceiveEvent(event_t* ev, struct TOS_state* state) {
//    FinishReceiveEventData* data = (FinishReceiveEventData*) ev->data;
//    TOS_MsgPtr msg = data->msg;
//    uint8_t* arr = (uint8_t*) msg;
//    uint8_t length = msg->length + 1 + 2;
//    bool overflow = FALSE;
//
//    p("enter handleFinishReceiveEvent()");
//
//    if (DEBUG_SENDING) {
//      int i;
//      pp("in dump: [ ");
//      for (i = 0; i < length; i++) {
//        pp("%d ", (int) arr[i]);
//      }
//      pp("]");
//
//      {
//        int8_t rssi = ((int8_t*) arr)[length - 2]; // TODO is the casting good?
//        uint8_t lqi = arr[length - 1] & 0x7F; // remove CRC
//        pp("got rssi = %d, lqi = %d", (int) rssi, (int) lqi);
//      }
//
//      pp("mdmctrl0 = %d or %02x", getRegister(CC2420_MDMCTRL0), getRegister(CC2420_MDMCTRL0));
//      pp("arr[-1] = %d or %02x", arr[msg->length - 1], arr[msg->length - 1]);
//    }
//
//    if (getRegisterBit(CC2420_MDMCTRL0, CC2420_MDMCTRL0_AUTOCRC)) {
//      //arr[length - 1] |= (arr[length - 2] == 0 && arr[length - 1] == 0) << 7;
//      if (DEBUG_SENDING) {
//        pp("fcs = [ %d %d or %02x %02x ]",
//            arr[msg->length], arr[msg->length + 1],
//            arr[msg->length], arr[msg->length + 1]);
//        pp("arr[-1] = %d or %02x", arr[msg->length - 1], arr[msg->length - 1]);
//      }
//    }
//
//    // Note that nothing gets to happen between the SFD/CCA changes!
//    {
//      clearCca();
//      setSfd();
//
//      // Write to the RX FIFO.
//      if (rxQueueEnd + length > QUEUE_SIZE) {
//        clearFifo();
//        setFifop();
//        overflow = TRUE;
//      } else {
//        memcpy(rxQueue + rxQueueEnd, msg, length);
//        rxQueueEnd += length;
//      }
//
//      clearSfd();
//      setCca();
//    }
//
//    // Send an ack.
//    if (!overflow) {
//      // TODO is this right? it seems from figure 12 that i should be setting
//      // FIFOP instead of clearing it, but the stack never expects that.
//      clearFifop();
//
//      if (DEBUG_SENDING) {
//        pp("ack conditions: %d %d %d", (msg->fcfhi & CC2420_DEF_FCF_HI_ACK) != 0,
//            msg->addr == NODE_NUM,
//            ((arr[length - 1] >> 7) & 1) == 1);
//      }
//
//      if ((msg->fcfhi & CC2420_DEF_FCF_HI_ACK) != 0 &&
//          msg->addr == NODE_NUM &&
//          ((arr[length - 1] >> 7) & 1) == 1) {
//        // TODO don't send if there's a concurrent tranmission (would that be the right behavior? the docs don't say anything about what happens in this case)
//        // TODO i should really be sending this 12 symbols after the end of incoming frame...
//        if (getStatusReg(CC2420_TX_ACTIVE) == 0) {
//          sendAck(data->src, msg->dsn);
//        }
//      }
//    }
//
//    event_cleanup(ev);
//  }
//
//  // Cleans up finish-receive events.
//  void cleanupFinishReceiveEvent(event_t* ev) {
//    FinishReceiveEventData* data = (FinishReceiveEventData*) ev->data;
//    free(data->msg);
//    free(data);
//    free(ev);
//  }
//
//  // Creates finish-receive events.
//  void createFinishReceiveEvent(uint16_t addr, double lqi, double rssi) {
//    uint8_t length = 0;
//    event_t* ev = (event_t*) malloc(sizeof(event_t));
//    FinishReceiveEventData* data = (FinishReceiveEventData*) malloc(sizeof(FinishReceiveEventData));
//
//    pp("enter createFinishReceiveEvent(%d)", addr);
//
//    if (isSendingAck) {
//      TOS_MsgPtr msg = NULL;
//
//      length = ACK_LENGTH + 1;
//      msg = (TOS_MsgPtr) malloc(length);
//      data->msg = msg;
//
//      msg->length = ACK_LENGTH;
//      msg->fcfhi = CC2420_DEF_FCF_TYPE_ACK;
//      msg->fcflo = CC2420_DEF_FCF_LO; // TODO why is the bit in Reserved set?
//      msg->dsn = ackDsn;
//    } else {
//      uint8_t* arr = NULL;
//      uint8_t origLength = txQueue[0] + 1;
//      length = origLength;
//
//      // TODO but change this to the auto-lqi/rssi stuff
//      if (getRegisterBit(CC2420_MDMCTRL0, CC2420_MDMCTRL0_AUTOCRC)) {
//        length += 2;
//      }
//
//      // Note that in broadcasts, we're copying the data for each mote.
//      data->msg = (TOS_MsgPtr) malloc(length);
//      memcpy(data->msg, txQueue, origLength - MSG_FOOTER_SIZE);
//      arr = (uint8_t*) data->msg;
//
//      // Set FCS values.
//      {
//        int8_t rssiValue = rssi + 45;
//        uint8_t lqiValue = (110 - 65) * lqi + 65;
//        (int8_t) arr[length - 2] = rssiValue; // TODO is the casting good?
//        arr[length - 1] = (1 << 7) | lqiValue;
//
//        if (DEBUG_SENDING) {
//          int i;
//          pp("sending rssi = %d, lqi = %d", (int) rssiValue, (int) lqiValue);
//          pp("out dump: [ ");
//          for (i = 0; i < length; i++) {
//            pp("%d ", (int) arr[i]);
//          }
//          pp("]");
//        }
//      }
//    }
//
//    {
//      // TODO how do I calculate the actual time needed to transmit? (If I should?)
//      //uint16_t transmitTime = (preambleLength + length) * byteTransmitTime;
//
//      uint16_t transmitTime = secondsToTicks(TRANSMIT_LATENCY);
//      char buf[128];
//      printTime(buf, 128);
//      pp("  %s, tos_state.tos_time = %d, transmitTime = %d",
//          buf, (int) tos_state.tos_time, (int) transmitTime);
//      data->src = NODE_NUM;
//      ev->data = data;
//      ev->mote = addr;
//      ev->time = tos_state.tos_time + transmitTime;
//      ev->handle = handleFinishReceiveEvent;
//      ev->cleanup = cleanupFinishReceiveEvent;
//      ev->pause = 0;
//      TOS_queue_insert_event(ev);
//    }
//  }
//
//  //
//  // Finish-send events.
//  //
//
//  // Handles finish-send events.
//  void handleFinishSendEvent(event_t* ev, struct TOS_state* state) {
//    RadioMsgSentEvent radioEvent;
//    TOS_MsgPtr msg = (TOS_MsgPtr) txQueue;
//    double lqi, rssi;
//
//    p("enter handleFinishSendEvent()");
//
//    // Note that we are copying some garbage here.
//    memcpy(&radioEvent.message, msg, sizeof(radioEvent.message));
//
//    if (DEBUG_SENDING) {
//      // Dump the packet contents.
//      uint8_t i;
//      for (i = 0; i < sizeof(radioEvent.message); i++) {
//        printf("%02x ", ((uint8_t*) &radioEvent)[i]);
//      }
//    }
//
//    // TOSSIM-related tools expect CRC in {0,1}, not an actual CRC value.
//    radioEvent.message.crc = 1;
//
//    // Determine whether the packet should be dropped - if not, then "send" it.
//    if (isSendingAck) {
//      if (canSend(NODE_NUM, ackDest, ACK_LENGTH, &lqi, &rssi)) {
//        createFinishReceiveEvent(ackDest, lqi, rssi);
//        sendTossimEvent(NODE_NUM, AM_RADIOMSGSENTEVENT, tos_state.tos_time, &radioEvent);
//      }
//    } else {
//      // actually send out the packets to each of the motes via events
//      if (msg->addr != TOS_BCAST_ADDR) {
//        // TODO why add 7?
//        if (canSend(NODE_NUM, msg->addr, msg->length + 7, &lqi, &rssi)) {
//          createFinishReceiveEvent(msg->addr, lqi, rssi);
//          sendTossimEvent(NODE_NUM, AM_RADIOMSGSENTEVENT, tos_state.tos_time, &radioEvent);
//        }
//      } else {
//        uint16_t destAddr;
//        for (destAddr = 0; destAddr < tos_state.num_nodes; destAddr++) {
//          if (canSend(NODE_NUM, destAddr, msg->length + 7, &lqi, &rssi)) {
//            createFinishReceiveEvent(destAddr, lqi, rssi);
//            sendTossimEvent(NODE_NUM, AM_RADIOMSGSENTEVENT, tos_state.tos_time, &radioEvent);
//          }
//        }
//      }
//    }
//
//    // Set some state (and signal that they've changed).
//    setStatusReg(CC2420_TX_ACTIVE, FALSE);
//    clearSfd();
//    setCca();
//
//    event_cleanup(ev);
//  }
//
//  // Cleans up finish-send events.
//  void cleanupFinishSendEvent(event_t* ev) {
//    free(ev);
//  }
//
//  // Creates finish-send events.
//  void createFinishSendEvent() {
//    event_t* ev = (event_t*) malloc(sizeof(event_t));
//    p("enter createFinishSendEvent()");
//    ev->mote = NODE_NUM;
//    ev->data = NULL;
//    ev->time = tos_state.tos_time + TRANSMIT_LOCAL_LATENCY;
//    ev->handle = handleFinishSendEvent;
//    ev->cleanup = cleanupFinishSendEvent;
//    ev->pause = 0;
//    TOS_queue_insert_event(ev);
//  }

  //
  // Frame-received event.
  //

  // Handles frame-received events.
  void handleFrameReceivedEvent(event_t* ev, struct TOS_state* state) {
    bool isOverflow = FALSE;
    FrameData* data;
    TOS_MsgPtr msg;
    uint8_t length;
    uint8_t* frame;
    bool crcOk;

    data = (FrameData*) ev->data;
    pp("enter handleFrameReceivedEvent(from=%hd, rssi=%f)",
        data->sourceId, data->rssi);

    // This is necessary to keep all forced events safe, as we may be trying
    // to access uninitialized variables.
    checkInitialized();

    // Check that we're actually receiving this packet correctly,
    // and that this event is for the right packet being received.
    if (receivingFrame != NULL &&
        data->sourceId == receivingFrame->sourceId) {

      // TODO note that this is really wasteful! We're sending the data twice.
      // the first send was necessary because address verification (which happens
      // as soon as the address is received) needs to be able to check the data
      // up through the address. However, we're sending everything over once again
      // because we're allowing for changes to happen as soon as the file is done.
      free(receivingFrame->frame);
      receivingFrame->frame = data->frame;
      // Pass on ownership (as understood by cleanupFrameReceivedEvent).
      data->frame = NULL;

      assert( getState() != STATE_VREG_OFF &&
          "receivingFrame != NULL but we're powered off!" );

      // Check that the destination address was correct and
      // that the length was not corrupted by interference.
      // TODO note that here, we're explicitly allowing all ACKs to get in!
      // is this a good idea?
      if (getState() == STATE_RX_FRAME &&
          (receivingFrame->isAck ||
           (!receivingFrame->wasLengthCorrupt &&
            receivingFrame->isDestAddrCorrect))) {
        //assert(!isReceivingInterference);

        msg = (TOS_MsgPtr) receivingFrame->frame;
        frame = receivingFrame->frame;
        // + 1 for the length field.
        length = msg->length + 1;

        // Make sure that the RSSI value for this packet is the same.
        assert(receivingFrame->rssi == data->rssi);

        if (!isReceivingInterference) {
          if (getRegisterBit(CC2420_MDMCTRL0, CC2420_MDMCTRL0_AUTOCRC)) {
            // In receive mode, auto-ack automatically verifies the two CRC
            // bytes, and then replaces those two bytes with the RSSI, the CRC
            // correctness bit, and the LQI.

            // The packet should always have two CRC bytes, according to the
            // 802.15.4 standard. Verify the CRC.
            // TODO actually check the CRC
            crcOk = (frame[length - 2] == 0 && frame[length - 1] == 0);

            // Now replace the two CRC bytes with the RSSI and LQI values.
            (int8_t) frame[length - 2] = getEncodedRssi(receivingFrame->rssi);
            frame[length - 1] = (crcOk << 7) |
              getEncodedLqi(receivingFrame->lqi);
          }

          // Write to the RX FIFO (if we're not the ones sending this packet).
          if (receivingFrame->sourceId != NODE_NUM) {
            assert(!getStatusReg(CC2420_TX_ACTIVE));
            // If there is not enough space in the RX queue.
            if (rxQueueEnd + length > QUEUE_SIZE) {
              // TODO this is so not right, because it is followed immediately
              // by the normal procedure. also, was FIFOP supposed to be
              // already set earlier by something? (According to the datasheet,
              // overflow is setting FIFO to low *while* FIFOP is high.)
              fail("not implemented!");
              setFifop();
              clearFifo();
              isOverflow = TRUE;
            } else {
              // Copy the data into the RX queue.
              memcpy(rxQueue + rxQueueEnd, frame, length);
              rxQueueEnd += length;

              // If it's not an ACK, make this an event.
              if (!receivingFrame->isAck) {
                RadioMsgSentEvent radioEvent;

                // Send the radio event to TinyViz.
                // TODO pad the remaining bytes of radioEvent.message?
                assert(msg->length + 1 < sizeof radioEvent.message);
                memcpy(&radioEvent.message, msg, msg->length + 1);
                // TOSSIM-related tools expect CRC in {0,1}, not an actual CRC value.
                radioEvent.message.crc = 1;

//              if (!receivingFrame->isAck) {
//                printf("  [length=%#x]\n"
//                    "  [fcfhi=%#x]\n"
//                    "  [fcflo=%#x]\n"
//                    "  [dsn=%#x]\n"
//                    "  [destpan=%#x]\n"
//                    "  [addr=%#x]\n"
//                    "  [type=%#x]\n"
//                    "  [group=%#x]\n",
//                    msg->length,
//                    msg->fcfhi,
//                    msg->fcflo,
//                    msg->dsn,
//                    msg->destpan,
//                    msg->addr,
//                    msg->type,
//                    msg->group);
//              }

                sendTossimEvent(data->sourceId, AM_RADIOMSGSENTEVENT, tos_state.tos_time, &radioEvent);
//              {
//                char str[STR_LENGTH];
//                char* pstr = str;
//                uint8_t i;
//                uint8_t* arr = (uint8_t*) &radioEvent.message;
//                for (i = 0; i < arr[0] + 1; i++) {
//                  assert(pstr - str < STR_LENGTH);
//                  pstr += snprintf(pstr, STR_LENGTH, "%02x ", arr[i]);
//                }
//                pp("sendTossimEvent(length=%d [ %s ])", arr[0]+1, str);
//              }

              }
            }
          }
        }

        // The signal has ended.
        removeChannelSource(receivingFrame->rssi, data->sourceId);

        // If we heard this packet fine (no interference) and we're not
        // the ones sending this packet.
        if (!isReceivingInterference &&
            receivingFrame->sourceId != NODE_NUM) {
          assert(!getStatusReg(CC2420_TX_ACTIVE));
          // FIFOP is set once we've finished receiving a packet and/or we've exceeded
          // the RXFIFO threshold.
          // TODO is fifop supposed to be set even when we're still hearing an
          // interfering packet? i'm guessing that it works because we're comparing
          // the length with the length given in the length field. BUT what if the length
          // field was also interfered?
          // TODO should I add another event for packets that make the rxfifo length
          // exceed the threshold? the event would set FIFOP.
          pppp(dbgTransmit, "transmitted from %d to %d%s", receivingFrame->sourceId, NODE_NUM, receivingFrame->isAck ? " ack" : "");
          if (isFifopInverted()) {
            clearFifop();
          } else {
            setFifop();
          }

          // Start sending an ack if auto-ack is enabled and an ack was requested.
          if (getRegisterBit(CC2420_MDMCTRL0, CC2420_MDMCTRL0_AUTOACK) &&
              (msg->fcfhi & CC2420_DEF_FCF_HI_ACK) != 0 && crcOk) {
            // Save the DSN of this packet (so that when we create the ACK later,
            // we'll know what DSN to acknowledge).
            ackDsn = msg->dsn;

            setState(STATE_TX_ACK_CALIBRATE);
            createTxCalibratedEvent();
          } else {
            // TODO what happens in RX_WAIT, exactly?
            setState(STATE_RX_WAIT);
            setState(STATE_RX_SFD_SEARCH);
          }
        } else {
          printd(dbgFail, "transmit from %hu to %hu failed (due to interference)",
              data->sourceId, NODE_NUM);
        }
      } else {
        if (getState() != STATE_RX_FRAME && data->sourceId != NODE_NUM) {
          printd(dbgFail, "transmit from %hu to %hu failed (due to state being %s instead of RX_FRAME)",
              data->sourceId, NODE_NUM, getStateStr(getState()));
        } else if (receivingFrame->wasLengthCorrupt) {
          printd(dbgFail, "transmit from %hu to %hu failed (due to corrupted length field)",
              data->sourceId, NODE_NUM);
        } else if (!receivingFrame->isDestAddrCorrect && data->sourceId != NODE_NUM) {
          printd(dbgFail, "transmit from %hu to %hu failed (due to incorrect address)",
              data->sourceId, NODE_NUM);
        } else {
          assert( data->sourceId == NODE_NUM );
        }

        // TODO there is duplicate code here (same from above case)!
        // The signal has ended.
        removeChannelSource(receivingFrame->rssi, data->sourceId);

        // If we're not in a sending state.
        if (receivingFrame->sourceId != NODE_NUM &&
            getState() == STATE_RX_FRAME) {
          // TODO what happens in RX_WAIT, exactly?
          setState(STATE_RX_WAIT);
          setState(STATE_RX_SFD_SEARCH);
        }
      }

      // Free this because the event is for receivingFrame.
      free(receivingFrame->frame);
      free(receivingFrame);
      receivingFrame = NULL;
//    } else if (receivingFrame != NULL) {
//      // TODO there is duplicate code here (same from above case)!
//      // The signal has ended.
//      removeChannelSource(receivingFrame->rssi);
//      free(receivingFrame->frame);
//      free(receivingFrame);
//      receivingFrame = NULL;
    } else {
      removeChannelSource(data->rssi, data->sourceId);
    }

    event_cleanup(ev);
  }

  // Cleans up frame-received events.
  void cleanupFrameReceivedEvent(event_t* ev) {
    FrameData* data = (FrameData*) ev->data;
    p("enter cleanupFrameReceivedEvent()");
    if (data->frame != NULL) {
      free(data->frame);
    }
    free(data);
    free(ev);
  }

  // Creates frame-received events.
  // Preconditions: called at the frame has been completely received.
  void createFrameReceivedEvent(uint16_t moteId) {
    event_t* ev;

    p("enter createFrameReceivedEvent()");

    ev = (event_t*) alloc(sizeof(event_t));
    ev->mote = moteId;
    ev->force = TRUE;
    // Freed in handleFrameReceivedEvent()
    ev->data = createFrame(moteId);
    //// Freed in cleanupFrameReceivedEvent()
    //ev->data = createSourceData(moteId);
    ev->time = tos_state.tos_time;
    ev->handle = handleFrameReceivedEvent;
    ev->cleanup = cleanupFrameReceivedEvent;
    ev->pause = 0;

    TOS_queue_insert_event(ev);
  }

  //
  // Address-received events.
  //

  // Handles address-received events.
  void handleAddressReceivedEvent(event_t* ev, struct TOS_state* state) {
    SourceData* data;

    data = (SourceData*) ev->data;
    pp("enter handleAddressReceivedEvent(from=%hd, rssi=%f)",
        data->sourceId, data->rssi);

    // This is necessary to keep all forced events safe.
    checkInitialized();

    // Check whether this is for the right packet, and whether there has
    // been any interference.
    if (receivingFrame != NULL &&
        data->sourceId == receivingFrame->sourceId &&
        !receivingFrame->wasLengthCorrupt &&
        !isReceivingInterference) {
      TOS_MsgPtr msg = (TOS_MsgPtr) receivingFrame->frame;

      assert( getState() != STATE_VREG_OFF &&
          "receivingFrame != NULL but we're powered off!" );

      // Perform address recognition.
      receivingFrame->isDestAddrCorrect = isAddressCorrect(msg);

      // Clear the pins if this address is incorrect and we're not the ones
      // sending this packet.
      if (!receivingFrame->isDestAddrCorrect &&
          receivingFrame->sourceId != NODE_NUM) {
        assert(!getStatusReg(CC2420_TX_ACTIVE));
        clearSfd();
        clearFifo();
      }
    }

    event_cleanup(ev);
  }

  // Cleans up address-received events.
  void cleanupAddressReceivedEvent(event_t* ev) {
    p("enter cleanupAddressReceivedEvent()");
    free(ev->data);
    free(ev);
  }

  // Creates address-received events.
  // Preconditions: this must be called at the timepoint when we're just starting
  // to send the frame, so that the time until the address field is received
  // (the address transmit latency) makes sense.
  void createAddressReceivedEvent(uint16_t moteId) {
    event_t* ev;

    p("enter createAddressReceivedEvent()");

    ev = (event_t*) alloc(sizeof(event_t));
    ev->mote = moteId;
    ev->force = TRUE;
    // Freed in cleanupAddressReceivedEvent()
    ev->data = createSourceData(moteId);
    ev->time = tos_state.tos_time + secondsToTicks(ADDRESS_TRANSMIT_LATENCY);
    ev->handle = handleAddressReceivedEvent;
    ev->cleanup = cleanupAddressReceivedEvent;
    ev->pause = 0;

    TOS_queue_insert_event(ev);
  }

  //
  // Frame-receiving event.
  //

  // Handles frame-receiving events.
  // Preconditions: if there was interference before this time point,
  // then isReceivingInterference is set.
  // Postconditions: receivingFrame is set to the packet currently being
  // received.
  void handleFrameReceivingEvent(event_t* ev, struct TOS_state* state) {
    // Save all the data about this packet.
    FrameData* data = (FrameData*) ev->data;

    // This is necessary to keep all forced events safe.
    checkInitialized();

    pp("enter handleFrameReceivingEvent(from=%hd, rssi=%f): receivingFrame %s null",
        data->sourceId, data->rssi, receivingFrame == NULL ? "==" : "!=");

    if (getState() != STATE_VREG_OFF && receivingFrame == NULL) {
      // TODO note that this implementation means that
      // if we have mote A start sending while mote B is just about to finish,
      // then the preamble/SFD will be corrupt (interfered),
      // but not the frame. And this if statement is really just checking
      // to see if the current frame is corrupted (and neglecting the
      // preamble/sfd)!
      receivingFrame = data;

      // If we have no interference and either we're listening
      // or we're the senders of the packet.
      if (!isReceivingInterference &&
          (getState() == STATE_RX_SFD_SEARCH || receivingFrame->sourceId == NODE_NUM)) {
        // We can hear the length correctly (we're assuming that the next byte
        // will be received without interference).
        receivingFrame->wasLengthCorrupt = FALSE;
        p("  setting wasLengthCorrupt = FALSE");

        // Set the pins and state if we're not the ones sending this packet.
        if (receivingFrame->sourceId != NODE_NUM) {
          assert(!getStatusReg(CC2420_TX_ACTIVE));
          // For transmission, the SFD is set in handleFrameSentEvent() and
          // handlePreambleSentEvent(), not here.
          setSfd();
          setFifo();
          setState(STATE_RX_FRAME);
        }
      } else {
        receivingFrame->wasLengthCorrupt = TRUE;
        p("  setting wasLengthCorrupt = TRUE");
      }
    } else {
      free(data->frame);
      free(data);
    }

    event_cleanup(ev);
  }

  // Cleans up frame-receiving events.
  // Don't clean up the event data, because it contains the frame that will be
  // received.
  void cleanupFrameReceivingEvent(event_t* ev) {
    p("enter cleanupFrameReceivingEvent()");
    free(ev);
  }

  // Creates frame-receiving events.
  void createFrameReceivingEvent(uint16_t moteId, FrameData* data) {
    event_t* ev;

    pp("enter createFrameReceivingEvent(%d)", moteId);

    ev = (event_t*) alloc(sizeof(event_t));
    ev->data = data;
    ev->force = TRUE;
    ev->mote = moteId;
    ev->time = tos_state.tos_time;
    ev->handle = handleFrameReceivingEvent;
    ev->cleanup = cleanupFrameReceivingEvent;
    ev->pause = 0;

    TOS_queue_insert_event(ev);
  }

  //
  // Preamble-receiving event.
  //

  // Handles preamble-receiving events.
  void handlePreambleReceivingEvent(event_t* ev, struct TOS_state* state) {
    SourceData* data;

    data = (SourceData*) ev->data;
    pp("enter handlePreambleReceivingEvent(from=%hd, rssi=%f)",
        data->sourceId, data->rssi);

    // This is necessary to keep all forced events safe.
    checkInitialized();

    // Adjust the CCA with an energy level.
    // TODO is there any other situation in which the channel data would be invalid?
    pppp(dbgReceive, "getting preamble (rssi = %f, from = %hu)",
        data->rssi, data->sourceId);
    addChannelSource(data->rssi, data->sourceId);

    event_cleanup(ev);
  }

  // Cleans up preamble-receiving events.
  void cleanupPreambleReceivingEvent(event_t* ev) {
    p("enter cleanupPreambleReceivingEvent()");
    free(ev->data);
    free(ev);
  }

  // Creates preamble-receiving events.
  void createPreambleReceivingEvent(uint16_t moteId) {
    event_t* ev;

    pp("enter createPreambleReceivingEvent(%d)", moteId);

    ev = (event_t*) alloc(sizeof(event_t));
    ev->mote = moteId;
    ev->force = TRUE;
    // Freed in cleanupPreambleReceivingEvent()
    ev->data = createSourceData(moteId);
    ev->time = tos_state.tos_time;
    ev->handle = handlePreambleReceivingEvent;
    ev->cleanup = cleanupPreambleReceivingEvent;
    ev->pause = 0;

    TOS_queue_insert_event(ev);
  }

  //
  // RX-calibrated events.
  //

  // Handles RX-calibrated events.
  void handleRxCalibratedEvent(event_t* ev, struct TOS_state* state) {
    StateChangeData* data;

    p("enter handleRxCalibratedEvent()");

    data = (StateChangeData*) ev->data;
    // Make sure that, e.g., we did not get turned off since this event was issued,
    // (that we did not get switched away from the state).
    if (data->stateSession == stateSession) {
      //if (getState() != STATE_VREG_OFF) {
        // Start listening for SFDs.
        setState(STATE_RX_SFD_SEARCH);
      //}
    }

    event_cleanup(ev);
  }

  // Cleans up RX-calibrated events.
  void cleanupRxCalibratedEvent(event_t* ev) {
    p("enter cleanupRxCalibratedEvent()");
    free(ev->data);
    free(ev);
  }

  // Creates RX-calibrated events.
  void createRxCalibratedEvent() {
    event_t* ev;

    p("enter createRxCalibratedEvent()");

    ev = (event_t*) alloc(sizeof(event_t));
    ev->mote = NODE_NUM;
    ev->data = createStateChangeData();
    ev->time = tos_state.tos_time + symbolsToTicks(RX_CALIBRATION_LATENCY);
    ev->handle = handleRxCalibratedEvent;
    ev->cleanup = cleanupRxCalibratedEvent;
    ev->pause = 0;

    TOS_queue_insert_event(ev);
  }

  //
  // Frame-sent events.
  //

  // Handles frame-sent events.
  void handleFrameSentEvent(event_t* ev, struct TOS_state* state) {
    uint16_t moteId;
    uint16_t expectedLength;

    p("enter handleFrameSentEvent()");

    // Let neighbors know that they have finished receiving the packet.
    for (moteId = 0; moteId < tos_state.num_nodes; moteId++) {
      if (getNeighbor(moteId)->isNeighbor) {
        DBGSTATE(moteId, FALSE, getNeighbor(moteId)->rssi);
        createFrameReceivedEvent(moteId);
      }
    }

    // Transmission completed, so go back to listening mode.
    setState(STATE_RX_CALIBRATE);
    createRxCalibratedEvent();

    // Was there an underflow?
    // TODO right now i'm determining if there's an underflow beforehand.
    // but it is possible to push more bytes into TXFIFO while transmitting,
    // and thus avoiding underflow.
    expectedLength = txQueue[0];
    if (getRegisterBit(CC2420_MDMCTRL0, CC2420_MDMCTRL0_AUTOCRC)) {
      expectedLength -= 2;
    }
    if (txQueueEnd <= expectedLength) {
      setStatusReg(CC2420_TX_UNDERFLOW, FALSE);
    }

    // Set pins to signal the end of the transmission.
    setStatusReg(CC2420_TX_ACTIVE, FALSE);
    clearSfd();

    free(transmittingFrame->frame);
    free(transmittingFrame);
    transmittingFrame = NULL;
    event_cleanup(ev);
  }

  // Cleans up frame-sent events.
  void cleanupFrameSentEvent(event_t* ev) {
    p("enter cleanupFrameSentEvent()");
    free(ev);
  }

  // Creates frame-sent events.
  void createFrameSentEvent() {
    uint64_t latency;
    event_t* ev;

    p("enter createFrameSentEvent()");

    // + 1 for the length field.
    latency = secondsToTicks(calculateTransmitTime(1 + transmittingFrame->length));

    ev = (event_t*) alloc(sizeof(event_t));
    ev->mote = NODE_NUM;
    ev->data = NULL;
    ev->time = tos_state.tos_time + latency;
    ev->handle = handleFrameSentEvent;
    ev->cleanup = cleanupFrameSentEvent;
    ev->pause = 0;

    TOS_queue_insert_event(ev);
  }

  //
  // Preamble-sent events. This event actually spans both the preamble and the
  // SFD.
  //

  // Handles preamble-sent events.
  void handlePreambleSentEvent(event_t* ev, struct TOS_state* state) {
    uint16_t moteId;

    p("enter handlePreambleSentEvent()");

    // Transition appropriately.
    if (getState() == STATE_TX_PREAMBLE) {
      setState(STATE_TX_FRAME);
    } else {
      assert(getState() == STATE_TX_ACK_PREAMBLE);
      setState(STATE_TX_ACK);
    }

    // Prepare a local copy of the full frame.
    transmittingFrame = createFrame(NODE_NUM);

    // Start transmitting the frame, making all neighbors hear it.
    for (moteId = 0; moteId < tos_state.num_nodes; moteId++) {
      if (getNeighbor(moteId)->isNeighbor) {
        FrameData* frame = createFrame(moteId);
        createFrameReceivingEvent(moteId, frame);
        // TODO this assumes that the buffer doesn't change while
        // transmitting. however, this is apparently not always the case!
        // this should be safe for the CC2420Radio lib, though.
        // UPDATE this is not entirely true. we're now sending the data twice,
        // and the second time (which happens at the end) should contain updated
        // data. another solution (tailored in particular for SP) would be to
        // move the SFD signal (below) up before this piece of code (and also get
        // rid of the signal therein) so as to let SP modify the packet
        // appropriately.

        // Make sure that we actually transmit up through the address field
        // (up till TOS_Msg.type).
        if (frame->length >= offsetof(struct TOS_Msg, type)) {
          createAddressReceivedEvent(moteId);
        }
      }
    }
    createFrameSentEvent();

    // Set the SFD pin to signal that transmission of the actual packet has started.
    setSfd();

    event_cleanup(ev);
  }

  // Cleans up preamble-sent events.
  void cleanupPreambleSentEvent(event_t* ev) {
    p("enter cleanupPreambleSentEvent()");
    free(ev);
  }

  // Creates preamble-sent events.
  void createPreambleSentEvent() {
    event_t* ev;

    p("enter createPreambleSentEvent()");

    ev = (event_t*) alloc(sizeof(event_t));
    ev->mote = NODE_NUM;
    ev->data = NULL;
    ev->time = tos_state.tos_time + secondsToTicks(PREAMBLE_SFD_TRANSMIT_LATENCY);
    ev->handle = handlePreambleSentEvent;
    ev->cleanup = cleanupPreambleSentEvent;
    ev->pause = 0;

    TOS_queue_insert_event(ev);
  }

  //
  // TX-calibrated events.
  //

  // Handles TX-calibrated events.
  // TODO note that we're not handling interrupted transmits!
  // For instance, what if we turned off the mote, or otherwise switched away
  // from this state? (Maybe we can use the StateChangeData here, but it's not
  // currently being used.)
  void handleTxCalibratedEvent(event_t* ev, struct TOS_state* state) {
    uint16_t moteId;

    p("enter handleTxCalibratedEvent()");

    // Determine which other motes can hear the packet we're about to send.
    updateNeighbors();

    // Transition to the appropriate next state. These series of functions are
    // shared for both data packets and ack packets.
    if (getState() == STATE_TX_CALIBRATE) {
      setState(STATE_TX_PREAMBLE);
    } else {
      assert(getState() == STATE_TX_ACK_CALIBRATE);
      setState(STATE_TX_ACK_PREAMBLE);
    }

    // Start transmitting the preamble.
    for (moteId = 0; moteId < tos_state.num_nodes; moteId++) {
      if (getNeighbor(moteId)->isNeighbor) {
        DBGSTATE(moteId, TRUE, getNeighbor(moteId)->rssi);
        createPreambleReceivingEvent(moteId);
      }
    }
    createPreambleSentEvent();

    event_cleanup(ev);
  }

  // Cleans up TX-calibrated events.
  void cleanupTxCalibratedEvent(event_t* ev) {
    p("enter cleanupTxCalibratedEvent()");
    free(ev->data);
    free(ev);
  }

  // Creates TX-calibrated events.
  void createTxCalibratedEvent() {
    event_t* ev;
    bool txTurnaroundBit;
    uint8_t txTurnaroundSymbols;

    p("enter createTxCalibratedEvent()");

    // Get the turnaround time (in symbols).
    if (getState() == STATE_TX_CALIBRATE) {
      txTurnaroundBit = getRegisterBit(CC2420_TXCTRL, CC2420_TXCTRL_TURNARND);
      txTurnaroundSymbols = txTurnaroundBit == 0 ? 8 : 12;
    } else {
      assert(getState() == STATE_TX_ACK_CALIBRATE);
      txTurnaroundSymbols = TX_ACK_CALIBRATE_LATENCY;
    }

    // Create the event.
    ev = (event_t*) alloc(sizeof(event_t));
    ev->mote = NODE_NUM;
    ev->data = createStateChangeData();
    ev->time = tos_state.tos_time + symbolsToTicks(txTurnaroundSymbols);
    ev->handle = handleTxCalibratedEvent;
    ev->cleanup = cleanupTxCalibratedEvent;
    ev->pause = 0;

    TOS_queue_insert_event(ev);
  }

  //
  // Oscillator-on events.
  //

  // Handles oscillator-on events.
  void handleOscillatorOnEvent(event_t* ev, struct TOS_state* state) {
    uint8_t ccaMux;
    StateChangeData* data;

    p("enter handleOscillatorOn()");

    data = (StateChangeData*) ev->data;
    assert(data->stateSession == stateSession);

    setState(STATE_XOSC_ON);

    ccaMux = getRegisterBits(CC2420_IOCFG1,
        CC2420_IOCFG1_CCAMUX_START, CC2420_IOCFG1_CCAMUX_END);
    if (ccaMux == 24) {
      setCca();
    }

    setStatusReg(CC2420_XOSC16M_STABLE, 1);

    // TODO this is part of the temporary workaround
    if (ev != NULL) {
      event_cleanup(ev);
    }
  }

  // Cleans up oscillator-on events.
  void cleanupOscillatorOnEvent(event_t* ev) {
    free(ev->data);
    free(ev);
  }

  // Creates oscillator-on events.
  void createOscillatorOnEvent() {
    event_t* ev;

    p("enter createOscillatorOnEvent()");

    ev = (event_t*) alloc(sizeof(event_t));
    ev->mote = NODE_NUM;
    ev->data = createStateChangeData();
    ev->time = tos_state.tos_time + secondsToTicks(OSCILLATOR_ON_LATENCY);
    ev->handle = handleOscillatorOnEvent;
    ev->cleanup = cleanupOscillatorOnEvent;
    ev->pause = 0;

    TOS_queue_insert_event(ev);
  }

  //
  // VREG-on events.
  //

  // Handles VREG-on events.
  void handleVregOnEvent(event_t* ev, struct TOS_state* state) {
    StateChangeData* data;

    p("enter handleVregOnEvent()");

    data = (StateChangeData*) ev->data;
    assert(data->stateSession == stateSession);

    setState(STATE_IDLE);
    event_cleanup(ev);
  }

  // Cleans up VREG-on events.
  void cleanupVregOnEvent(event_t* ev) {
    p("enter cleanupVregOnEvent()");
    free(ev->data);
    free(ev);
  }

  // Creates VREG-on events.
  void createVregOnEvent() {
    event_t* ev;

    p("enter createVregOnEvent()");

    ev = (event_t*) alloc(sizeof(event_t));
    ev->mote = NODE_NUM;
    ev->data = createStateChangeData();
    ev->time = tos_state.tos_time + secondsToTicks(VREG_ON_LATENCY);
    ev->handle = handleVregOnEvent;
    ev->cleanup = cleanupVregOnEvent;
    ev->pause = 0;

    TOS_queue_insert_event(ev);
  }

  //
  // Sending packets.
  //

  // Create a SourceData struct.
  // These are always allocated as event data, so they are freed in the
  // cleanup functions.
  // Precondition: we have already run updateNeighbors for the current
  // transmission.
  SourceData* createSourceData(uint16_t moteId) {
    SourceData* data = (SourceData*) alloc(sizeof(SourceData));
    data->sourceId = NODE_NUM;
    data->rssi = getNeighbor(moteId)->rssi;
    return data;
  }

  // Creates a frame to be transmitted, based on what we have in TXFIFO.
  FrameData* createFrame(uint16_t moteId) {
    uint8_t length;
    // Freed by the transmitter and the receiver after the packet has been
    // completely sent, in handleFrameSentEvent() and handleFrameReceivedEvent().
    FrameData* data = (FrameData*) alloc(sizeof(FrameData));

    if (getState() == STATE_TX_ACK) {
      TOS_MsgPtr msg = NULL;

      // + 1 to include the length field itself.
      length = ACK_LENGTH + 1;
      // Freed by the transmitter and the receiver after the packet has been
      // completely sent, in handleFrameSentEvent() and handleFrameReceivedEvent().
      msg = (TOS_MsgPtr) alloc(length * sizeof(uint8_t));
      data->frame = (uint8_t*) msg;

      msg->length = ACK_LENGTH;
      msg->fcfhi = CC2420_DEF_FCF_TYPE_ACK;
      msg->fcflo = CC2420_DEF_FCF_LO;
      msg->dsn = ackDsn;

      // TODO should I be writing this???
      // Valgrind says I should initialize this (so that getDestPan in
      // isAddressCorrect will work), but I don't remember seeing it
      // mentioned by the packet sniffing software.
      // BUT it also complains about addr, which we clearly don't have space for
      // so what should we do about that?
      // Also, since the length is 5, it seems that we should be including
      // the destpan.
      msg->destpan = 0xFFFF;

      data->isAck = TRUE;
    } else {
      uint8_t* frame = NULL;

      assert(getState() == STATE_TX_FRAME);

      // The length field includes the header, payload, and footer,
      // but not the length field itself.
      length = txQueue[0] + 1; // + 1 to include the length field

      // Allocate space for the frame.
      // Freed by the transmitter and the receiver after the packet has been
      // completely sent, in handleFrameSentEvent() and handleFrameReceivedEvent().
      frame = (uint8_t*) alloc(length);
      data->frame = frame;

      // If auto-ack isn't set, the packet should already include the CRC.
      // Otherwise, the radio is responsible for generating and appending it.
      // TODO implement true CRC generation
      if (getRegisterBit(CC2420_MDMCTRL0, CC2420_MDMCTRL0_AUTOCRC)) {
        frame[length - 2] = 0;
        frame[length - 1] = 0;
      }

      assert(length <= sizeof(TOS_Msg));

      // The amount of data actually in the TXFIFO does not include the message
      // footer, since the radio is supposed to generate it.
      memcpy(frame, txQueue, length - MSG_FOOTER_SIZE);

      data->isAck = FALSE;
    }

    data->length = length;
    data->sourceId = NODE_NUM;
    data->rssi = getNeighbor(moteId)->rssi;
    data->lqi = getNeighbor(moteId)->lqi;
    return data;
  }

  // Start transmission by setting the appropriate pins and starting
  // calibration.
  void startTransmission() {
    // Transition to calibration state.
    setStatusReg(CC2420_TX_ACTIVE, TRUE);
    setState(STATE_TX_CALIBRATE);

    // Start the calibration (8-12 symbols).
    createTxCalibratedEvent();

    // Start TX in-line encryption if SPI_SEC_MODE != 0.
    // TODO implement
  }

  //
  // HPLCC2420 registers.
  //

  // Send a command strobe, returning the radio's status byte.
  // TODO complete implementation.
  async command uint8_t HPLCC2420.cmd(uint8_t addr) {
    char* cmdstr;
    switch (addr) {
      case CC2420_SNOP:
        cmdstr = "CC2420_SNOP";
        break;
      case CC2420_SXOSCON:
        cmdstr = "CC2420_SXOSCON";
        break;
      case CC2420_STXCAL:
        cmdstr = "CC2420_STXCAL";
        break;
      case CC2420_SRXON:
        cmdstr = "CC2420_SRXON";
        break;
      case CC2420_STXON:
        cmdstr = "CC2420_STXON";
        break;
      case CC2420_STXONCCA:
        cmdstr = "CC2420_STXONCCA";
        break;
      case CC2420_SRFOFF:
        cmdstr = "CC2420_SRFOFF";
        break;
      case CC2420_SXOSCOFF:
        cmdstr = "CC2420_SXOSCOFF";
        break;
      case CC2420_SFLUSHRX:
        cmdstr = "CC2420_SFLUSHRX";
        break;
      case CC2420_SFLUSHTX:
        cmdstr = "CC2420_SFLUSHTX";
        break;
      case CC2420_SACK:
        cmdstr = "CC2420_SACK";
        break;
      case CC2420_SACKPEND:
        cmdstr = "CC2420_SACKPEND";
        break;
      case CC2420_SRXDEC:
        cmdstr = "CC2420_SRXDEC";
        break;
      case CC2420_STXENC:
        cmdstr = "CC2420_STXENC";
        break;
      case CC2420_SAES:
        cmdstr = "CC2420_SAES";
        break;
      default:
        fail("not a valid register");
        break;
    }
    pp("enter HPLCC2420.cmd(%s): status = %x", cmdstr, statusReg);

    // Don't accept commands if the oscillator isn't on.
    if ((getState() != STATE_VREG_OFF &&
          getState() != STATE_VREG_POWERUP &&
          getState() != STATE_IDLE &&
          getState() != STATE_XOSC_POWERUP) ||
        addr == CC2420_SXOSCON) {
      switch (addr) {
        case CC2420_SNOP:
          // No op (other than reading out status-bits).
          break;
        case CC2420_SXOSCON:
          // Transition into the oscillator powerup state.
          setState(STATE_XOSC_POWERUP);

          // Start turning on the oscillator.
//          // TODO note that TOSH_wait doesn't actually do anything!
//          // so this timeout mechanism *will not* work
          createOscillatorOnEvent();
//          // TODO this is a temporary workaround
//          handleOscillatorOnEvent(NULL, NULL);

          break;
        case CC2420_STXCAL:
          // TODO implement
          break;
        case CC2420_SRXON:
          // Enable RX.
          // Start the calibration.
          // TODO so apparently, we can accept multiple (quick) calls to SRXON, right?
          // (see TuneManual, followed by RxMode, in lib)
          setState(STATE_RX_CALIBRATE);
          createRxCalibratedEvent();
          break;
        case CC2420_STXON:
          // Enable TX.
          // TODO this is incomplete! I have never tested this.
          startTransmission();
          break;
        case CC2420_STXONCCA:
          // Enable TX if channel is clear.
          if (TOSH_READ_RADIO_CCA_PIN()) {
            startTransmission();
          }
          break;
        case CC2420_SRFOFF:
          // TODO implement
          break;
        case CC2420_SXOSCOFF:
          // Turn off the crystal oscillator and RF.
          setStatusReg(CC2420_XOSC16M_STABLE, 0);
          // Modify xosc16m_pd/bias_pd/rf?
          // TODO implement
          break;
        case CC2420_SFLUSHRX:
          // Flush the RX FIFO buffer and reset the demodulator.
          // Note: you must read at least one byte from the RXFIFO before issuing
          // this command.
          clearFifo();
          // Reset the demodulator.
          // TODO implement
          break;
        case CC2420_SFLUSHTX:
          // Clear the underflow status bit.
          setStatusReg(CC2420_TX_UNDERFLOW, 0);
          // Flush the TX FIFO buffer.
          txQueueEnd = 0;
          break;
        case CC2420_SACK:
          break;
        case CC2420_SACKPEND:
          break;
        case CC2420_SRXDEC:
          break;
        case CC2420_STXENC:
          break;
        case CC2420_SAES:
          break;
        default:
          fail("not a valid register");
          break;
      }
    } else {
      pp("  still in state %d", getState());
    }

    pp("exit HPLCC2420.cmd(): status = %#x", statusReg);
    return statusReg;
  }

  // Transmits 16-bit data, returning the radio's status byte.
  // TODO complete implementation
  async command uint8_t HPLCC2420.write(uint8_t addr, uint16_t data) {
    pp("enter HPLCC2420.write(addr = %d, data = %d or %#x)", addr, data, data);
    setRegister(addr, data);
    return statusReg;
  }

  // Reads 16-bit data.
  async command uint16_t HPLCC2420.read(uint8_t addr) {
    pp("enter HPLCC2420.read(addr = %d)", addr);
    return getRegister(addr);
  }

  //
  // HPLCC2420M RAM.
  //

  // Signals that a RAM read operation has finished.
  task void signalRAMRd() {
    signal HPLCC2420RAM.readDone(rxramaddr, rxramlen, rxrambuf);
  }

  // Reads some data from the RAM.
  async command result_t HPLCC2420RAM.read(uint16_t addr, uint8_t length, uint8_t* buffer) {
    p("enter HPLCC2420RAM.read()");
    assert(addr + length <= RAM_SIZE);

    // Write the data into the given buffer.
    memcpy(buffer, ram + addr, length);

    // Prepare the states to be returned.
    rxramaddr = addr;
    rxramlen = length;
    rxrambuf = buffer;

    return post signalRAMRd();
  }

  // Signals that a RAM write operation has finished.
  task void signalRAMWr() {
    signal HPLCC2420RAM.writeDone(ramaddr, ramlen, rambuf);
  }

  // Writes some data to the RAM.
  async command result_t HPLCC2420RAM.write(uint16_t addr, uint8_t length, uint8_t* buffer) {
    pp("enter HPLCC2420RAM.write(addr = %d, length = %d)", addr, length);
    assert(addr + length <= RAM_SIZE);

    // Write the data to the RAM address.
    memcpy(ram + addr, buffer, length);

    // Prepare the states to be returned.
    ramaddr = addr;
    ramlen = length;
    rambuf = buffer;

    return post signalRAMWr();
  }

  //
  // HPLCC2420M FIFO queues.
  //

  // Signals that we have finished a read operation on the RXFIFO.
  task void signalRXFIFO() {
    signal HPLCC2420FIFO.RXFIFODone(rxlen, rxbuf);
  }

  // Read from the RX FIFO queue.  Will read bytes from the queue
  // until the length is reached (determined by the first byte read).
  // RXFIFODone() is signalled when all bytes have been read or the
  // end of the packet has been reached.
  //
  // @param length number of bytes requested from the FIFO
  // @param data buffer bytes should be placed into
  //
  // @return SUCCESS if the bus is free to read from the FIFO
  async command result_t HPLCC2420FIFO.readRXFIFO(uint8_t length, uint8_t *data) {
    TOS_MsgPtr rxMsg = (TOS_MsgPtr) rxQueue;
    uint8_t msgLen;

    p("enter HPLCC2420FIFO.read()");

    // Include the length field.
    msgLen = rxMsg->length + 1;

    // Check for sanity.
    assert(rxQueueEnd > 0);
    assert(msgLen <= length); // TODO what to do if not enough space in buffer?

    // Copy data from queue into provided buffer.
    memcpy(data, rxQueue, msgLen);
    // Shift the data over.
    rxQueueEnd -= msgLen;
    memmove(rxQueue, rxQueue + msgLen, rxQueueEnd);

    // Clear the FIFOP pin once at least one byte has been read.
    // TODO it was not clear from the datasheet whether this is the only condition for
    // the FIFOP pin to drop.
    if (length > 0) {
      if (isFifopInverted()) {
        setFifop();
      } else {
        clearFifop();
      }
    }

    // Save this as state so that it can be returned via the signal.
    rxbuf = data;
    rxlen = msgLen;

    // Debugging output.
    {
      char str[STR_LENGTH];
      char* pstr = str;
      uint8_t i;
      for (i = 0; i < rxlen; i++) {
        assert(pstr - str < STR_LENGTH);
        pstr += snprintf(pstr, STR_LENGTH, "%02x ", data[i]);
      }
      pp("msg.length=%d, length=%d, bytes=[ %s]", rxlen, length, str);
    }

    return post signalRXFIFO();
  }

  // Signals that we have finished a write operation on the RXFIFO.
  task void signalTXFIFO() {
    signal HPLCC2420FIFO.TXFIFODone(txlen, txbuf);
  }

  // Writes a series of bytes to the transmit FIFO.
  //
  // @param length length of data to be written
  // This includes the message header - everything before the payload, including
  // the length field - and the payload.
  // This is the actual length of the data parameter, since data does not include
  // the message footer (which the radio is responsible for generating).
  // This is in contrast with the length field's value, which is the size of the
  // entire packet - header, payload, and footer - EXCEPT for the length field.
  // @param data the first byte of data
  //
  // @return SUCCESS if the bus is free to write to the FIFO
  async command result_t HPLCC2420FIFO.writeTXFIFO(uint8_t length, uint8_t *data) {
    p("enter HPLCC2420FIFO.write()");
    // Check that the length is correct and that the message fits
    // The first byte should always be the length field.
    assert(data[0] - MSG_FOOTER_SIZE + 1 == length);
    if (length >= QUEUE_SIZE) {
      fail("overflowed TXFIFO");
    }

    // copy the data into the TXFIFO
    memcpy(txQueue + txQueueEnd, data, length);
    txQueueEnd += length;

    // signal that the TXFIFO is done
    return post signalTXFIFO();
  }

  // Default event handlers.

  default async event result_t HPLCC2420FIFO.RXFIFODone(uint8_t length, uint8_t *data) { return SUCCESS; }

  default async event result_t HPLCC2420FIFO.TXFIFODone(uint8_t length, uint8_t *data) { return SUCCESS; }

  default async event result_t HPLCC2420RAM.readDone(uint16_t addr, uint8_t length, uint8_t *data) { return SUCCESS; }

  default async event result_t HPLCC2420RAM.writeDone(uint16_t addr, uint8_t length, uint8_t *data) { return SUCCESS; }

  //
  // FIFOP Interrupt handlers and dispatch.
  // The FIFOP pin is set when we have started receiving data.
  //

  // Signals that the FIFOP pin has been fired.
  task void signalFifopFired() {
    result_t result = signal FIFOP.fired();
    fifopEnabled = result == SUCCESS;
  }

  // Set the FIFOP pin.
  void setFifop() {
    if (TOSH_READ_CC_FIFOP_PIN() == 0) {
      TOSH_SET_CC_FIFOP_PIN();
      if (fifopEnabled && fifopLowToHigh) {
        p("FIFOP set high");
        post signalFifopFired();
      } else {
        p("FIFOP set high, not firing");
      }
    } else {
      p("FIFOP set high, already high");
    }
  }

  // Clear the FIFOP pin.
  void clearFifop() {
    if (TOSH_READ_CC_FIFOP_PIN() == 1) {
      TOSH_CLR_CC_FIFOP_PIN();
      if (fifopEnabled && !fifopLowToHigh) {
        p("FIFOP set low");
        post signalFifopFired();
      } else {
        p("FIFOP set low, not firing");
      }
    } else {
      p("FIFOP set low, already low");
    }
  }

  // Determines the polarity of the FIFOP pin.
  bool isFifopInverted() {
    return getRegisterBit(CC2420_IOCFG0, CC2420_IOCFG0_FIFOPPOL);
  }

  // Enables an edge interrupt on the FIFOP pin.
  async command result_t FIFOP.startWait(bool low_to_high) {
    pp("enter FIFOP.startWait(%s)", low_to_high ? "low to high" : "high to low");
    fifopEnabled = TRUE;
    fifopLowToHigh = low_to_high;
    return SUCCESS;
  }

  // Disables FIFOP interrupts.
  async command result_t FIFOP.disable() {
    p("enter FIFOP.disable()");
    fifopEnabled = FALSE;
    return SUCCESS;
  }

  // Default event handler.
  default async event result_t FIFOP.fired() {
    return FAIL;
  }

  //
  // FIFO Interrupt handlers and dispatch.
  //

  // Signals that the FIFO pin has been fired
  task void signalFifoFired() {
    result_t result = signal FIFO.fired();
    fifoEnabled = result == SUCCESS;
  }

  // Set the FIFO pin.
  void setFifo() {
    if (TOSH_READ_CC_FIFO_PIN() == 0) {
      TOSH_SET_CC_FIFO_PIN();
      if (fifoEnabled && fifoLowToHigh) {
        p("FIFO set high");
        post signalFifoFired();
      } else {
        p("FIFO set high, not firing");
      }
    } else {
      p("FIFO set high, already high");
    }
  }

  // Clear the FIFO pin.
  void clearFifo() {
    if (TOSH_READ_CC_FIFO_PIN() == 1) {
      TOSH_CLR_CC_FIFO_PIN();
      if (fifoEnabled && !fifoLowToHigh) {
        p("FIFO set low");
        post signalFifoFired();
      } else {
        p("FIFO set low, not firing");
      }
    } else {
      p("FIFO set low, already low");
    }
  }

  // Enable an edge interrupt on the FIFO pin.
  async command result_t FIFO.startWait(bool low_to_high) {
    pp("enter FIFO.startWait(%s)", low_to_high ? "low to high" : "high to low");
    fifoEnabled = TRUE;
    fifoLowToHigh = low_to_high;
    return SUCCESS;
  }

  // Disables FIFO interrupts.
  async command result_t FIFO.disable() {
    p("enter FIFO.disable()");
    fifoEnabled = FALSE;
    return SUCCESS;
  }

  // Default event handler.
  default async event result_t FIFO.fired() {
    return FAIL;
  }

  //
  // CCA Interrupt handlers and dispatch.
  //

  // Signals that the FIFO pin has been fired.
  task void signalCcaFired() {
    result_t result = signal CCA.fired();
    ccaEnabled = result == SUCCESS;
  }

  // Set the CCA pin.
  void setCca() {
    if (TOSH_READ_RADIO_CCA_PIN() == 0) {
      TOSH_SET_RADIO_CCA_PIN();
      if (ccaEnabled && ccaLowToHigh) {
        p("CCA set high");
        post signalCcaFired();
      } else {
        p("CCA set high, not firing");
      }
    } else {
      p("CCA set high, already high");
    }
  }

  // Clear the CCA pin.
  void clearCca() {
    if (TOSH_READ_RADIO_CCA_PIN() == 1) {
      TOSH_CLR_RADIO_CCA_PIN();
      if (ccaEnabled && !ccaLowToHigh) {
        p("CCA set low");
        post signalCcaFired();
      } else {
        p("CCA set low, not firing");
      }
    } else {
      p("CCA set low, already low");
    }
  }

  // Disables CCA interrupts.
  async command result_t CCA.disable() {
    p("enter CCA.disable()");
    ccaEnabled = FALSE;
    return SUCCESS;
  }

//  // Handles CCA events.
//  void handleCcaEvent(event_t* ev, struct TOS_state* state) {
//    signal CCA.fired();
//    event_cleanup(ev);
//  }
//
//  // Cleans up CCA events.
//  void cleanupCcaEvent(event_t* ev) {
//    free(ev);
//  }
//
//  // Creates CCA events.
//  void createCcaEvent() {
//    event_t* ev = (event_t*) alloc(sizeof(event_t));
//    ev->mote = NODE_NUM;
//    ev->data = NULL;
//    ev->time = tos_state.tos_time; // TODO is this a reasonable delay?
//    ev->handle = handleCcaEvent;
//    ev->cleanup = cleanupCcaEvent; // free everything afterward
//    ev->pause = 0; // TODO what's this?
//    TOS_queue_insert_event(ev);
//  }

  // Enable an edge interrupt on the CCA pin.
  async command result_t CCA.startWait(bool low_to_high) {
    pp("enter CCA.startWait(%s)", low_to_high ? "low to high" : "high to low");
    ccaEnabled = TRUE;
    ccaLowToHigh = low_to_high;
    return SUCCESS;
  }

  // Default event handler.
  default async event result_t CCA.fired() {
    return FAIL;
  }

  //
  // SFD Interrupt handlers and dispatch
  // SFD = Start of Frame Delimiter
  // This detects the beginning of a packet.
  //

  // Signals that the SFD pin has been fired.
  task void signalSfdCaptured() {
    // TODO the time being passed is zero; this seems to be OK....
    result_t result = signal SFD.captured((uint16_t) getCurrentTimeInJiffies());
    sfdEnabled = result == SUCCESS;
  }

  // Sets the SFD pin.
  void setSfd() {
    if (TOSH_READ_CC_SFD_PIN() == 0) {
      TOSH_SET_CC_SFD_PIN();
      if (sfdEnabled && sfdLowToHigh) {
        p("SFD set high");
        post signalSfdCaptured();
      } else {
        p("SFD set high, not firing");
      }
    } else {
      p("SFD set high, already high");
    }
  }

  // Clears the SFD pin.
  void clearSfd() {
    if (TOSH_READ_CC_SFD_PIN() == 1) {
      TOSH_CLR_CC_SFD_PIN();
      if (sfdEnabled && !sfdLowToHigh) {
        p("SFD set low");
        post signalSfdCaptured();
      } else {
        p("SFD set low, not firing");
      }
    } else {
      p("SFD set low, already low");
    }
  }

  // Enables an edge interrupt on the SFD pin.
  async command result_t SFD.enableCapture(bool low_to_high) {
    pp("enter SFD.enableCapture(%s)", low_to_high ? "low to high" : "high to low");
    sfdEnabled = TRUE;
    sfdLowToHigh = low_to_high;
    return SUCCESS;
  }

  // Disables SFD interrupts.
  async command result_t SFD.disable() {
    p("enter SFD.disable()");
    sfdEnabled = FALSE;
    return SUCCESS;
  }

  default async event result_t SFD.captured(uint16_t val) { return FAIL; }

}

