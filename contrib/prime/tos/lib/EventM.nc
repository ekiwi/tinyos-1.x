/*									tab:4
 *  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.  By
 *  downloading, copying, installing or using the software you agree to
 *  this license.  If you do not agree to this license, do not download,
 *  install, copy or use the software.
 *
 *  Intel Open Source License 
 *
 *  Copyright (c) 2002 Intel Corporation 
 *  All rights reserved. 
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 * 
 *	Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 *	Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 *      Neither the name of the Intel Corporation nor the names of its
 *  contributors may be used to endorse or promote products derived from
 *  this software without specific prior written permission.
 *  
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 *  PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE INTEL OR ITS
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * 
 */
/* 
 * Authors:  Wei Hong
 *           Intel Research Berkeley Lab
 * Date:     9/24/2002
 *
 */

module EventM
{
	provides
	{
		interface StdControl;
		interface EventRegister;
		interface EventUse;
	}
	uses 
	{
		interface CommandUse;
		interface Leds;
	}
}
implementation 
{
	EventDescs		eventDescs;
	bool			addEventPending;
	bool			eventMsgPending;
	EventDesc		*currentEventDesc;
	ParamVals		*currentParams;
	short			nextCmdIdx;
	bool			currentCmdDone;
	EventQueue		eventQueue;
	char			resultBuf[20];  // XXX an arbitrary size

	static void
	eventQueueInit()
	{
		eventQueue.head = 0;
		eventQueue.tail = 0;
		eventQueue.size = 0;
		eventQueue.inuse = FALSE;
	}

	static result_t
	eventEnqueue(EventDescPtr eventDesc, ParamVals *params)
	{
		if (eventQueue.size == MAX_EVENT_QUEUE_LEN)
			return FAIL;
		if (eventQueue.inuse)
			return FAIL;
		eventQueue.inuse = TRUE;
		eventQueue.events[eventQueue.tail].eventDesc = eventDesc;
		eventQueue.events[eventQueue.tail].eventParams = params;
		eventQueue.size++;
		if (eventQueue.tail == MAX_EVENT_QUEUE_LEN - 1)
			eventQueue.tail = 0;
		else
			eventQueue.tail++;
		eventQueue.inuse = FALSE;
		return SUCCESS;
	}

	static result_t
	eventDequeue(EventDescPtr *eventDesc, ParamVals **params)
	{
		if (eventQueue.size == 0)
		{
			return FAIL;
		}
		eventQueue.inuse = TRUE;
		*eventDesc = eventQueue.events[eventQueue.head].eventDesc;
		*params = eventQueue.events[eventQueue.head].eventParams;
		eventQueue.size--;
		if (eventQueue.head == MAX_EVENT_QUEUE_LEN - 1)
			eventQueue.head = 0;
		else
			eventQueue.head++;
		eventQueue.inuse = FALSE;
		return SUCCESS;
	}

	command result_t StdControl.init()
	{
		eventDescs.numEvents = 0;
		addEventPending = FALSE;
		eventMsgPending = FALSE;
		currentEventDesc = NULL;
		nextCmdIdx = 0;
		currentCmdDone = TRUE;
		eventQueueInit();

		return SUCCESS;
	}

	command result_t StdControl.start()
	{
		return SUCCESS;
	}

	command result_t StdControl.stop()
	{
		return SUCCESS;
	}

/* Return a pointer to the  descriptor for the specified event,
   or NULL if the command does not exist
*/
	command EventDescPtr EventUse.getEvent(char *name)
	{
		// read numEvents into local variable to reduce window of race condition
		short numEvents = eventDescs.numEvents;
		short i;
		for (i = 0; i < numEvents; i++)
		{
			if (!eventDescs.eventDesc[i].deleted &&
				strcasecmp(eventDescs.eventDesc[i].name, name) == 0)
				return &eventDescs.eventDesc[i];
		}
		return NULL;
	}

/* Return a pointer to the descriptor for the specified event index,
   or NULL if the index is not valid
*/
	command EventDescPtr EventUse.getEventById(uint8_t id) 
	{
		short numEvents = eventDescs.numEvents;
		if (id >= numEvents || eventDescs.eventDesc[id].deleted)
			return NULL;
		return &eventDescs.eventDesc[(int)id];
	}

	command EventDescsPtr EventUse.getEvents()
	{
		return &eventDescs;
	}

	command uint8_t EventUse.numEvents()
	{
		return eventDescs.numEvents;
	}

	task void signalEventTask()
	{
		EventDescPtr eventDesc;
		ParamVals *params;
		SchemaErrorNo errNo;
		if (currentEventDesc != NULL && currentCmdDone)
		{
			char *name = currentEventDesc->name;
			if (call CommandUse.invokeById(
					currentEventDesc->cmds[nextCmdIdx], 
					resultBuf, &errNo, currentParams) != SUCCESS ||
				errNo == SCHEMA_ERROR)
			{
				currentEventDesc = NULL;
				signal EventUse.eventDone(name, SCHEMA_ERROR);
			}
			else
			{
				if (errNo == SCHEMA_RESULT_PENDING)
					currentCmdDone = FALSE;
				else
				{
					if (++nextCmdIdx >= currentEventDesc->numCmds)
					{
						currentEventDesc = NULL;
						signal EventUse.eventDone(name, SCHEMA_SUCCESS);
					}
				}
			}
		}
		if (currentEventDesc == NULL)
		{
			if (eventDequeue(&eventDesc, &params) == FAIL)
			{
				return;
			}
			currentEventDesc = eventDesc;
			currentParams = params;
			currentCmdDone = TRUE;
			nextCmdIdx = 0;
		}
		post signalEventTask();
	}

	/* 
		signal an event.  All the commands associated with the event will be
		called sequentially in a task.  the eventDone event will be signaled
		when all commands are completed.
	*/
	command result_t EventUse.signalEvent(char *eventName,
											ParamVals *params)
	{
		EventDescPtr eventDesc = call EventUse.getEvent(eventName);
		if (eventDesc == NULL || eventDesc->params.numParams != params->numParams)
		{
			return FAIL;
		}
		if (eventEnqueue(eventDesc, params) == FAIL)
			return FAIL;
		return post signalEventTask();
	}

	/* parse event signal message, then signal the event */
	command result_t EventUse.signalEventMsg(TOS_MsgPtr msg)
	{
		char *eventName;
		char *ptr;
		uint16_t nodeid;
		TOS_Msg msgCopy;
		struct CommandMsg *cmsg;

		EventDescPtr eventDesc;
		if (eventMsgPending)
			return FAIL;
		eventMsgPending = TRUE;
		msgCopy = *msg;
		cmsg = (struct CommandMsg *)msgCopy.data;

		nodeid = cmsg->nodeid;
		if (nodeid == TOS_BCAST_ADDR || nodeid == TOS_LOCAL_ADDRESS)
		{
			short i;
			ParamVals paramVals;
			ptr = (char *)&cmsg->data[0];
			eventName = ptr;
			eventDesc = call EventUse.getEvent(eventName);
			for (i = 0, ptr += strlen(eventName) + 1; i < eventDesc->params.numParams; i++)
			{
				paramVals.paramDataPtr[i] = ptr;
				ptr += lengthOf(eventDesc->params.params[i], ptr);
			}
			paramVals.numParams = eventDesc->params.numParams;
			eventMsgPending = FALSE;
			return call EventUse.signalEvent(eventName, &paramVals);
		}
		eventMsgPending = FALSE;
		return SUCCESS;
	}

	// associate a command to an event as a callback
	command result_t EventUse.registerEventCallback(char *eventName, char *cmdName)
	{
		EventDesc *eventDesc;
		CommandDesc *cmdDesc;
		short i;
		eventDesc = call EventUse.getEvent(eventName);
		if (eventDesc == NULL || eventDesc->numCmds >= MAX_CMD_PER_EVENT)
			return FAIL;
		cmdDesc = call CommandUse.getCommand(cmdName);
		if (cmdDesc == NULL)
			return FAIL;
		// make sure the event and the command have identical
		// parameter signature
		if (eventDesc->params.numParams != cmdDesc->params.numParams)
			return FAIL;
		for (i = 0; i < eventDesc->params.numParams; i++)
		{
			if (eventDesc->params.params[i] != cmdDesc->params.params[i])
				return FAIL;
		}
		eventDesc->cmds[eventDesc->numCmds++] = cmdDesc->idx;
		return SUCCESS;
	}

	// delete a command from an event's callback list
	command result_t EventUse.deleteEventCallback(char *eventName, char *cmdName)
	{
		EventDesc *eventDesc;
		CommandDesc *cmdDesc;
		short cmd, i;
		eventDesc = call EventUse.getEvent(eventName);
		if (eventDesc == NULL)
			return FAIL;
		cmdDesc = call CommandUse.getCommand(cmdName);
		if (cmdDesc == NULL)
			return FAIL;
		for (cmd = 0; cmd < eventDesc->numCmds; cmd++)
			if (eventDesc->cmds[cmd] == cmdDesc->idx)
				break;
		if (cmd >= eventDesc->numCmds)
			return FAIL;
		// compact the callback array
		for (i = cmd + 1; i < eventDesc->numCmds; i++)
			eventDesc->cmds[i-1] = eventDesc->cmds[i];
		eventDesc->numCmds--;
		return SUCCESS;
	}

	/* Add a new event to the schema with the specified parameters */
	command result_t EventRegister.registerEvent(char *eventName, ParamList *params)
	{
		short eventIdx;
		bool eventExists = FALSE;
		EventDesc *eventDesc = NULL;
		if (params->numParams > MAX_PARAMS)
			return FAIL;
		if (addEventPending || strlen(eventName) > MAX_EVENT_NAME_LEN)
			return FAIL;
		else
			addEventPending = TRUE;
		// replace event definition if one with same name exists
		for (eventIdx = 0; eventIdx < eventDescs.numEvents; eventIdx++)
		{
			if (eventDescs.eventDesc[eventIdx].deleted)
				eventDesc = &eventDescs.eventDesc[eventIdx];
			else if (strcasecmp(eventDescs.eventDesc[eventIdx].name, eventName) == 0)
			{
				eventExists = TRUE;
				break;
			}
		}
		if (!eventExists)
		{
			if (eventDescs.numEvents < MAX_EVENTS)
				eventDescs.numEvents++;
			else
			{
				addEventPending = FALSE;
				return FAIL;
			}
		}
		if (eventDesc == NULL)
			eventDesc = &eventDescs.eventDesc[eventIdx];
		eventDesc->idx = eventIdx;
		strcpy(eventDesc->name, eventName);
		eventDesc->numCmds = 0;
		eventDesc->deleted = FALSE;
		eventDesc->params = *params;
		addEventPending = FALSE;
		return SUCCESS;
	}

	command result_t EventRegister.deleteEvent(char *name)
	{
		short numEvents = eventDescs.numEvents;
		short i;
		for (i = 0; i < numEvents; i++)
		{
			if (!eventDescs.eventDesc[i].deleted &&
				strcasecmp(eventDescs.eventDesc[i].name, name) == 0)
			{
				eventDescs.eventDesc[i].deleted = TRUE;
				return SUCCESS;
			}
		}
		return FAIL;
	}

	event result_t CommandUse.commandDone(char *commandName, char *resBuf, SchemaErrorNo errorNo)
	{
	  char *name;
		
	  if (currentCmdDone == TRUE || currentEventDesc == NULL)
	    return SUCCESS; //not for us
		
		name = currentEventDesc->name;
		if (errorNo == SCHEMA_ERROR)
		{
			currentEventDesc = NULL;
			currentCmdDone = TRUE;
			signal EventUse.eventDone(name, SCHEMA_ERROR);
		}
		else
		{
			currentCmdDone = TRUE;
			if (++nextCmdIdx >= currentEventDesc->numCmds)
			{
				currentEventDesc = NULL;
				signal EventUse.eventDone(name, SCHEMA_SUCCESS);
			}
		}
		return SUCCESS;
	}
}
