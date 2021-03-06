/*
  Copyright (C) 2004 Klaus S. Madsen <klaussm@diku.dk>
  Copyright (C) 2006 Marcus Chang <marcus@diku.dk>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/


#include "HPLSpi.h"


module HALSTM25P40M {
	provides {
		interface HALSTM25P40 as Flash;
	}

	uses {
		interface HPLSTM25P40 as HPLFlash;
		interface Timer;
		interface Spi;
		interface BusArbitration;
		interface StdOut;
	}
}

implementation {

#define QUEUE_SIZE 9
#define FLASH_BUSY_BACKOFF 200

	enum
	{
		TASK_READ = 0x01,
		TASK_FAST_READ = 0x02,
		TASK_WRITE = 0x03,
		TASK_SECTOR_ERASE = 0x04,
		TASK_BULK_ERASE = 0x05,
		TASK_SLEEP = 0x06,
		TASK_WAKEUP = 0x07,
		TASK_CHECK_BUSY = 0x08,
	};
		
	task void readTask();
	task void fastReadTask();
	task void writeTask();
	task void sectorEraseTask();
	task void bulkEraseTask();
	task void sleepTask();
	task void wakeupTask();
	task void checkBusyTask();

	bool taskPosted[QUEUE_SIZE];
	uint8_t queue[QUEUE_SIZE];
	uint8_t first, last, currentTask;
    bool timerActive = FALSE, flashTaskPosted = FALSE, postCheckBusyTask = FALSE;
    bool flashOn = FALSE;

    /**********************************************************************
     *********************************************************************/
	bool queuePutBack(uint8_t id) {

		if ( (queue[id] != 0) || (last == id) || (id > QUEUE_SIZE - 1) )
			return FALSE;

		if (first == 0) {
			first = id;
			last = id;
		} else {
			queue[last] = id;	
			last = id;
		}

		return TRUE;
	}

	bool queuePutFront(uint8_t id) {

		if ( (queue[id] != 0) || (last == id) || (id > QUEUE_SIZE - 1) )
			return FALSE;

		if (first == 0) {
			first = id;
			last = id;
		} else {
			queue[id] = first;
			first = id;
		}

		return TRUE;
	}

	uint8_t queueGet() {
		uint8_t retval;
		
		retval = first;
		first = queue[retval];
		queue[retval] = 0;

		if (first == 0) {
			last = 0;
		}
		
		return retval;
	}

	bool queueEmpty() {
		if ( (first == 0) && (flashTaskPosted == FALSE) ) {
			return TRUE;
		} else {
			return FALSE;
		}
	}
	
	void postNextTask() {
		uint8_t id;
		
		id = queueGet();

		switch(id) {           
			case TASK_READ:
				flashTaskPosted = TRUE;
				post readTask();
				break;

			case TASK_FAST_READ:
				flashTaskPosted = TRUE;
				post fastReadTask();
				break;

			case TASK_WRITE:
				flashTaskPosted = TRUE;
				post writeTask();
				break;

			case TASK_SECTOR_ERASE:
				flashTaskPosted = TRUE;
				post sectorEraseTask();
				break;

			case TASK_BULK_ERASE:
				flashTaskPosted = TRUE;
				post bulkEraseTask();
				break;

			case TASK_SLEEP:
				flashTaskPosted = TRUE;
				post sleepTask();
				break;

			case TASK_WAKEUP:
				flashTaskPosted = TRUE;
				post wakeupTask();
				break;

			default:
				break;
		}
	
			
		return;
	}

	/**********************************************************************
	 *********************************************************************/
	event result_t BusArbitration.busFree()
	{
		if (!timerActive && !queueEmpty() && !flashTaskPosted)
		{
			postNextTask();
		}
        else if (!timerActive && queueEmpty() && !flashTaskPosted && flashOn)
        {
            flashTaskPosted = TRUE;
            post sleepTask();
        }        
		else if (postCheckBusyTask == TRUE)
		{
			postCheckBusyTask = FALSE;
			post checkBusyTask();
		}

		return SUCCESS;
	}

	/**********************************************************************
	 *********************************************************************/
	event result_t Timer.fired()
	{
		post checkBusyTask();
		
		return SUCCESS;
	}

	/**********************************************************************
	 * Flash read
	 *********************************************************************/
	/**
	 * Read flash block.
	 *
	 *
	 * \param address block address on flash
	 * \param buffer  pointer to buffer
	 * \param length  length of read buffer
	 *
	 * \return SUCCESS
	 * \return FAIL	bus not free or init failed
	 */
	uint32_t readQueueAddress;
	uint8_t * readQueueBuffer;
	uint16_t readQueueLength;

	command result_t Flash.read(uint32_t address, uint8_t *buffer, uint16_t length)
	{
		if (address > 0x07FFFF) return FAIL;

		if (!taskPosted[TASK_READ]) {
			taskPosted[TASK_READ] = TRUE;
			
			readQueueAddress = address;
			readQueueBuffer = buffer;
			readQueueLength = length;

            /* if the queue is empty no task has been posted and the flash is off */
			if (queueEmpty()) {
				flashTaskPosted = TRUE;

                if (flashOn)
                {
                    post readTask();
                } else
                {
                    post wakeupTask();
                    queuePutBack(TASK_READ);
                }
			} else 
                queuePutBack(TASK_READ);

			return SUCCESS;
		} else {
			return FAIL;
		}
		
	}
	
	task void readTask() {

		if (call BusArbitration.getBus() == FAIL) {
			queuePutFront(TASK_READ);
			return;
		}
		
		/***********************************************
		** select SPI bus and module 1 (micro4)
		***********************************************/
		call Spi.enable(BUS_CLOCK_INVERT + BUS_CLOCK_4MHZ, 1);

		/***********************************************
		** Read flash into buffer
		***********************************************/
		call HPLFlash.read(readQueueAddress, readQueueBuffer, readQueueLength);

		signal Flash.readReady(readQueueAddress, readQueueBuffer, readQueueLength);

		flashTaskPosted = FALSE;
		taskPosted[TASK_READ] = FALSE;

		call Spi.disable();
		call BusArbitration.releaseBus();

		return;
	}
	

	/**
	 * Fast Read flash block.
	 *
	 *
	 * \param address block address on flash
	 * \param buffer  pointer to buffer
	 * \param length  length of read buffer
	 *
	 * \return SUCCESS
	 * \return FAIL	bus not free or init failed
	 */
	uint32_t fastReadQueueAddress;
	uint8_t * fastReadQueueBuffer;
	uint16_t fastReadQueueLength;

	command result_t Flash.fastRead(uint32_t address, uint8_t *buffer, uint16_t length)
	{
		if (address > 0x07FFFF) return FAIL;

		if (!taskPosted[TASK_FAST_READ]) {
			taskPosted[TASK_FAST_READ] = TRUE;
			
			fastReadQueueAddress = address;
			fastReadQueueBuffer = buffer;
			fastReadQueueLength = length;

            /* if the queue is empty no task has been posted and the flash is off */
			if (queueEmpty()) {
				flashTaskPosted = TRUE;

                if (flashOn)
                {
                    post fastReadTask();
                } else
                {
                    post wakeupTask();
                    queuePutBack(TASK_FAST_READ);
                }
			} else
                queuePutBack(TASK_FAST_READ);

			return SUCCESS;
		} else {
			return FAIL;
		}

	}

	task void fastReadTask() {

		if (call BusArbitration.getBus() == FAIL) {
			queuePutFront(TASK_FAST_READ);
			return;
		}
		
		/***********************************************
		** select SPI bus and module 1 (micro4)
		***********************************************/
		call Spi.enable(BUS_CLOCK_INVERT + BUS_CLOCK_4MHZ, 1);

		/***********************************************
		** Fast read flash into buffer
		***********************************************/
		call HPLFlash.fastRead(fastReadQueueAddress, fastReadQueueBuffer, fastReadQueueLength);

		signal Flash.fastReadReady(fastReadQueueAddress, fastReadQueueBuffer, fastReadQueueLength);

		flashTaskPosted = FALSE;
		taskPosted[TASK_FAST_READ] = FALSE;

		call Spi.disable();
		call BusArbitration.releaseBus();

		return;
	}
	

	/**********************************************************************
	 * Flash write
	 *********************************************************************/
	/**
	 * Write flash page. Page size is 256 bytes.
	 * Write address must point at start of page.
	 *
	 * \param address block address on flash
	 * \param buffer  pointer to buffer
	 * \param length  length of read buffer
	 *
	 * \return SUCCESS
	 * \return FAIL		bus not free or buffer too long
	 */
	uint32_t writeQueueAddress;
	uint8_t * writeQueueBuffer;
	uint16_t writeQueueLength;

	command result_t Flash.write(uint32_t address, uint8_t *buffer, uint16_t length)
	{
		if (address > 0x07FFFF) return FAIL;
		if ((length > 256) || (length == 0)) return FAIL;

		if (!taskPosted[TASK_WRITE]) {
			taskPosted[TASK_WRITE] = TRUE;
			
			writeQueueAddress = address;
			writeQueueBuffer = buffer;
			writeQueueLength = length;

            /* if the queue is empty no task has been posted and the flash is off */
			if (queueEmpty()) {
				flashTaskPosted = TRUE;

                if (flashOn)
                {
                    post writeTask();
                } else
                {
                    post wakeupTask();
                    queuePutBack(TASK_WRITE);
                }
			} else
                queuePutBack(TASK_WRITE);

			return SUCCESS;
		} else {
			return FAIL;
		}
	}

	task void writeTask() {

		if (call BusArbitration.getBus() == FAIL) {
			queuePutFront(TASK_WRITE);
			return;
		}
		
		/***********************************************
		** select SPI bus and module 1 (micro4)
		***********************************************/
		call Spi.enable(BUS_CLOCK_INVERT + BUS_CLOCK_4MHZ, 1);

		/***********************************************
		** Write buffer to page, starting at address
		***********************************************/
		call HPLFlash.write(writeQueueAddress, writeQueueBuffer, writeQueueLength);

		/* set timer to post checkBusyTask (signalTask) */
		call Timer.start(TIMER_ONE_SHOT, 20);
		timerActive = TRUE;
		currentTask = TASK_WRITE;

		taskPosted[TASK_WRITE] = FALSE;

		call Spi.disable();
		call BusArbitration.releaseBus();

		return;
	}



	/**********************************************************************
	 * Flash erase
	 *********************************************************************/
	/**
	 * Flash sector erase. Sector size is 64 kilobytes.
	 * Address must point at start of sector.
	 *
	 * \param address block address on flash
	 *
	 * \return SUCCESS
	 * \return FAIL		bus not free 
	 */
	uint32_t sectorEraseQueueAddress;

	command result_t Flash.sectorErase(uint32_t address)
	{
		if (address > 0x07FFFF) return FAIL;

		if (!taskPosted[TASK_SECTOR_ERASE]) {
			taskPosted[TASK_SECTOR_ERASE] = TRUE;
			
			sectorEraseQueueAddress = address;

            /* if the queue is empty no task has been posted and the flash is off */
			if (queueEmpty()) {
				flashTaskPosted = TRUE;
                
                if (flashOn)
                {
                    post sectorEraseTask();
                } else
                {
                    post wakeupTask();
                    queuePutBack(TASK_SECTOR_ERASE);
                }
			} else
                queuePutBack(TASK_SECTOR_ERASE);

			return SUCCESS;
		} else {
			return FAIL;
		}

	}
		
	task void sectorEraseTask() {

		if (call BusArbitration.getBus() == FAIL) {
			queuePutFront(TASK_SECTOR_ERASE);
			return;
		}
		
		/***********************************************
		** select SPI bus and module 1 (micro4)
		***********************************************/
		call Spi.enable(BUS_CLOCK_INVERT + BUS_CLOCK_4MHZ, 1);
		
		/***********************************************
		** Erase sector holding address
		***********************************************/
		call HPLFlash.sectorErase(sectorEraseQueueAddress);

		/* set timer to post checkBusyTask (signalTask) */
		call Timer.start(TIMER_ONE_SHOT, 1000);
		timerActive = TRUE;
		currentTask = TASK_SECTOR_ERASE;

		taskPosted[TASK_SECTOR_ERASE] = FALSE;

		call Spi.disable();
		call BusArbitration.releaseBus();

		return;
	}

	/**
	 * Flash bulk erase. 
	 * Erases entire flash
	 *
	 * \return SUCCESS
	 * \return FAIL	bus not free 
	 */
	command result_t Flash.bulkErase()
	{
		if (!taskPosted[TASK_BULK_ERASE]) {
			taskPosted[TASK_BULK_ERASE] = TRUE;
			
            /* if the queue is empty no task has been posted and the flash is off */
			if (queueEmpty()) {
				flashTaskPosted = TRUE;

                if (flashOn)
                {
                    post bulkEraseTask();
                } else
                {
    				post wakeupTask();
                    queuePutBack(TASK_BULK_ERASE);
                }
			} else
                queuePutBack(TASK_BULK_ERASE);

			return SUCCESS;
		} else {
			return FAIL;
		}
	}

	task void bulkEraseTask() {

		if (call BusArbitration.getBus() == FAIL) {
			queuePutFront(TASK_BULK_ERASE);
			return;
		}
		
		/***********************************************
		** select SPI bus and module 1 (micro4)
		***********************************************/
		call Spi.enable(BUS_CLOCK_INVERT + BUS_CLOCK_4MHZ, 1);

		/***********************************************
		** Bulk erase
		***********************************************/
		call HPLFlash.bulkErase();

		/* set timer to post checkBusyTask (signalTask) */
		call Timer.start(TIMER_ONE_SHOT, 4500);
		timerActive = TRUE;
		currentTask = TASK_BULK_ERASE;

		taskPosted[TASK_BULK_ERASE] = FALSE;

		call Spi.disable();
		call BusArbitration.releaseBus();

		return;
	}


	/**********************************************************************
	 * Flash power management
	 *********************************************************************/
	/**
	 * Deep Power-down. 
	 *
	 * \return SUCCESS
	 * \return FAIL		bus not free
	 */
	command result_t Flash.sleep()
	{
		if (!taskPosted[TASK_SLEEP]) 
        {
			taskPosted[TASK_SLEEP] = TRUE;
			
            /* if the queue is empty no task has been posted and the flash is off */
 			if (queueEmpty()) 
            {
 				flashTaskPosted = TRUE;
                post sleepTask();
   			} else {
                queuePutBack(TASK_SLEEP);                    
            }

			return SUCCESS;
		} else {

			return FAIL;
		}

	}
	
	task void sleepTask() {

		if (call BusArbitration.getBus() == FAIL) {
			queuePutFront(TASK_SLEEP);
			return;
		}
		
		/***********************************************
		** select SPI bus and module 1 (micro4)
		***********************************************/
		call Spi.enable(BUS_CLOCK_INVERT + BUS_CLOCK_4MHZ, 1);

		/***********************************************
		** Send command to enter deep power-down
		***********************************************/
		call HPLFlash.sleep();
        
        call StdOut.print("sleep\r\n");

        flashOn = FALSE;
        flashTaskPosted = FALSE;
		taskPosted[TASK_SLEEP] = FALSE;

		call Spi.disable();
		call BusArbitration.releaseBus();

		return;
	}

	/**
	 * Flash signature read. Wakes the device up from power down mode.
	 * Signature value should be 0x12 if the flash is present and working.
	 *
	 * \return signature value
	 * \return -1	bus not free
	 */
	command result_t Flash.wakeUp()
	{

		if (!taskPosted[TASK_WAKEUP]) 
        {
			taskPosted[TASK_WAKEUP] = TRUE;
			
            /* if the queue is empty no task has been posted and the flash is off */
            if (queueEmpty()) 
            {
                flashTaskPosted = TRUE;
                post wakeupTask();
            } else {
                queuePutBack(TASK_WAKEUP);                    
            }
            
			return SUCCESS;
		} else {

			return FAIL;
		}
	}

	task void wakeupTask() {
		int16_t retval;

		if (call BusArbitration.getBus() == FAIL) {
			queuePutFront(TASK_WAKEUP);
			return;
		}
		
		/***********************************************
		** select SPI bus and module 1 (micro4)
		***********************************************/
		call Spi.enable(BUS_CLOCK_INVERT + BUS_CLOCK_4MHZ, 1);


		/***********************************************
		** Read signature
		***********************************************/
		retval = call HPLFlash.wakeUp();

		call StdOut.print("wakeup: ");
    	call StdOut.printHex(retval);
		call StdOut.print("\r\n");

		/* check if wakeup was successfull */
		if (retval != 0x12) {

			/* flash not ready - repost wakeup task */
			post wakeupTask();
		} else 
		{
			/* wakeup completed */
            flashOn = TRUE;
			flashTaskPosted = FALSE;
			taskPosted[TASK_WAKEUP] = FALSE;
		}

		call Spi.disable();
		call BusArbitration.releaseBus();

		return;
	}



	/**********************************************************************
	 * Checks if flash is writing
	 *********************************************************************/
	task void checkBusyTask() {

		if (call BusArbitration.getBus() == FAIL) {
			postCheckBusyTask = TRUE;
			return;
		}
		
		/***********************************************
		** select SPI bus and module 1 (micro4)
		***********************************************/
		call Spi.enable(BUS_CLOCK_INVERT + BUS_CLOCK_4MHZ, 1);


		/***********************************************
		** Checks if flash is writing
		***********************************************/
		if (call HPLFlash.isFree() == SUCCESS) {
			
			/* signal recent task */
			switch(currentTask) {
				case TASK_WRITE:

					signal Flash.writeDone(writeQueueAddress, writeQueueBuffer, writeQueueLength);
					break;

				case TASK_SECTOR_ERASE:

					signal Flash.sectorEraseDone(sectorEraseQueueAddress);
					break;

				case TASK_BULK_ERASE:

					signal Flash.bulkEraseDone();
					break;

				default:
					break;
			}

			currentTask = 0;
			
			/* post - if any - next task */
			flashTaskPosted = FALSE;
			timerActive = FALSE;
			postNextTask();

		} else {

			call Timer.start(TIMER_ONE_SHOT, FLASH_BUSY_BACKOFF);
		}

		call Spi.disable();
		call BusArbitration.releaseBus();

		return;
	}


	async event result_t StdOut.get(uint8_t data) {
		return SUCCESS;
	}
}
