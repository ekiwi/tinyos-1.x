/*
 * Copyright (c) 2004, Technische Universitaet Berlin
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions 
 * are met:
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright 
 *   notice, this list of conditions and the following disclaimer in the 
 *   documentation and/or other materials provided with the distribution.
 * - Neither the name of the Technische Universitaet Berlin nor the names 
 *   of its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * - Description ---------------------------------------------------------
 * Controlling the TDA5250 Radio Component.
 * - Revision -------------------------------------------------------------
 * $Revision: 1.5 $
 * $Date: 2005/09/20 08:32:42 $
 * @author: Kevin Klues (klues@tkn.tu-berlin.de)
 * ========================================================================
 */
 
includes HPLTDA5250Const;

interface HPLTDA5250Config {
   
   /** 
      Signaled once when the radio is ready for the commands in
      this interface to be called
   */   
   event void ready();   

   /**
     Reset all Radio Registers to default values as defined
     in the Manual
   */
   command void reset();

   /*
    * switch UART to SPI mode 
    */
   async command result_t enableSPI();

   /**
     Set the exact contents of the writable radio data 
     registers
   */
   async command void SetRegisterCONFIG(uint16_t value);
   async command void SetRegisterFSK(uint16_t value);
   async command void SetRegisterXTAL_TUNING(uint16_t value);
   async command void SetRegisterLPF(uint8_t value);
   async command void SetRegisterON_TIME(uint16_t value);
   async command void SetRegisterOFF_TIME(uint16_t value);
   async command void SetRegisterCOUNT_TH1(uint16_t value);
   async command void SetRegisterCOUNT_TH2(uint16_t value);
   async command void SetRegisterRSSI_TH3(uint8_t value);
   async command void SetRegisterCLK_DIV(uint8_t value);
   async command void SetRegisterXTAL_CONFIG(uint8_t value);
   async command void SetRegisterBLOCK_PD(uint16_t value);
   
   /**
     Set parts of certain registers according to their 
     logical function
   */   
   async command void UseRCIntegrator();
   async command void UsePeakDetector();
   async command void PowerDown();
   async command void PowerUp();
   async command void RunInTestMode();
   async command void RunInNormalMode();
   async command void ControlRxTxExternally();
   async command void ControlRxTxInternally();
   async command void UseFSK(uint8_t pos_shift, uint8_t neg_shift);
   async command void UseASK(uint8_t value);
   async command void SetClockOffDuringPowerDown();
   async command void SetClockOnDuringPowerDown();
   async command void InvertData();
   async command void DontInvertData();
   async command void UseRSSIDataValidDetection(uint8_t value, uint16_t lower_bound, uint16_t upper_bound);
   async command void UseVCCDataValidDetection(uint8_t value, uint16_t lower_bound, uint16_t upper_bound);
   async command void UseDataValidDetection();
   async command void UseDataAlwaysValid();
   async command void ADCContinuousMode();
   async command void ADCOneShotMode();
   async command void DataValidContinuousMode();
   async command void DataValidOneShotMode();
   async command void HighLNAGain();
   async command void LowLNAGain();
   async command void EnableReceiverInTimedModes();
   async command void DisableReceiverInTimedModes();
   async command void UseHighTxPower();
   async command void UseLowTxPower();
   async command result_t UseBipolarXTALTuning(uint8_t fsk_ramp0, uint8_t fsk_ramp1, uint8_t nom_freq);
   async command result_t UseFETXTALTuning(uint8_t nom_freq);
   /**
      Set the mode of the radio 
      The choices are SLAVE_MODE, TIMER_MODE, SELF_POLLING_MODE
   */
   async command void SetSlaveMode();   
   async command void SetTimerMode(float on_time, float off_time);
   async command void ResetTimerMode();
   async command void SetSelfPollingMode(float on_time, float off_time);
   async command void ResetSelfPollingMode();
   
   /**
    * Set the contents of the LPF register with either the Low pass filter value
    * or the IQ filter value
   */
   async command void SetLowPassFilter(uint8_t data_cutoff);
   async command void SetIQFilter(uint8_t iq_cutoff);
   
   /**
      Set the on time and off time of the radio
      (Only makes sense when in TIMER or SELF_POLLING Mode)
   */
   async command void SetOnTime_ms(float time);
   async command void SetOffTime_ms(float time);
   /**
      Set the frequency that the CLK_DIV outputs
      (Available frequencies given in TDA5250ClockFreq_t struct)
   */
   async command void UseSetClock();
   async command void Use18MHzClock();
   async command void Use32KHzClock();
   async command void UseWindowCountAsClock();
   async command void SetRadioClock(TDA5250ClockOutFreqs_t freq);  
   
   /**
      Sets the threshold Values for internal evaluation
   */
   async command void SetRSSIThreshold(uint8_t value);
   async command void SetVCCOver5Threshold(uint8_t value);
   async command void SetLowerDataRateThreshold(uint16_t value);
   async command void SetUpperDataRateThreshold(uint16_t value);
      
   /**
      Get the exact contents of the readable radio data 
      registers
   */   
   async command uint8_t GetRegisterSTATUS();
   async command uint8_t GetRegisterADC();
   
   /**
     Get parts of certain registers according to their 
     logical functionality 
   */      
   async command uint8_t GetRSSIValue();
   async command uint8_t GetADCSelectFeedbackBit();
   async command uint8_t GetADCPowerDownFeedbackBit();
   async command bool IsDataRateLessThanLowerThreshold();
   async command bool IsDataRateBetweenThresholds();
   async command bool IsDataRateLessThanUpperThreshold();
   async command bool IsDataRateLessThanHalfOfLowerThreshold();
   async command bool IsDataRateBetweenHalvesOfThresholds();
   async command bool IsDataRateLessThanHalfOfUpperThreshold();
   async command bool IsRSSIEqualToThreshold();
   async command bool IsRSSIGreaterThanThreshold();

   /**
    switch source of SMCLCK
   */
   async command void sourceSMCLKfromDCO();
   async command void sourceSMCLKfromRadio();
   
   /**
      Switches radio between states when in SLAVE_MODE
   */
   async command void SetTxState();
   async command void SetRxState();
   async command void SetSleepState();
   
   event void SetTxStateDone();
   event void SetRxStateDone();
   event void SetSleepStateDone();  
   event void RSSIStable();
   
   /**
      Interrupt avialable on the PWD_DD pin when in 
      TIMER_MODE or SELF_POLLING_MODE
   */   
   async event void PWD_DDInterrupt();
}

