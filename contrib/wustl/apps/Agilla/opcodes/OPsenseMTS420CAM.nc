// $Id: OPsenseMTS420CAM.nc,v 1.3 2006/05/23 21:05:59 chien-liang Exp $

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
includes AgillaOpcodes;
includes TupleSpace;

module OPsenseM {
  provides {
    interface BytecodeI;
    interface StdControl;
  }
  uses {
    interface AgentMgrI;
    interface OpStackI;

    interface ADC as ADC_Photo;
    interface ADC as ADC_Temp;
    interface ADC as ADC_Mic;
    interface ADC as ADC_MagX;
    interface ADC as ADC_MagY;
    interface ADC as ADC_AccelX;
    interface ADC as ADC_AccelY;
    
    interface QueueI;
    interface ErrorMgrI;
  }
}
implementation {
  Queue waitQueue;
  AgillaAgentContext* _context;
  norace AgillaReading reading;  

  command result_t StdControl.init() {    
    call QueueI.init(&waitQueue, OP_SENSE_MTS420CA_M);    
    //call QueueI.init(&waitQueue);    
    //dbg(DBG_USR1, "OPsenseMTS420CAM queue is at address %i\n", (int)&waitQueue);
    return SUCCESS;
  }

  command result_t StdControl.start() {
    return SUCCESS;
  }

  command result_t StdControl.stop() {
    return SUCCESS;
  }
    
  task void senseDone() {
    call OpStackI.pushReading(_context, reading.type, reading.reading);
    call AgentMgrI.run(_context);
    _context = NULL;
    
    // Resume all agents in the wait queue.  It is necessary to
    // resume all agents because some of them might have reacted
    // while waiting.
    while (!call QueueI.empty(&waitQueue)) {
      call AgentMgrI.run(call QueueI.dequeue(NULL, &waitQueue));      
    }
  }

  command result_t BytecodeI.execute(uint8_t instr, AgillaAgentContext* context) {
    AgillaVariable arg;    
    context->state = AGILLA_STATE_WAITING;  // this prevents VM from running agent 
    
    // only one agent can sense at a time
    if (_context != NULL) {      
      context->pc--;          // re-run this instruction 
      call QueueI.enqueue(context, &waitQueue, context); // store waiting context
      return SUCCESS;
    }
    
    _context = context;
    if (call OpStackI.popOperand(context, &arg)) {            
      if (!(arg.vtype & AGILLA_TYPE_VALUE)) {
         dbg(DBG_USR1, "VM (%i:%i): ERRROR: OPsenseM.execute(): Invalid sensor argument type.\n", context->id.id, context->pc-1);
         call ErrorMgrI.error(context, AGILLA_ERROR_INVALID_SENSOR);
         return FAIL;
      }         
    
      reading.type = arg.value.value;
      dbg(DBG_USR1, "VM (%i:%i): Executing OPsense with value %i.\n", context->id.id, context->pc-1, reading.type);
      switch(reading.type) {
        case AGILLA_STYPE_PHOTO:
          atomic {       
            call ADC_Photo.getData();
          }
        break;
        case AGILLA_STYPE_TEMP:
          atomic {
            call ADC_Temp.getData();
          }
        break;
        case AGILLA_STYPE_MIC:
          atomic {
            call ADC_Mic.getData();
          }
        break;
        case AGILLA_STYPE_MAGX:
          atomic {
            call ADC_MagX.getData();
          }
        break;
        case AGILLA_STYPE_MAGY:
          atomic {
            call ADC_MagY.getData();
          }
        break;      
        case AGILLA_STYPE_ACCELX:
          atomic {
            call ADC_AccelX.getData();
          }
        break;
        case AGILLA_STYPE_ACCELY:
          atomic {
            call ADC_AccelY.getData();
          }
        break;      
        default:
          dbg(DBG_USR1, "VM (%i:%i): ERRROR: Invalid sensor argument.\n", context->id.id, context->pc-1);
          call ErrorMgrI.error(context, AGILLA_ERROR_INVALID_SENSOR);        
      }   
      return SUCCESS;
    } 
    return FAIL; 
  }  
  
  inline result_t saveData(uint16_t data) {
    reading.reading = data;
    return post senseDone();   
  }

  async event result_t ADC_Photo.dataReady(uint16_t data) { 
    return saveData(data);    
  }

  async event result_t ADC_Temp.dataReady(uint16_t data) {  
    return saveData(data);   
  }

  async event result_t ADC_Mic.dataReady(uint16_t data) {
    return saveData(data);
  }

  async event result_t ADC_MagX.dataReady(uint16_t data) {
    return saveData(data);
  }

  async event result_t ADC_MagY.dataReady(uint16_t data) {
    return saveData(data);
  }

  async event result_t ADC_AccelX.dataReady(uint16_t data) {
    return saveData(data);
  }

  async event result_t ADC_AccelY.dataReady(uint16_t data) {
    return saveData(data);
  }
}
