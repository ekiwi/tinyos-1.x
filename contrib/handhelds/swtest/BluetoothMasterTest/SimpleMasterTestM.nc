/*
 * Copyright (c) 2010, Shimmer Research, Ltd.
 * All rights reserved
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:

 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials provided
 *       with the distribution.
 *     * Neither the name of Shimmer Research, Ltd. nor the names of its
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.

 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Author: Steve Ayer, Adrian Burns
 *         December, 2010
 */

 /***********************************************************************************

   This master mode is useful when the device only wants to initiate connections (not
   receive them). In this mode the device will NOT be discoverable or connectable.

   At compile time you need to provide a Bluetooth Slave Address to connect to so do 
   "make BT_SLAVE=0011f6057c35 shimmer2" for example....
   where 0011f6057c35 is your Bluetooth device address

   sends a string every 100ms

   Known Issues:
   When you program a Shimmer back to a slave mode firmware after using this master 
   mode firmware that it takes a second reset before the slave becomes discoverable.again.
   
 ***********************************************************************************/

includes RovingNetworks;
includes Message;

module SimpleMasterTestM {
  provides{
    interface StdControl;
  }
  uses {
    interface StdControl as BTStdControl;
    interface Bluetooth;    
    interface Leds;
    interface Timer as ConnectTimer;
    interface Timer as sendTimer;
    interface Timer as BTMasterTestTimer;
    interface LocalTime;
  }
} 

implementation {
  extern int sprintf(char *str, const char *format, ...) __attribute__ ((C));

#define CONNECT_PERIOD 30720 /* 30s off 30s on  over and over again */
#define CONN_TIMEOUT   20240 /* shut down radio if we cant connect to a slave */

  uint8_t sbuf0[96], send_period;
  bool enable_sending, bluetooth_connected;

  command result_t StdControl.init() {
    register uint8_t i;
    call Leds.init();

    send_period = 100;
    sprintf(sbuf0, "hello slave!\n");

    
    enable_sending = FALSE;
    bluetooth_connected = FALSE;

    return SUCCESS;
  }

  command result_t StdControl.start() {
    call BTStdControl.init();

    call BTMasterTestTimer.start(TIMER_ONE_SHOT, 5120);

    return SUCCESS;
  }

  /* if hw setup goes ok this will end up with in Bluetooth.commandModeEnded event */
  task void powerUpSystem() {
    call Bluetooth.disableRemoteConfig(TRUE);

    /* initiating a connection can be done in Slave or Master mode */
    //    call Bluetooth.setName("foo");
    call Bluetooth.setRadioMode(MASTER_MODE);
    call BTStdControl.start();
  }  
  
  task void powerDownSystem() {
    call BTStdControl.stop();
  }

  task void sendMasterDisconnect() {
    call Bluetooth.disconnect();
  }

  command result_t StdControl.stop() {
    call BTStdControl.stop();
    return SUCCESS;
  }

  task void sendString() {
    call Bluetooth.write(sbuf0, strlen(sbuf0));
  }

  task void startSending() {
    call sendTimer.start(TIMER_REPEAT, send_period);
  }

  task void stopSending() {
    call sendTimer.stop();
  }

  async event void Bluetooth.connectionMade(uint8_t status) { 
    call Leds.greenOn();
    call ConnectTimer.stop();
    atomic enable_sending = bluetooth_connected = TRUE;
    post startSending();
    call BTMasterTestTimer.start(TIMER_ONE_SHOT, CONNECT_PERIOD);    
  }

  task void connectToSlave() {
    call Bluetooth.connect(BT_SLAVE_ADDRESS);
  }
  
  async event void Bluetooth.commandModeEnded() { 
    call ConnectTimer.start(TIMER_ONE_SHOT, CONN_TIMEOUT);
    post connectToSlave();
  }
    
  /* we can get here by us (Master) closing the connection or the 
     slave closing the connection */
  async event void Bluetooth.connectionClosed(uint8_t reason){
    call Leds.greenOff();
    atomic enable_sending = bluetooth_connected = FALSE;
  
    post stopSending();
    post powerDownSystem();
    
    /* test app will connect again in 30 seconds */
    call BTMasterTestTimer.start(TIMER_ONE_SHOT, CONNECT_PERIOD);
  }

  async event void Bluetooth.dataAvailable(uint8_t data){
  }

  event void Bluetooth.writeDone(){
  }

  event result_t BTMasterTestTimer.fired() {
    if(bluetooth_connected) {
      post stopSending();
      // connection will be closed and BT module will be turned off when the connectionClosed event appears
      post sendMasterDisconnect();
    }
    else
      post powerUpSystem();

    return SUCCESS;
  }

  event result_t sendTimer.fired() {
    post sendString();

    return SUCCESS;
  }

  event result_t ConnectTimer.fired() {
    /* connection failed so clean up */
    call Leds.redToggle();
    post stopSending();
    post powerDownSystem();

    return SUCCESS;
  }

}

