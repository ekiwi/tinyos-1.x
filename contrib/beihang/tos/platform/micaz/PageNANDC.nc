/*
 * file:        PageNANDC.nc
 * description: Component for NAND Flash driver
 *
 * author:      Peter Desnoyers, UMass Computer Science Dept., 2006
 * $Id: PageNANDC.nc,v 1.1 2011/08/14 16:37:54 dukenunee Exp $
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

configuration PageNANDC {
    provides {
        interface StdControl;
	interface PageNAND;
    }
}

/* Using the separate configuration file lets us #ifdef the wiring for
 *the serial debug console.
 */
implementation {
    components PageNANDM;

#ifdef DEBUG_NAND
    components ConsoleC;
#endif

    StdControl = PageNANDM;
    PageNAND = PageNANDM;

#ifdef DEBUG_NAND
    PageNANDM.Console -> ConsoleC;
#endif

}

    
