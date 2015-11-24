#ifndef __HARDWARE_H__
#define __HARDWARE_H__
/* Include our CPU definitions */
#include <hcs08hardware.h>
#include <mcuToRadioPorts.h>

// Assign leds - the 13192 have four, dunno what to do about the last one...
TOSH_ASSIGN_PIN(RED_LED, D, 0);
TOSH_ASSIGN_PIN(GREEN_LED, D, 1);
TOSH_ASSIGN_PIN(YELLOW_LED, D, 3);
TOSH_ASSIGN_PIN(BLUE_LED, D, 4);

// Assing ADC pins - only these four are available
TOSH_ASSIGN_PIN(ADC1, B, 1);
TOSH_ASSIGN_PIN(ADC2, B, 2);
TOSH_ASSIGN_PIN(ADC3, B, 3);
TOSH_ASSIGN_PIN(ADC7, B, 7);

// MC13192 radio pins.
TOSH_ASSIGN_PIN(RADIO_CE, E, 2);       // SPI Chip Enable pin
TOSH_ASSIGN_PIN(RADIO_ATTN, C, 2);     // Attention pin
TOSH_ASSIGN_PIN(RADIO_RXTXEN, C, 3);   // Receive/Transmit Enable pin
TOSH_ASSIGN_PIN(RADIO_RESET, C, 4);    // Reset pin
TOSH_ASSIGN_PIN(RADIO_ANT_CTRL, B, 6); // Antenna Switch pin
TOSH_ASSIGN_PIN(RADIO_LNA_CTRL, B, 0); // LNA pin (Not mounted on EVB13192)
TOSH_ASSIGN_PIN(RADIO_OOI, B, 4);      // Out-of-idle pin (Used in stream mode)
TOSH_ASSIGN_PIN(RADIO_CRC, B, 5);      // CRC pin (Used in stream mode)

// Set the pin directions.
void TOSH_SET_PIN_DIRECTIONS(void)
{
  //LEDS
  TOSH_SET_RED_LED_PIN();
  TOSH_SET_GREEN_LED_PIN();
  TOSH_SET_YELLOW_LED_PIN();
  TOSH_SET_BLUE_LED_PIN();
  TOSH_MAKE_RED_LED_OUTPUT();
  TOSH_MAKE_GREEN_LED_OUTPUT();
  TOSH_MAKE_YELLOW_LED_OUTPUT();
  TOSH_MAKE_BLUE_LED_OUTPUT();
  
	//Radio
	TOSH_PULLUP_RADIO_RESET_DISABLE();
	TOSH_MAKE_RADIO_CE_OUTPUT();
	TOSH_MAKE_RADIO_ATTN_OUTPUT();
	TOSH_MAKE_RADIO_RXTXEN_OUTPUT();
	TOSH_MAKE_RADIO_RESET_OUTPUT();
	TOSH_MAKE_RADIO_OOI_INPUT();
	TOSH_PULLUP_RADIO_OOI_ENABLE();
	TOSH_MAKE_RADIO_CRC_INPUT();
	TOSH_PULLUP_RADIO_CRC_ENABLE();
	TOSH_MAKE_RADIO_ANT_CTRL_OUTPUT();
	TOSH_MAKE_RADIO_LNA_CTRL_OUTPUT();
}



#endif


#ifdef IMATELOS_H_hardware_h
#define _H_hardware_h

#include "msp430hardware.h"
#include "MSP430ADC12.h"

#include "CC2420Const.h"
#include "AM.h"

// LEDs
TOSH_ASSIGN_PIN(RED_LED, 5, 4);
TOSH_ASSIGN_PIN(GREEN_LED, 5, 5);
TOSH_ASSIGN_PIN(YELLOW_LED, 5, 6);

// CC2420 RADIO #defines
TOSH_ASSIGN_PIN(RADIO_CSN, 4, 2);
TOSH_ASSIGN_PIN(RADIO_VREF, 4, 5);
TOSH_ASSIGN_PIN(RADIO_RESET, 4, 6);
TOSH_ASSIGN_PIN(RADIO_FIFOP, 1, 0);
TOSH_ASSIGN_PIN(RADIO_SFD, 4, 1);
TOSH_ASSIGN_PIN(RADIO_GIO0, 1, 3);
TOSH_ASSIGN_PIN(RADIO_FIFO, 1, 3);
TOSH_ASSIGN_PIN(RADIO_GIO1, 1, 4);
TOSH_ASSIGN_PIN(RADIO_CCA, 1, 4);

TOSH_ASSIGN_PIN(CC_FIFOP, 1, 0);
TOSH_ASSIGN_PIN(CC_FIFO, 1, 3);
TOSH_ASSIGN_PIN(CC_SFD, 4, 1);
TOSH_ASSIGN_PIN(CC_VREN, 4, 5);
TOSH_ASSIGN_PIN(CC_RSTN, 4, 6);

// UART pins
TOSH_ASSIGN_PIN(SOMI0, 3, 2);
TOSH_ASSIGN_PIN(SIMO0, 3, 1);
TOSH_ASSIGN_PIN(UCLK0, 3, 3);
TOSH_ASSIGN_PIN(UTXD0, 3, 4);
TOSH_ASSIGN_PIN(URXD0, 3, 5);
TOSH_ASSIGN_PIN(UTXD1, 3, 6);
TOSH_ASSIGN_PIN(URXD1, 3, 7);
TOSH_ASSIGN_PIN(UCLK1, 5, 3);
TOSH_ASSIGN_PIN(SOMI1, 5, 2);
TOSH_ASSIGN_PIN(SIMO1, 5, 1);


// HUMIDITY
TOSH_ASSIGN_PIN(HUM_SDA, 1, 5);
TOSH_ASSIGN_PIN(HUM_SCL, 1, 6);
TOSH_ASSIGN_PIN(HUM_PWR, 1, 7);

// GIO pins
TOSH_ASSIGN_PIN(GIO0, 2, 0);
TOSH_ASSIGN_PIN(GIO1, 2, 1);

void HUMIDITY_MAKE_CLOCK_OUTPUT() { TOSH_MAKE_HUM_SCL_OUTPUT(); }
void HUMIDITY_MAKE_CLOCK_INPUT() { TOSH_MAKE_HUM_SCL_INPUT(); }
void HUMIDITY_CLEAR_CLOCK() { TOSH_CLR_HUM_SCL_PIN(); }
void HUMIDITY_SET_CLOCK() { TOSH_SET_HUM_SCL_PIN(); }
void HUMIDITY_MAKE_DATA_OUTPUT() { TOSH_MAKE_HUM_SDA_OUTPUT(); }
void HUMIDITY_MAKE_DATA_INPUT() { TOSH_MAKE_HUM_SDA_INPUT(); }
void HUMIDITY_CLEAR_DATA() { TOSH_CLR_HUM_SDA_PIN(); }
void HUMIDITY_SET_DATA() { TOSH_SET_HUM_SDA_PIN(); }
char HUMIDITY_GET_DATA() { return TOSH_READ_HUM_SDA_PIN(); }

#define HUMIDITY_TIMEOUT_MS          30
#define HUMIDITY_TIMEOUT_TRIES       20

enum {
  // Sensirion Humidity addresses and commands
  TOSH_HUMIDITY_ADDR = 5,
  TOSH_HUMIDTEMP_ADDR = 3,
  TOSH_HUMIDITY_RESET = 0x1E
};

// FLASH
TOSH_ASSIGN_PIN(FLASH_PWR, 4, 3);
TOSH_ASSIGN_PIN(FLASH_CS, 4, 4);

// PROGRAMMING PINS (tri-state)
//TOSH_ASSIGN_PIN(TCK, );
TOSH_ASSIGN_PIN(PROG_RX, 1, 1);
TOSH_ASSIGN_PIN(PROG_TX, 2, 2);

void TOSH_SET_PIN_DIRECTIONS(void)
{
  //LEDS
  TOSH_SET_RED_LED_PIN();
  TOSH_SET_GREEN_LED_PIN();
  TOSH_SET_YELLOW_LED_PIN();
  TOSH_MAKE_RED_LED_OUTPUT();
  TOSH_MAKE_GREEN_LED_OUTPUT();
  TOSH_MAKE_YELLOW_LED_OUTPUT();

  //RADIO PINS
  //CC2420 pins
  TOSH_MAKE_SOMI0_INPUT();
  TOSH_MAKE_SIMO0_INPUT();
  TOSH_MAKE_UCLK0_INPUT();
  TOSH_MAKE_SOMI1_INPUT();
  TOSH_MAKE_SIMO1_INPUT();
  TOSH_MAKE_UCLK1_INPUT();
  TOSH_SET_RADIO_RESET_PIN();
  TOSH_MAKE_RADIO_RESET_OUTPUT();
  TOSH_CLR_RADIO_VREF_PIN();
  TOSH_MAKE_RADIO_VREF_OUTPUT();
  TOSH_SET_RADIO_CSN_PIN();
  TOSH_MAKE_RADIO_CSN_OUTPUT();
  TOSH_MAKE_RADIO_FIFOP_INPUT();
  TOSH_MAKE_RADIO_GIO0_INPUT();
  TOSH_MAKE_RADIO_SFD_INPUT();
  TOSH_MAKE_RADIO_GIO1_INPUT();

  //UART PINS
  TOSH_MAKE_UTXD0_INPUT();
  TOSH_MAKE_URXD0_INPUT();
  TOSH_MAKE_UTXD1_INPUT();
  TOSH_MAKE_URXD1_INPUT();
  
  //PROG PINS
  TOSH_MAKE_PROG_RX_INPUT();
  TOSH_MAKE_PROG_TX_INPUT();

  //FLASH PINS
  TOSH_MAKE_FLASH_PWR_OUTPUT();
  TOSH_SET_FLASH_PWR_PIN();
  TOSH_MAKE_FLASH_CS_OUTPUT();
  TOSH_SET_FLASH_CS_PIN();

  //HUMIDITY PINS
  TOSH_MAKE_HUM_SCL_OUTPUT();
  TOSH_MAKE_HUM_SDA_OUTPUT();
  TOSH_MAKE_HUM_PWR_OUTPUT();
  TOSH_CLR_HUM_SCL_PIN();
  TOSH_CLR_HUM_SDA_PIN();
  TOSH_CLR_HUM_PWR_PIN();
}

#ifndef SENSORBOARD_H
#define SENSORBOARD_H

enum {
  TOSH_ADC_PORTMAPSIZE = 4 // default board has no sensors hooked up
};

enum
{
  TOSH_ACTUAL_ADC_PAR_PORT = ASSOCIATE_ADC_CHANNEL(
         INPUT_CHANNEL_A4, REFERENCE_VREFplus_AVss, REFVOLT_LEVEL_1_5
  ),
  TOSH_ACTUAL_ADC_TSR_PORT = ASSOCIATE_ADC_CHANNEL(
         INPUT_CHANNEL_A5, REFERENCE_VREFplus_AVss, REFVOLT_LEVEL_1_5
  ),
};

enum
{
  TOS_ADC_PAR_PORT,
  TOS_ADC_TSR_PORT,
  TOS_ADC_INTERNAL_TEMP_PORT,
  TOS_ADC_INTERNAL_VOLTAGE_PORT
};

#endif // SENSORBOARD_H

#endif // _H_hardware_h

