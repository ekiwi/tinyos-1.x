//$Id: DS2411LiteM.nc,v 1.1 2005/07/29 18:29:31 adchristian Exp $

/* "Copyright (c) 2000-2003 The Regents of the University of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement
 * is hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY
 * OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 */

//@author Cory Sharp <cssharp@eecs.berkeley.edu>


/*

  The 1-wire timings suggested by the DS2411 data sheet are incorrect,
  incomplete, or unclear.  The timings provided the app note 522 work:

    http://www.maxim-ic.com/appnotes.cfm/appnote_number/522

*/

/*
  This is a stripped version of the DS2411 driver modified for our network stack.
  Instead of a nice abstraction layer, we rely on TOSH_ASSIGN_PIN(ONEWIRE) in the
  hardware.h file to set up the appropriate pin for communications.

  Andrew Christian <andrew.christian@hp.com>
  June 2005
*/

module DS2411LiteM
{
  provides interface IDChip;
}
implementation
{
  enum
  {
    STD_A = 6,
    STD_B = 64,
    STD_C = 60,
    STD_D = 10,
    STD_E = 9,
    STD_F = 55,
    STD_G = 0,
    STD_H = 480,
    STD_I = 90,
    STD_J = 220,
  };

  void init_pins()
  {
#ifdef ID_CHIP_POWER
    TOSH_SET_ONEWIRE_POWER_PIN();    
    TOSH_MAKE_ONEWIRE_POWER_OUTPUT();
#endif

    TOSH_SEL_ONEWIRE_IOFUNC();
    TOSH_MAKE_ONEWIRE_INPUT();
    TOSH_CLR_ONEWIRE_PIN();
  }

  void clear_pins()
  {
#ifdef TOSH_SET_ONEWIRE_POWER_PIN
    TOSH_CLR_ONEWIRE_POWER_OUTPUT();
#endif
    // Don't need to fix ONEWIRE...it finishes as an INPUT
  }

  bool reset() // >= 960us
  {
    int present;
    TOSH_MAKE_ONEWIRE_OUTPUT();
    TOSH_uwait(STD_H); //t_RSTL
    TOSH_MAKE_ONEWIRE_INPUT();
    TOSH_uwait(STD_I);  //t_MSP
    present = TOSH_READ_ONEWIRE_PIN();
    TOSH_uwait(STD_J);  //t_REC
    return (present == 0);
  }

  void write_bit_one() // >= 70us
  {
    TOSH_MAKE_ONEWIRE_OUTPUT();
    TOSH_uwait(STD_A);  //t_W1L
    TOSH_MAKE_ONEWIRE_INPUT();
    TOSH_uwait(STD_B);  //t_SLOT - t_W1L
  }

  void write_bit_zero() // >= 70us
  {
    TOSH_MAKE_ONEWIRE_OUTPUT();
    TOSH_uwait(STD_C);  //t_W0L
    TOSH_MAKE_ONEWIRE_INPUT();
    TOSH_uwait(STD_D);  //t_SLOT - t_W0L
  }

  void write_bit( int is_one ) // >= 70us
  {
    if(is_one)
      write_bit_one();
    else
      write_bit_zero();
  }

  bool read_bit() // >= 70us
  {
    int bit;
    TOSH_MAKE_ONEWIRE_OUTPUT();
    TOSH_uwait(STD_A);  //t_RL
    TOSH_MAKE_ONEWIRE_INPUT();
    TOSH_uwait(STD_E); //near-max t_MSR
    bit = TOSH_READ_ONEWIRE_PIN();
    TOSH_uwait(STD_F);  //t_REC
    return bit;
  }

  void write_byte( uint8_t byte ) // >= 560us
  {
    uint8_t bit;
    for( bit=0x01; bit!=0; bit<<=1 )
      write_bit( byte & bit );
  }

  uint8_t read_byte() // >= 560us
  {
    uint8_t byte = 0;
    uint8_t bit;
    for( bit=0x01; bit!=0; bit<<=1 )
    {
      if( read_bit() )
	byte |= bit;
    }
    return byte;
  }

  uint8_t crc8_byte( uint8_t crc, uint8_t byte )
  {
    int i;
    crc ^= byte;
    for( i=0; i<8; i++ )
    {
      if( crc & 1 )
        crc = (crc >> 1) ^ 0x8c;
      else
        crc >>= 1;
    }
    return crc;
  }

  /*
   * Reset the DS2411 chip and read the 8 bytes of data out.  
   * We verify the CRC to ensure good data, dump the family byte (it should be '1')
   * and fill a buffer with the 6 good uniqut address bytes.
   *
   * It is possible for the initialization to fail.
   */

  command result_t IDChip.read( uint8_t *id_buf ) // >= 6000us
  {
    int retry = 5;
    uint8_t id[8];

    init_pins();
    TOSH_uwait( 1200 );    // Delay a bit at start up (as per DS2411 data sheet)

    while( retry-- > 0 ) {
      int crc = 0;
      if( reset() ) {
	uint8_t* byte;

	write_byte(0x33); //read rom
	for( byte=id+7; byte!=id-1; byte-- )
	  crc = crc8_byte( crc, *byte=read_byte() );

	if( crc == 0 ) {
	  memcpy( id_buf, id + 1, 6 );
	  clear_pins();
	  return SUCCESS;
	}
      }
    }

    clear_pins();
    return FAIL;
  }
}

