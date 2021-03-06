// $Id: OPcistypeM.nc,v 1.3 2006/05/18 19:58:41 chien-liang Exp $

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

includes Agilla;

/**
 * Determines whether the type of the second variable on the stack
 * matches the TYPE variable on top of the stack.
 *
 * @author Chien-Liang Fok
 * @version 1.3
 */
module OPcistypeM {
  provides interface BytecodeI;  
  uses {
    interface OpStackI;  
    interface ErrorMgrI;
  }  
}
implementation {
  command result_t BytecodeI.execute(uint8_t instr, AgillaAgentContext* context) {    
    AgillaVariable arg1, arg2;
    if (call OpStackI.popOperand(context, &arg1)) {
      if (arg1.vtype != AGILLA_TYPE_TYPE && arg1.vtype != AGILLA_TYPE_STYPE) {
        dbg(DBG_ERROR, "VM (%i:%i): cistype: First argument is not a type %i.\n", context->id.id, context->pc-1, arg1.vtype);
        call ErrorMgrI.errord(context, AGILLA_ERROR_INVALID_TYPE, 0x07);
        return FAIL;
      }
      if (call OpStackI.popOperand(context, &arg2)) {        
        if (arg1.vtype == AGILLA_TYPE_TYPE) {
          context->condition = (arg1.type.type == arg2.vtype);      
          dbg(DBG_USR1, "VM (%i:%i): Executing cistype: Required type = %i, Found type = %i, Setting condition to %i.\n", context->id.id, context->pc-1, arg1.type.type, arg2.vtype, context->condition);                                    
        } else {
          context->condition = (arg1.rtype.stype == arg2.reading.type);      
          dbg(DBG_USR1, "VM (%i:%i): Executing cistype: Required reading type = %i, Found reading type = %i, Setting condition to %i.\n", context->id.id, context->pc-1, arg1.rtype.stype, arg2.reading.type, context->condition);                            
        }
      }
    }    
    return SUCCESS;
  }
}
