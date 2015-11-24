/*
 * Copyright (c) 2004-2006 Rincon Research Corporation.  
 * All rights reserved.
 * 
 * Rincon Research will permit distribution and use by others subject to
 * the restrictions of a licensing agreement which contains (among other things)
 * the following restrictions:
 * 
 *  1. No credit will be taken for the Work of others.
 *  2. It will not be resold for a price in excess of reproduction and 
 *      distribution costs.
 *  3. Others are not restricted from copying it or using it except as 
 *      set forward in the licensing agreement.
 *  4. Commented source code of any modifications or additions will be 
 *      made available to Rincon Research on the same terms.
 *  5. This notice will remain intact and displayed prominently.
 * 
 * Copies of the complete licensing agreement may be obtained by contacting 
 * Rincon Research, 101 N. Wilmot, Suite 101, Tucson, AZ 85711.
 * 
 * There is no warranty with this product, either expressed or implied.  
 * Use at your own risk.  Rincon Research is not liable or responsible for 
 * damage or loss incurred or resulting from the use or misuse of this software.
 */
 
/**
 * Blackbook File System Full Configuration
 * This is the configuration to wire to your application.
 *
 * For each provided interface except BBoot and BClean,
 * use unique("interface") to connect, for example:
 *
 * <code>
 *   MyApp.BFileWrite -> BlackbookC.BFileWrite[unique("BFileWrite")];
 * </code>
 *
 * This configuration wires up Blackbook to provide Dictionary and Binary
 * file functionality.
 *
 * @author David Moss - dmm@rincon.com
 */

includes Blackbook;

configuration BlackbookFullC {
  provides {
    interface StdControl;
    interface BFileRead[uint8_t id];
    interface BFileWrite[uint8_t id];
    interface BFileDelete[uint8_t id];
    interface BFileDir[uint8_t id];
    interface BDictionary[uint8_t id];
    interface BClean;
    interface BBoot;
  }
}

implementation {

  components BDictionaryC, BFileDeleteC, BCleanC;
  components BFileReadC, BFileWriteC;
  components BFileDirC, BBootFullC;
  components CheckpointC;
  
  components FileioC, WriteAllocC, NodeMapC, NodeShopC, SectorMapC, FlashBridgeC, StateC;
  
  StdControl = BFileReadC;
  StdControl = BFileWriteC;
  StdControl = BDictionaryC;
  
  StdControl = CheckpointC;
  StdControl = FileioC;
  StdControl = NodeMapC;
  StdControl = SectorMapC;
  StdControl = StateC;
  StdControl = FlashBridgeC;
  
  BFileRead = BFileReadC;
  BFileWrite = BFileWriteC;
  BFileDelete = BFileDeleteC;
  BFileDir = BFileDirC;
  BDictionary = BDictionaryC;
  BBoot = BBootFullC;
  BClean = BCleanC;
  
  BFileDeleteC.Checkpoint -> CheckpointC;
  
}

