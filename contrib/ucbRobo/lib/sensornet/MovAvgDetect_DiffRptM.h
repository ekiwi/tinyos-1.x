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
 */
// $Id: MovAvgDetect_DiffRptM.h,v 1.1 2005/04/16 01:01:44 phoebusc Exp $
/**  
 * MovAvgDetect_DiffRptM.h contains the constants used by
 * MovAvgDetect_DiffRptM.nc.  This is so ncg, the NesC Constant
 * Generator, will properly extract the constants and dump it in a
 * java file.
 *
 * @author Phoebus Chen
 * @modified 4/13/2005 File created
 */

//constants are used by MovAvgDetect_DiffRptM.nc
  enum {
    MAX_SAMPLES = 32,
    DEFAULT_REPORT_THRESH = 600,
    DEFAULT_READ_FIRE_INTERVAL = 50,
    DEFAULT_WINDOW_SIZE = 10, //Make sure less than MAX_SAMPLES
  };

