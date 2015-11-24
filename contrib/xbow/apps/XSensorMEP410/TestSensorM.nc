/**
 * Copyright (c) 2004-2005 Crossbow Technology, Inc.  All Rights Reserved.
 *
 * Permission to use, copy, modify and distribute, this software and 
 * documentation is granted, provided the following conditions are met:
 *   1. The above copyright notice and these conditions, along with the 
 *      following disclaimers, appear in all copies of the software.
 *   2. When the use, copying, modification or distribution is for COMMERCIAL 
 *      purposes (i.e., any use other than academic research), then the 
 *      software (including all modifications of the software) may be used 
 *      ONLY with hardware manufactured by and purchased from 
 *      Crossbow Technology, unless you obtain separate written permission 
 *      from, and pay appropriate fees to, Crossbow.  For example, no right 
 *      to copy and use the software on non-Crossbow hardware, if the use is 
 *      commercial in nature, is permitted under this license. 
 *   3. When the use, copying, modification or distribution is for 
 *      NON-COMMERCIAL PURPOSES (i.e., academic research use only), the 
 *      software may be used, whether or not with Crossbow hardware, 
 *      without any fee to Crossbow. 
 *
 * IN NO EVENT SHALL CROSSBOW TECHNOLOGY OR ANY OF ITS LICENSORS BE LIABLE TO 
 * ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL 
 * DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN 
 * IF CROSSBOW OR ITS LICENSOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
 * DAMAGE. CROSSBOW TECHNOLOGY AND ITS LICENSORS SPECIFICALLY DISCLAIM ALL 
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED 
 * HEREUNDER IS ON AN "AS IS" BASIS, AND NEITHER CROSSBOW NOR ANY LICENSOR HAS 
 * ANY OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, 
 * OR MODIFICATIONS. 
 *
 * $Id: TestSensorM.nc,v 1.1 2005/02/03 10:15:03 pipeng Exp $
 */

/******************************************************************************
 *    -Tests the Mep401 Mica2 Sensor Board
 *    -Read Accel, Light, Pressure, Temperature and Humidity(Internal and External) sensor readings
 *-----------------------------------------------------------------------------
 * Output results through mica2 uart and radio. 
 * Use Xlisten.exe program to view data from either port:
 *  uart: mount mica2 on mib510 with Mep401
 *        connect serial cable to PC
 *        run xlisten.exe at 56K baud
 *  radio: run mica2 with Mep401, 
 *         run mica2 with TOSBASE
 *         run xlisten.exe at 56K baud
 *-----------------------------------------------------------------------------
 * Data packet structure  :
 *
 * PACKET #1 (of 2)
 * ----------------
 *  msg->data[0] : sensor id, Mep401 = 0x87
 *  msg->data[1] : packet id = 10
 *  msg->data[2] : node id
 *  msg->data[3] : reserved
 *  msg->data[4,5] : accel_x adc data
 *  msg->data[6,7] : accel_y adc data
 *  msg->data[8,9] : photo1 data 
 *  msg->data[10,11] : photo2 data  
 *  msg->data[12,13] : photo3 data 
 *  msg->data[12,13] : photo4 data 
 *  msg->data[14,15] : humidity data
 *  msg->data[16,17] : thermistor data
 *  
 * PACKET #2 (of 2)
 * ----------------
 *  msg->data[0] : sensor id, Mep401 = 0x87
 *  msg->data[1] : packet id = 11
 *  msg->data[2] : node id
 *  msg->data[3] : reserved 
 *  msg->data[4,5] : cal_word1 
 *  msg->data[6,7] : cal_word2
 *  msg->data[8,9] : cal_word3
 *  msg->data[10,11] : cal_word4
 *  msg->data[12,13] : intersematemp
 *  msg->data[14,15] : pressure
 
 * ---------------------------------------------------------------------------
 *****************************************************************************/
#include "appFeatures.h"
includes sensorboard;

module TestSensorM {
  provides {
    interface StdControl;
  }
  uses {
  
    //interface ADCControl;
    interface Timer;
    interface Leds;

//communication
	interface StdControl as CommControl;
	interface SendMsg as Send;
	interface ReceiveMsg as Receive;
    
// Battery    
    interface ADC as ADCBATT;
    interface StdControl as BattControl;

    interface SplitControl as AccelControl;
    interface ADC as AccelX;
    interface ADC as AccelY;
    
    interface SplitControl as PhotoControl;
    interface ADC as Photo1;
    interface ADC as Photo2;
    interface ADC as Photo3;
    interface ADC as Photo4;
    
    interface SplitControl as HumControl;
    interface ADC as Humidity;
    interface ADC as Temperature;
    interface ADCError as HumidityError;
    interface ADCError as TemperatureError;

    interface SplitControl as IntHumControl;
    interface ADC as IntHumidity;
    interface ADC as IntTemperature;
    interface ADCError as IntHumidityError;
    interface ADCError as IntTemperatureError;
    
    interface SplitControl as IntersemaControl;
    interface ADC as Pressure;
    interface ADC as IntersemaTemperature;
    interface ADCError as PressureError;
    interface ADCError as IntersemaTemperatureError;
    interface Calibration;
  }
}

implementation {
	
  enum {STATE_START, STATE_VREF, STATE_ACCELX,STATE_ACCELY,
        STATE_PHOTO1,STATE_PHOTO2,STATE_PHOTO3,STATE_PHOTO4,
        STATE_HUMIDITY,STATE_THERM,STATE_INTHUMIDITY,STATE_INTTHERM,STATE_INTTHERMEND,
        STATE_CALIBRATION,STATE_PRESSURE,STATE_TEMP,};
/*
  enum { SENSOR_ID = 0, PACKET_ID, NODE_ID, RSVD};
  enum { VREF=4, ACCELX = 6, ACCELY = 8, PHOTO1=10, PHOTO2=12, 
         PHOTO3=14, PHOTO4=16, HUMIDITY=18, THERM=20,INTHUMIDITY=22, INTTHERM=24,};
  enum { CAL_WORD1 = 4, CAL_WORD2 = 6, CAL_WORD3 = 8,CAL_WORD4 = 10,
       	 TEMP = 12, PRESSURE = 14,};
 */ 
  #define MSG_LEN  29 

   TOS_Msg msg_buf;
   TOS_MsgPtr msg_ptr;
 
   bool sendPending;
   bool bIsUart;
   uint8_t state;
   
   char count;
   XDataMsg *pack;
   uint16_t calibration[4];           //intersema calibration words

/****************************************************************************
 * Task to xmit radio message
 *
 ****************************************************************************/
   task void send_radio_msg(){
    if(sendPending) return; 
    atomic sendPending=TRUE;  
    call Leds.yellowToggle(); 
    call Send.send(TOS_BCAST_ADDR,sizeof(XDataMsg),msg_ptr);
    return;
  }
/****************************************************************************
 * Task to uart as message
 *
 ****************************************************************************/
  task void send_uart_msg(){

    if(sendPending) return; 
    atomic sendPending=TRUE;  
    call Leds.yellowToggle(); 
        
    call Send.send(TOS_UART_ADDR,sizeof(XDataMsg),msg_ptr);
    return;
  }

/****************************************************************************
 * Initialize this and all low level components used in this application.
 * 
 * @return returns <code>SUCCESS</code> or <code>FAIL</code>
 ****************************************************************************/
  command result_t StdControl.init() {
    atomic{
        msg_ptr = &msg_buf;
        pack=(XDataMsg*)msg_ptr->data;
    };
    
    call BattControl.init();    
    
    atomic sendPending = TRUE;
    call CommControl.init();
    call Leds.init();
    atomic sendPending = FALSE;
    
    call AccelControl.init();
    call PhotoControl.init();
    call HumControl.init();
    call IntHumControl.init();
    call IntersemaControl.init();
		
    atomic state = STATE_START;
    
    call Leds.greenOff(); 
    call Leds.yellowOff(); 
    call Leds.redOff(); 
    
    return SUCCESS;
  }

/**
 * Start this component.
 * 
 * @return returns <code>SUCCESS</code>
 */
  command result_t StdControl.start(){
    call HumidityError.enable();
    call TemperatureError.enable();
    call BattControl.start(); 
    call IntHumidityError.enable();
    call IntTemperatureError.enable();
    call PressureError.enable();
    call IntersemaTemperatureError.enable();
    call CommControl.start();
    call Timer.start(TIMER_REPEAT, 2000);
    pack->xSensorHeader.board_id = SENSOR_BOARD_ID;
    pack->xSensorHeader.node_id = TOS_LOCAL_ADDRESS;
    pack->xSensorHeader.rsvd = 0;
    return SUCCESS;	
  }
/**
 * Stop this component.
 * 
 * @return returns <code>SUCCESS</code>
 */
  command result_t StdControl.stop() {
    call CommControl.stop();
    call BattControl.stop(); 
    call AccelControl.stop();
    call PhotoControl.stop();
    call HumControl.stop();
    call IntHumControl.stop();
    call IntersemaControl.stop();
    return SUCCESS;    
  }

/*********************************************
event handlers
*********************************************/

/***********************************************/  
  event result_t AccelControl.initDone() {
    return SUCCESS;
  }
  
/***********************************************/  
  event result_t AccelControl.stopDone() {
    return SUCCESS;
  }
  
/***********************************************/  
  event result_t PhotoControl.initDone() {
    return SUCCESS;
  }
  
/***********************************************/  
  event result_t PhotoControl.stopDone() {
    return SUCCESS;
  }
  
/***********************************************/  
  event result_t HumControl.initDone() {
    return SUCCESS;
  }
  
/***********************************************/  
  event result_t HumControl.stopDone() {
    return SUCCESS;
  }
  
/***********************************************/  
  event result_t IntHumControl.initDone() {
    return SUCCESS;
  }
  
/***********************************************/  
  event result_t IntHumControl.stopDone() {
    return SUCCESS;
  }
  
/***********************************************/  
  event result_t IntersemaControl.initDone() {
    return SUCCESS;
  }
  
/***********************************************/  
  event result_t IntersemaControl.stopDone() {
    return SUCCESS;
  }

/***********************************************/  
  event result_t Timer.fired() {
  	uint8_t l_state;
  	int i;
    bIsUart=TRUE;
	atomic l_state = state;
  	if ( sendPending ) return SUCCESS ;      //don't overrun buffers
    // sample
    call Leds.redOn();
    switch(l_state) {
    	case STATE_START:
    	    for(i=4;i<49;i++){((uint8_t*)pack)[i]=0x0;}
    	    atomic state = STATE_VREF;	
            call ADCBATT.getData();           //get vref data;
        	break;
        default:
            break;
    }
    return SUCCESS;
  }

/***********************************************/  

 /**********************************************
 * Battery Ref
 ***********************************************/
  async event result_t ADCBATT.dataReady(uint16_t data) {
      pack->xData.datax.vref = data ;
      atomic state = STATE_ACCELX;	
      call AccelControl.start();
      return SUCCESS;
  }
  
  event result_t AccelControl.startDone() {
    atomic state = STATE_ACCELX;   
    call AccelX.getData();
    return SUCCESS;
  }

  async event result_t AccelX.dataReady(uint16_t data)
  {
    pack->xData.datax.accel_x=data;
    atomic state = STATE_ACCELY;   
    call Leds.redOn();
    call AccelY.getData();
    return SUCCESS;
  }
  
  async event result_t AccelY.dataReady(uint16_t data)
  {
    pack->xData.datax.accel_y=data;
    call Leds.redOn();
    call AccelControl.stop();
    call PhotoControl.start();
    return SUCCESS;
  }
  
  /***********************************************/  
  event result_t PhotoControl.startDone() {
  	atomic state = STATE_PHOTO1;   
    call Photo1.getData();
    return SUCCESS;
  }
  
  /***********************************************/  
    async event result_t Photo1.dataReady(uint16_t data)
  {
    pack->xData.datax.photo[0]=data;
    atomic state = STATE_PHOTO2;   
    call Leds.greenOn();
    call Photo2.getData();
    return SUCCESS;
  }

  async event result_t Photo2.dataReady(uint16_t data)
  {
    pack->xData.datax.photo[1]=data;
    atomic state = STATE_PHOTO3;   
    call Leds.yellowOn();
    call Photo3.getData();
    return SUCCESS;
  }

  async event result_t Photo3.dataReady(uint16_t data)
  {
    pack->xData.datax.photo[2]=data;
    atomic state = STATE_PHOTO4;   
    call Leds.redOn();
    call Photo4.getData();
    return SUCCESS;
  }

  async event result_t Photo4.dataReady(uint16_t data)
  {
    pack->xData.datax.photo[3]=data;
    call Leds.yellowOff();
    call PhotoControl.stop();
    call HumControl.start();    
    return SUCCESS;
  }
  
/***********************************************/  
  event result_t HumControl.startDone() {
    atomic state = STATE_HUMIDITY;   
    call IntHumControl.start();    
    return SUCCESS;
  }

  event result_t IntHumControl.startDone() {
    atomic state = STATE_HUMIDITY;   
    call Humidity.getData();
    return SUCCESS;
  }

  async event result_t Humidity.dataReady(uint16_t data)
  {
    pack->xData.datax.humid=data;
    atomic state = STATE_THERM;   
    call Temperature.getData();
    return SUCCESS;
  }
  
   event result_t HumidityError.error(uint8_t token)
  {
    pack->xData.datax.humid= 0xffff;
    atomic state = STATE_THERM;   
    call Temperature.getData();
    return SUCCESS;
  }
  
  async event result_t Temperature.dataReady(uint16_t data)
  {	
    pack->xData.datax.humtemp= data;
    atomic state = STATE_INTHUMIDITY; 
    call IntHumidity.getData();
    return SUCCESS;
  }
  
  event result_t TemperatureError.error(uint8_t token)
  {
    pack->xData.datax.humtemp= 0xffff;
    atomic state = STATE_INTHUMIDITY; 
    call IntHumidity.getData();
    return SUCCESS;
  }
  
  async event result_t IntHumidity.dataReady(uint16_t data)
  {
    pack->xData.datax.inthum = data;
    atomic state = STATE_INTTHERM;   
    call IntTemperature.getData();
    return SUCCESS;
  }
  
   event result_t IntHumidityError.error(uint8_t token)
  {
    pack->xData.datax.inthum = 0xffff;
    atomic state = STATE_INTTHERM;   
    call IntTemperature.getData();
    return SUCCESS;
  }
  
  async event result_t IntTemperature.dataReady(uint16_t data)
  {	
    pack->xData.datax.inttemp = data;
    call HumControl.stop();
    call IntHumControl.stop();
    atomic state = STATE_CALIBRATION;	
    call IntersemaControl.start();
    return SUCCESS;
  }
  
  event result_t IntTemperatureError.error(uint8_t token)
  {
    pack->xData.datax.inttemp = 0xffff;
    call HumControl.stop();
    call IntHumControl.stop();
    atomic state = STATE_CALIBRATION;	
    call IntersemaControl.start();
    return SUCCESS;
  }
  
    event result_t IntersemaControl.startDone() {
    count = 0;
    atomic state = STATE_CALIBRATION;
    call Calibration.getData();
    return SUCCESS;
  }
  
    event result_t Calibration.dataReady(char word, uint16_t value) {
    // make sure we get all the calibration bytes
    count++;
    calibration[word-1] = value;

    if (count == 4) {
    	pack->xData.datax.presscalib[0] = calibration[0];
    	pack->xData.datax.presscalib[1] = calibration[1];
    	pack->xData.datax.presscalib[2] = calibration[2];
    	pack->xData.datax.presscalib[3] = calibration[3];

	    atomic state = STATE_PRESSURE;
        call Pressure.getData();
    }
    return SUCCESS;
  }

  event result_t PressureError.error(uint8_t token) {
    pack->xData.datax.press=0xffff;
	atomic state = STATE_TEMP;
    call IntersemaTemperature.getData();
    return SUCCESS;
  }
  
  async event result_t Pressure.dataReady(uint16_t data)
  {
    pack->xData.datax.press=data;
    call Leds.greenOn();
	atomic state = STATE_TEMP;
    call IntersemaTemperature.getData();
    return SUCCESS;
  }


  task void stopPressureControl()
  {
    //atomic sensor_state = SENSOR_PRESSURE_STOP;
    call IntersemaControl.stop();
    return;
  }
 
  event result_t IntersemaTemperatureError.error(uint8_t token)
  {
    pack->xData.datax.prtemp=0xffff;
	//call IntersemaControl.stop();
	post stopPressureControl();
    call Leds.greenOn();
	atomic state = STATE_START;
	pack->xSensorHeader.packet_id = 11;      // The No.2 packet for MEP401
   	post send_uart_msg();                                  //post uart xmit
	atomic state = STATE_START;
    return SUCCESS;
  }
  
  

  async event result_t IntersemaTemperature.dataReady(uint16_t data)
  {
    pack->xData.datax.prtemp=data;
	//call IntersemaControl.stop();
	post stopPressureControl();
    call Leds.greenOn();
	atomic state = STATE_START;
	pack->xSensorHeader.packet_id = 11;      // The No.2 packet for MEP401
   	post send_uart_msg();           // post uart xmit
	atomic state = STATE_START;
    return SUCCESS;
  }

/****************************************************************************
 * if Uart msg xmitted,Xmit same msg over radio
 * if Radio msg xmitted, issue a new round measuring
 ****************************************************************************/
  event result_t Send.sendDone(TOS_MsgPtr msg, result_t success) {
      //atomic msg_uart = msg;

      atomic msg_ptr = msg;
	  sendPending = FALSE;
      if(bIsUart)
      {
        bIsUart=!bIsUart;
        post send_radio_msg();
      }
      call Leds.redOff();
      return SUCCESS;
  }

/****************************************************************************
 * Uart msg rcvd. 
 * This app doesn't respond to any incoming uart msg
 * Just return
 ****************************************************************************/
  event TOS_MsgPtr Receive.receive(TOS_MsgPtr data) {
      return data;
  }

}

