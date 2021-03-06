// $Id: TOSBootM.nc,v 1.1.1.1 2007/01/10 21:10:50 lhuang2 Exp $

/*									tab:2
 * "Copyright (c) 2000-2005 The Regents of the University  of California.  
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
 */

/*
 * @author: Jonathan Hui <jwhui@cs.berkeley.edu>
 */

includes crc;
includes hardware;

module TOSBootM {
  uses {
    interface Exec;
    interface ExtFlash;
    interface Hardware;
    interface InternalFlash as IntFlash;
    interface Leds;
    interface ProgFlash;
    interface StdControl as SubControl;
    interface Voltage;
  }
}
implementation {

  enum {
    LEDS_LOWBATT = 1,
    LEDS_GESTURE = 7,
  };

  enum {
    R_SUCCESS,
    R_INVALID_IMAGE_ERROR,
    R_PROGRAMMING_ERROR,
  };

  void startupLeds() {

    uint8_t  output = 0x7;
    uint8_t  i;

    for (i = 3; i; i--, output >>= 1 )
      call Leds.glow(output, output >> 1);

  }

  uint32_t extFlashRead32() {
    uint32_t result = 0;
    uint8_t  i;
    for ( i = 0; i < 4; i++ )
      result |= ((uint32_t)call ExtFlash.readByte() & 0xff) << (i*8);    
    return result;
  }

  bool verifyImage(uint32_t startAddr) {

    uint16_t crcTmp = 0;
    int totalBytes;
    int i;
    ObjMetadata metadata;

    // Read metadata

    call ExtFlash.startRead(startAddr);
    for (i = 0; i < sizeof(ObjMetadata); i++) {
        *((uint8_t *)&metadata + i) = call ExtFlash.readByte();
    }
    call ExtFlash.stopRead();

    // Verify the completeness of the object.
   
    if (metadata.numPagesComplete != metadata.numPages) return FALSE;

    // Verify the integrity of metadata.

    for (crcTmp = 0, i = 0; i < offsetof(ObjMetadata, crcMeta); i++) {
        crcTmp = crcByte(crcTmp, *((uint8_t *)&metadata + i));
    }
    if (crcTmp != metadata.crcMeta) return FALSE;

    // Read object data and compute its CRC.

    totalBytes = ((metadata.numPages - 1) * PKTS_PER_PAGE + metadata.numPktsLastPage)
                 * BYTES_PER_PKT;

    call ExtFlash.startRead(startAddr + METADATA_SIZE);
    for (crcTmp = 0, i = 0; i < totalBytes; i++) {
        crcTmp = crcByte(crcTmp, call ExtFlash.readByte());
    }
    call ExtFlash.stopRead();
    if (crcTmp != metadata.crcData) return FALSE;
  
    return TRUE; 
  }

  result_t programImage(uint32_t startAddr) {

    uint8_t  buf[TOSBOOT_INT_PAGE_SIZE];
    uint16_t pageAddr, newPageAddr;
    uint32_t intAddr;
    uint32_t secLength;

    if (!verifyImage(startAddr))
      return R_INVALID_IMAGE_ERROR;

    startAddr += METADATA_SIZE; 

    call ExtFlash.startRead(startAddr);

    intAddr = extFlashRead32();
    secLength = extFlashRead32();

    while ( secLength ) {
      
      pageAddr = newPageAddr = intAddr / TOSBOOT_INT_PAGE_SIZE;

      // fill in ram buffer for internal program flash sector
      do {

	// check if secLength is all ones
	if ( secLength == 0xffffffff )
	  return FAIL;

	buf[(uint16_t)intAddr % TOSBOOT_INT_PAGE_SIZE] = call ExtFlash.readByte();
	intAddr++;
	
	if ( --secLength == 0 ) {
	  intAddr = extFlashRead32();
	  secLength = extFlashRead32();
	}

	newPageAddr = intAddr / TOSBOOT_INT_PAGE_SIZE;

      } while ( pageAddr == newPageAddr && secLength );
      
      call Leds.set(pageAddr);

      // write out page
      if (call ProgFlash.write(pageAddr*TOSBOOT_INT_PAGE_SIZE, buf,
			       TOSBOOT_INT_PAGE_SIZE) == FAIL)
	return R_PROGRAMMING_ERROR;

    }

    call ExtFlash.stopRead();

    return R_SUCCESS;

  }

  void runApp() {
    call SubControl.stop();
    call Exec.exec();
  }

  void startupSequence() {

    tosboot_args_t args;

    // check voltage and make sure flash can be programmed
    //   if not, just run the app, can't check for gestures
    //   if we can't write to the internal flash anyway
    if ( !call Voltage.okToProgram() ) {
      // give user some time and count down LEDs
      call Leds.flash(LEDS_LOWBATT);
      startupLeds();
      runApp();
    }

    // get current value of counter
    call IntFlash.read((uint8_t*)TOSBOOT_ARGS_ADDR, &args, sizeof(args));

    // increment gesture counter, see if it exceeds threshold
    if ( ++args.gestureCount >= TOSBOOT_GESTURE_MAX_COUNT - 1 ) {
      // gesture has been detected, display receipt of gesture on LEDs
      call Leds.flash(LEDS_GESTURE);

      // load golden image from flash
      // if the golden image is invalid, forget about reprogramming
      // if an error happened during reprogramming, reboot and try again
      //   not much else we can do :-/
      if (programImage(TOSBOOT_GOLDEN_IMG_ADDR) == R_PROGRAMMING_ERROR)
	call Hardware.reboot();
    }
    else {
      // update gesture counter
      call IntFlash.write((uint8_t*)TOSBOOT_ARGS_ADDR, &args, sizeof(args));
      
      if ( !args.noReprogram ) {
	// if an error happened during reprogramming, reboot and try again
	//   after two tries, try programming the golden image
	if (programImage(args.imageAddr) == R_PROGRAMMING_ERROR)
	  call Hardware.reboot();
      }
    }

    // give user some time and count down LEDs
    startupLeds();

    // reset counter and reprogramming flag
    args.gestureCount = 0xff;
    args.noReprogram = TRUE;
    call IntFlash.write((uint8_t*)TOSBOOT_ARGS_ADDR, &args, sizeof(args));
    
    runApp();

  }

  int main() __attribute__ ((C, spontaneous)) {

    __nesc_disable_interrupt();

    TOSH_SET_PIN_DIRECTIONS();
    call Hardware.init();

    call SubControl.init();
    call SubControl.start();

    startupSequence();

    return 0;

  }

}
