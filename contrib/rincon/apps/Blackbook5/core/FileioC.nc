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
 * Blackbook Fileio Configuration
 * Writes data to an address in a file, fills up each node
 * and automatically loads the next node for writing.
 *
 * @author David Moss - dmm@rincon.com
 */
 
configuration FileioC {
  provides {
    interface StdControl;
    interface Fileio;
  }
}

implementation {
  components FileioM, FlashBridgeC, NodeShopC, NodeMapC, StateC, GenericCrcC;
  
  Fileio = FileioM;
  StdControl = FlashBridgeC;
  
  FileioM.FlashBridge -> FlashBridgeC.FlashBridge[unique("FlashBridge")];
  FileioM.GenericCrc -> GenericCrcC;
  FileioM.NodeShop -> NodeShopC;
  FileioM.NodeMap -> NodeMapC; 
  FileioM.State -> StateC.State[unique("State")];
}
