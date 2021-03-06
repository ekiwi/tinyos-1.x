// $Id: AgillaReading.java,v 1.1 2005/10/13 17:12:19 chien-liang Exp $

/* Agilla - A middleware for wireless sensor networks.
 * Copyright (C) 2004, Washington University in Saint Louis
 * By Chien-Liang Fok.
 *
 * Washington University states that Agilla is free software;
 * you can redistribute it and/or modify it under the terms of
 * the current version of the GNU Lesser General Public License
 * as published by the Free Software Foundation.
 *
 * Agilla is distributed in the hope that it will be useful, but
 * THERE ARE NO WARRANTIES, WHETHER ORAL OR WRITTEN, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
 * MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.
 *
 * YOU UNDERSTAND THAT AGILLA IS PROVIDED "AS IS" FOR WHICH NO
 * WARRANTIES AS TO CAPABILITIES OR ACCURACY ARE MADE. THERE ARE NO
 * WARRANTIES AND NO REPRESENTATION THAT AGILLA IS FREE OF
 * INFRINGEMENT OF THIRD PARTY PATENT, COPYRIGHT, OR OTHER
 * PROPRIETARY RIGHTS.  THERE ARE NO WARRANTIES THAT SOFTWARE IS
 * FREE FROM "BUGS", "VIRUSES", "TROJAN HORSES", "TRAP DOORS", "WORMS",
 * OR OTHER HARMFUL CODE.
 *
 * YOU ASSUME THE ENTIRE RISK AS TO THE PERFORMANCE OF SOFTWARE AND/OR
 * ASSOCIATED MATERIALS, AND TO THE PERFORMANCE AND VALIDITY OF
 * INFORMATION GENERATED USING SOFTWARE. By using Agilla you agree to
 * indemnify, defend, and hold harmless WU, its employees, officers and
 * agents from any and all claims, costs, or liabilities, including
 * attorneys fees and court costs at both the trial and appellate levels
 * for any loss, damage, or injury caused by your actions or actions of
 * your officers, servants, agents or third parties acting on behalf or
 * under authorization from you, as a result of using Agilla.
 *
 * See the GNU Lesser General Public License for more details, which can
 * be found here: http://www.gnu.org/copyleft/lesser.html
 */
/**
 * AgillaSVInvalid.java
 *
 * @author Chien-Liang Fok
 */

package edu.wustl.mobilab.agilla.variables;
import edu.wustl.mobilab.agilla.*;

public class AgillaReading implements AgillaConstants, AgillaStackVariable,
	java.io.Serializable {
	
	private int type, reading;
	
	public AgillaReading(int type, int reading) {
		this.type = type;
		this.reading = reading;
	}
	
	public AgillaStackVariable deepClone() {
		return new AgillaReading(type, reading);
	}
	
	public short getType() {
		return AGILLA_TYPE_READING;
	}
	
	/**
	 * An AgillaReading is four bytes.
	 */
	public short getSize() {
		return 4;
	}
	
	public short[] toBytes() {
		short[] result = new short[getSize()];
		result[0] = (short)(getReadingType() & 0xff);
		result[1] = (short)(getReadingType() >> 8 & 0xff);
		result[2] = (short)(getReading() & 0xff);
		result[3] = (short)(getReading() >> 8 & 0xff);
		return result;
	}
	
	public int getReading() {
		return reading;
	}
	
	public int getReadingType() {
		return type;
	}
	
	public boolean matches(AgillaStackVariable v) {
		if (v instanceof AgillaReading) {
			AgillaReading ar = (AgillaReading)v;
			return ar.getReadingType() == getReadingType() && ar.getReading() == ar.getReading();
		} else return false;
	}
	
	public boolean equals(Object v) {
		if (v instanceof AgillaReading) {
			AgillaReading ar = (AgillaReading)v;
			return ar.type == type && ar.reading == reading;
		} else
			return false;
	}
	
	public String toString() {
		return "[reading type = " + AgillaRType.sensor2String(type) + ", reading = " + reading + "]";
	}
}

