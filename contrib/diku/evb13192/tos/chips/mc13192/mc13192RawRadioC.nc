/* Copyright (c) 2006, Jan Flora <janflora@diku.dk>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 *  - Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *  - Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *  - Neither the name of the University of Copenhagen nor the names of its
 *    contributors may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
  @author Jan Flora <janflora@diku.dk>
*/

includes mc13192Const;

configuration mc13192RawRadioC
{
	provides {
		interface StdControl as StdControl;
		interface mc13192Send as Send;
		interface mc13192Receive as Receive;
		interface mc13192CCA as CCA;
		interface mc13192Control as Control;
		interface mc13192PowerManagement as PowerMng;
	}
	uses {
		interface FastSPI as SPI;
	}
}
implementation
{
	components mc13192DataM as Data,
	           mc13192ControlM as RadioControl,
	           mc13192InterruptM as Interrupt,
	           mc13192HardwareM as Hardware,
	           mc13192TimerM as Timer,
	           mc13192TimerCounterM as TimerCounter,
	           mc13192StateM as State,
	           LedsC, ConsoleC;


	//Control = ConsoleC.StdControl;
	StdControl = RadioControl.StdControl;
	StdControl = Timer.StdControl;
	StdControl = Data.StdControl;
	Send = Data.Send;
	Receive = Data.Recv;
	CCA = Data.CCA;
	Control = RadioControl.RadioControl;
	PowerMng = RadioControl.PowerMng;
	SPI = Hardware.SPI;
	SPI = Data.SPI;
	SPI = Interrupt.SPI;
	
	RadioControl.Interrupt -> Interrupt.Control;
	RadioControl.Regs -> Hardware.Regs;
	RadioControl.Timer2 -> Timer.Timer[1];
	RadioControl.Time -> TimerCounter.Time;
	RadioControl.State -> State.State;
	RadioControl.Leds -> LedsC;
	RadioControl.ConsoleOut -> ConsoleC.ConsoleOut;
	
	Data.Timer2 -> Timer.Timer[1];
	Data.Timer3 -> Timer.Timer[2];
	Data.Time -> TimerCounter.Time;
	Data.Regs -> Hardware.Regs;
	Data.Interrupt -> Interrupt.Data;
	Data.State -> State.State;
	Data.Leds -> LedsC;
	Data.ConsoleOut -> ConsoleC.ConsoleOut;
	
	Timer.Regs -> Hardware.Regs;
	Timer.Interrupt -> Interrupt.Timer;
	Timer.Leds -> LedsC;
	Timer.ConsoleOut -> ConsoleC.ConsoleOut;
	
	Interrupt.State -> State.State;
	Interrupt.Leds -> LedsC;
	Interrupt.ConsoleOut -> ConsoleC.ConsoleOut;
	
	
	State.Regs -> Hardware.Regs;
	State.ConsoleOut -> ConsoleC.ConsoleOut;
	
	Hardware.Leds -> LedsC;
	Hardware.ConsoleOut -> ConsoleC.ConsoleOut;
	
	TimerCounter.Regs -> Hardware.Regs;
	TimerCounter.Leds -> LedsC;
	TimerCounter.ConsoleOut -> ConsoleC.ConsoleOut;

}
