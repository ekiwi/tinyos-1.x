/* 
 * Copyright (c) 2005, Shockfish SA, Switzerland.
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
 * - Neither the name of the Ecole Polytechnique Federale de Lausanne (EPFL) 
 *   and Shockfish SA, nor the names of its contributors may be used to 
 *   endorse or promote products derived from this software without 
 *   specific prior written permission.
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
 * ========================================================================
 */

/*
 * Platform definitions for tinynode mamaboard
 *
 * @author Roger Meier
 */

#ifndef _H_MAMABOARD_h
#define _H_MAMABOARD_h


// LED's
TOSH_ALIAS_PIN(EX_RED_LED, STE1);
TOSH_ALIAS_PIN(EX_GREEN_LED, P23);
TOSH_ALIAS_PIN(EX_YELLOW_LED, P24);

// GPRS
TOSH_ALIAS_PIN(GPRS_EN, ADC6);		// GPRS enable, active high
TOSH_ALIAS_PIN(GPRS_IGT, STE1);		// P50, same pin as RED_LED
TOSH_ALIAS_PIN(GPRS_GPIO2, UCLK1);
TOSH_ALIAS_PIN(GPRS_SYNC, P16);

// SD card (connected to SPI1)
TOSH_ALIAS_PIN(SD_WP, P13);			// write protect
TOSH_ALIAS_PIN(NSD_CS, ADC7);		// chip select, active low

// Light sensor
TOSH_ALIAS_PIN(EX_LIGHT, ADC4);

// Temperature sensor
TOSH_ALIAS_PIN(EX_TEMP, ADC5);
TOSH_ALIAS_PIN(EX_TEMPE, P40);

// Humidity sensor
TOSH_ALIAS_PIN(HUM_SDA, P12);
TOSH_ALIAS_PIN(HUM_SCL, P41);
TOSH_ALIAS_PIN(HUM_PWR, NOT_CONNECTED1);	// for compatibility with telos

// associate ADC channels
enum
{
	TOSH_ADC_EX_LIGHT_PORT = unique("ADCPort"),
	TOSH_ACTUAL_ADC_EX_LIGHT_PORT = ASSOCIATE_ADC_CHANNEL(
								INPUT_CHANNEL_A4, 
								REFERENCE_VREFplus_AVss, 
								REFVOLT_LEVEL_1_5
								),

	TOSH_ADC_EX_TEMP_PORT = unique("ADCPort"),
	TOSH_ACTUAL_ADC_EX_TEMP_PORT = ASSOCIATE_ADC_CHANNEL(
							    INPUT_CHANNEL_A5, 
							    REFERENCE_VREFplus_AVss, 
							    REFVOLT_LEVEL_1_5
							   ),
};

#endif // _H_MAMABOARD_h
