/*
 * @author: Brano Kusy, kusy@isis.vanderbilt.edu
 * @author: Miklos Maroti, mmaroti@gmail.com
 * Date last modified: April 2006
 *
 * provides timestamping on transmitting/receiving SFD interrupt,uses 
 * SysTime (Timer3) to get local time 
 */

#include "AM.h"

module SysTimeStampingM
{
	provides
	{
		interface TimeStamping;
	}
	uses
	{
		interface RadioCoordinator as RadioSendCoordinator;
		interface RadioCoordinator as RadioReceiveCoordinator;
		interface SysTime;
		interface Leds;
		interface HPLCC2420RAM;
	}
}

implementation
{
	int8_t sendStampOffset = -1;
	TOS_MsgPtr sendMsg;

	uint32_t captureTime;
	uint32_t downloadTime;
	uint32_t receiveTime;
	TOS_MsgPtr receiveMsg;

    enum{
        TX_FIFO_MSG_START = 10,
        SEND_TIME_CORRECTION = 6,
    };

	command result_t TimeStamping.addStamp2(TOS_MsgPtr msg, int8_t offset)
	{
		uint8_t ret = FAIL;

		if( 0 <= offset && offset <= TOSH_DATA_LENGTH - 4  )
		{
			atomic
			{
				sendStampOffset = offset;
				sendMsg = msg;
				ret = SUCCESS;
			}
		}

		return ret;
	}

	async event void RadioSendCoordinator.startSymbol(uint8_t bitsPerBlock, uint8_t offset, TOS_MsgPtr msgBuff)
	{
		int8_t offsetCopy = -1;

		atomic
		{
			if( sendStampOffset >= 0 && msgBuff == sendMsg )
				offsetCopy = sendStampOffset;
			else
				offsetCopy = -1;
		}

		if( offsetCopy >= 0 )
		{
		    *(uint32_t*)((void*)msgBuff->data + offsetCopy) += call SysTime.getTime32();
		    call Leds.redToggle();
			call HPLCC2420RAM.write(TX_FIFO_MSG_START + offsetCopy, 4, (void*)msgBuff->data + offsetCopy);

			atomic sendStampOffset = -1;
		}
	}

	async event void RadioReceiveCoordinator.startSymbol(uint8_t bitsPerBlock, uint8_t offset, TOS_MsgPtr msgBuff)
	{
		atomic
		{
			captureTime = call SysTime.getTime32() + SEND_TIME_CORRECTION;
			call Leds.greenToggle();
		}
	}

    async event void RadioReceiveCoordinator.byte(TOS_MsgPtr msg, uint8_t byteCount)
	{
		if( byteCount == 0 )	// fired when FIFOP is fired
		{
			atomic downloadTime = captureTime;
		}
		else					// fired when RXFIFODONE is fired
		{
			atomic
			{
				receiveTime = downloadTime;
				receiveMsg = msg;
			}
		}
	}

	command uint32_t TimeStamping.getStamp2(TOS_MsgPtr msg)
	{
		uint32_t time = 0;
		
		atomic
		{
			if( receiveMsg == msg )
				time = receiveTime;
		}

		return time;
	}

    async event result_t HPLCC2420RAM.readDone(uint16_t addr, uint8_t length, uint8_t* buffer)
	{
        return SUCCESS;
    }
    
    async event result_t HPLCC2420RAM.writeDone(uint16_t addr, uint8_t length, uint8_t* buffer)
	{
        return SUCCESS;
    }

	async event void RadioSendCoordinator.byte(TOS_MsgPtr msg, uint8_t byteCount) { }
    async event void RadioSendCoordinator.blockTimer() { }
    async event void RadioReceiveCoordinator.blockTimer() { }
}
