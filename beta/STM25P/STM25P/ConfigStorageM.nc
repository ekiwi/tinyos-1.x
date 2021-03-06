// $Id: ConfigStorageM.nc,v 1.1 2005/06/01 22:43:57 jwhui Exp $

/*									tab:2
 * "Copyright (c) 2000-2005 The Regents of the University  of California.  
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
 */

/*
 * @author: Jonathan Hui <jwhui@cs.berkeley.edu>
 */

module ConfigStorageM {
  provides {
    interface Mount[configstorage_t configId];
    interface ConfigRead[configstorage_t configId];
    interface ConfigWrite[configstorage_t configId];
  }
  uses {
    interface SectorStorage[configstorage_t configId];
    interface Leds;
    interface Mount as ActualMount[configstorage_t configId];
    interface StorageManager[configstorage_t configId];
  }
}


implementation {

  enum {
    NUM_CLIENTS = uniqueCount("StorageManager"),
  };

  enum {
    S_IDLE,
    S_MOUNT,
    S_OPEN,
    S_READ,
    S_CREATE,
    S_BEGIN_WRITE,
    S_WRITE_READY,
    S_WRITE,
    S_COPY_HEADER,
    S_COPY_WRITE,
    S_END_WRITE,
    S_SWAP_BUFS,
  };

  uint8_t state;
  bool swappingBufs;
  configstorage_t client;
  configstorage_t blockId;

  configstorage_t idMap[NUM_CLIENTS];
  config_header_t config_header;
  config_sector_header_t config_sector_header;
  uint8_t curSector;
  
  config_addr_t rwAddr, rwLen;
  void* rwBuf;

  stm25p_addr_t endAddr;
  config_addr_t nextWriteAddr;

  uint8_t copyBuf[1];

  void signalDone(storage_result_t result) {

    uint8_t tmpState = state;

    state = S_IDLE;

    switch(tmpState) {
    case S_OPEN: signal ConfigRead.openDone[client](result, rwBuf); break;
    case S_READ: signal ConfigRead.readDone[client](result, rwAddr, rwBuf, rwLen); break;
    case S_CREATE: signal ConfigWrite.createDone[client](result, rwBuf); break;
    case S_BEGIN_WRITE: 
      state = S_WRITE_READY;
      signal ConfigWrite.beginWriteDone[client](result, rwLen); break;
    case S_WRITE: 
      state = S_WRITE_READY;
      signal ConfigWrite.writeDone[client](result, rwAddr, rwBuf, rwLen); break;
    case S_END_WRITE: signal ConfigWrite.endWriteDone[client](result); break;
    }

  }

  task void signalDoneTask() {
    signalDone(STORAGE_OK);
  }

  command result_t Mount.mount[configstorage_t configId](volume_id_t id) {
    return call ActualMount.mount[configId](id);
  }
  
  stm25p_addr_t toAddr(stm25p_addr_t addr, uint8_t sector) {
    if (sector)
      addr += STM25P_SECTOR_SIZE;
    return addr;
  }
  
  event void ActualMount.mountDone[configstorage_t configId](storage_result_t result, volume_id_t id) {

    int16_t version1, version2;
    
    // find valid sector
    result = rcombine(call SectorStorage.read[configId](0, &version1, sizeof(version1)), result);
    result = rcombine(call SectorStorage.read[configId](STM25P_SECTOR_SIZE, &version2, sizeof(version2)), result);
    
    if (version2 == CONFIG_INVALID_VER)
      curSector = 0;
    else if (version1 == CONFIG_INVALID_VER)
      curSector = 1;
    else
      curSector = (version1 - version2) < 0;
    
    // find address of last block
    endAddr = toAddr(CONFIG_DATA_ADDR, curSector);
    config_header.size = 0;
    do {
      endAddr += config_header.size;
      if ( call SectorStorage.read[configId](endAddr, &config_header, sizeof(config_header_t)) == FAIL )
	signalDone( STORAGE_FAIL );
    } while ( config_header.id != CONFIG_INVALID_ID && endAddr < STM25P_SECTOR_SIZE );
    
    signal Mount.mountDone[configId](result, id);
    
  }
  
  /**
   * findConfigBlock
   *
   * Returns the address of the newest configuration block with id
   * configId. Must add sizeof(config_header_t) to get address of
   * data.
   */
  stm25p_addr_t findConfigBlock(configstorage_t configId) {
    
    stm25p_addr_t tmpAddr = toAddr(CONFIG_DATA_ADDR, curSector);
    stm25p_addr_t newestAddr = STM25P_INVALID_ADDR;
    config_header_t tmpHeader;
    
    do {
      if ( call SectorStorage.read[configId](tmpAddr, &tmpHeader, sizeof(config_header_t)) == FAIL )
	return FAIL;
      if ( tmpHeader.id == idMap[configId] ) {
	config_header = tmpHeader;
	newestAddr = tmpAddr;
      }
      tmpAddr += sizeof(config_header_t) + tmpHeader.size;
    } while ( ( tmpAddr % STM25P_SECTOR_SIZE ) < ( STM25P_SECTOR_SIZE - CONFIG_DATA_ADDR - sizeof(SectorTable) )
	      && tmpHeader.size
	      && tmpHeader.size != CONFIG_INVALID_SIZE );

    return newestAddr;
    
  }

  result_t open() {

    stm25p_addr_t tmpAddr = toAddr(sizeof(config_sector_header_t), curSector);
    config_entry_t tmpEntry;
    uint8_t i;
    
    // look for id that matches string
    for ( i = 0; i < CONFIG_MAX_ITEMS; i++, tmpAddr += sizeof(config_entry_t) ) {
      
      if ( call SectorStorage.read[client](tmpAddr, &tmpEntry, sizeof(config_entry_t)) == FAIL )
	return FAIL;
      
      // check if string matches
      if ( !strcmp(rwBuf, tmpEntry.name) ) {
	idMap[client] = tmpEntry.id;
	return SUCCESS;
      }
      
    }

    return FAIL;

  }
  
  command result_t ConfigRead.open[configstorage_t configId](char* name) {

    if ( state != S_IDLE )
      return FAIL;

    client = configId;
    rwBuf = name;
    
    if (open() == SUCCESS) {
      if (post signalDoneTask() == SUCCESS) {
	state = S_OPEN;
	return SUCCESS;
      }
    }

    return FAIL;

  }

  command result_t ConfigRead.read[configstorage_t configId](config_addr_t addr, void* buf, config_addr_t len) {

    stm25p_addr_t tmpAddr;

    if ( state != S_IDLE )
      return FAIL;

    // look for latest version of config block
    tmpAddr = findConfigBlock(configId);

    if (tmpAddr == STM25P_INVALID_ADDR)
      return FAIL;

    tmpAddr += addr + sizeof(config_header_t);

    // read data
    if ( call SectorStorage.read[configId](tmpAddr, buf, len) == SUCCESS ) {
      // post signal done task
      if (post signalDoneTask() == SUCCESS) {
	state = S_READ;
	client = configId;
	rwAddr = addr;
	rwBuf = buf;
	rwLen = len;
	return SUCCESS;
      }
    }

    return FAIL;

  }

  command result_t ConfigWrite.create[configstorage_t configId](char* name) {

    stm25p_addr_t tmpAddr = toAddr(sizeof(config_sector_header_t), curSector);
    config_entry_t tmpEntry;
    uint8_t i;

    if ( state != S_IDLE )
      return FAIL;

    // make sure strlen is correct
    if ( strlen(name) > CONFIG_MAX_STR_LEN )
      return FAIL;

    rwBuf = name;

    // check if name is already taken
    if ( open() == SUCCESS )
      return FAIL;

    for ( i = 0; i < CONFIG_MAX_ITEMS; i++, tmpAddr += sizeof(config_entry_t) ) {
      if ( call SectorStorage.read[configId](tmpAddr, &tmpEntry, sizeof(config_entry_t)) == FAIL )
	return FAIL;
      if ( tmpEntry.id == CONFIG_INVALID_ID )
	break;
    }

    // write new entry
    strcpy(tmpEntry.name, name);
    tmpEntry.id = i;
    if ( call SectorStorage.write[configId](tmpAddr, &tmpEntry, sizeof(config_entry_t)) == FAIL )
      return FAIL;

    state = S_CREATE;
    client = configId;
    rwBuf = name;

    return SUCCESS;
    
  }

  result_t copyData(stm25p_addr_t dst, stm25p_addr_t src) {

    if ( call SectorStorage.read[client](src, copyBuf, sizeof(copyBuf)) == FAIL )
      return FAIL;
    
    if ( call SectorStorage.write[client](dst, copyBuf, sizeof(copyBuf)) == FAIL )
      return FAIL;

    return SUCCESS;

  }

  result_t copyConfigBlock() {

    stm25p_addr_t tmpAddr = findConfigBlock(blockId);
    
    result_t result = copyData(	endAddr + nextWriteAddr + sizeof(config_header_t),
				tmpAddr + nextWriteAddr + sizeof(config_header_t) );

    if ( result == SUCCESS) 
      state = S_COPY_WRITE;

    return result;

  }

  result_t initHeader(config_addr_t newLen) {
    
    // do not give an id until a writeDone occurs
    config_header.id = CONFIG_INVALID_ID;
    config_header.size = newLen;
    nextWriteAddr = 0;
    if ( call SectorStorage.write[client](endAddr, &config_header, sizeof(config_header_t)) == SUCCESS ) {
      state = S_BEGIN_WRITE;
      return SUCCESS;
    }
    
    return FAIL;

  }

  result_t swapBuffers() {
    
    // find next block to copy over
    for ( ; rwAddr < CONFIG_MAX_ITEMS; rwAddr++ ) {
      if ( findConfigBlock(rwAddr) != STM25P_INVALID_ADDR
	   && rwAddr != idMap[client] ) {
	nextWriteAddr = 0;
	break;
      }
    }

    // check if all done
    if ( rwAddr == CONFIG_MAX_ITEMS ) {
      config_header.size = rwLen;
      rwAddr = idMap[client];
    }
    
    blockId = rwAddr;
    
    return initHeader(config_header.size);
    
  }
  
  command result_t ConfigWrite.beginWrite[configstorage_t configId](config_addr_t newLen) {
    
    stm25p_addr_t tmpAddr = toAddr(sizeof(config_sector_header_t), curSector);
    stm25p_addr_t totalSize;
    uint8_t i;

    if ( state != S_IDLE )
      return FAIL;

    // compute length of all config blocks
    for ( i = 0, totalSize = 0; i < CONFIG_MAX_ITEMS; i++, tmpAddr += sizeof(config_entry_t) ) {
      if ( findConfigBlock(i) != STM25P_INVALID_ADDR )
	totalSize += config_header.size + sizeof(config_header_t);
    }
    
    // make sure new length fits
    if ( totalSize > CONFIG_MAX_SIZE )
      return FAIL;

    client = configId;
    rwLen = newLen;

    // check if need to swap buffers
    tmpAddr = endAddr % STM25P_SECTOR_SIZE;
    if ( tmpAddr + sizeof(config_header_t) + newLen > CONFIG_MAX_SIZE ) {
      return call SectorStorage.erase[configId](toAddr(0, !curSector), 1);
    }
    else {
      blockId = idMap[configId];
      return initHeader(newLen);
    }

  }

  result_t writeData() {
    if ( call SectorStorage.write[client](endAddr + nextWriteAddr + sizeof(config_header_t), 
					  rwBuf, rwLen) == FAIL )
      return FAIL;
    state = S_WRITE;
    nextWriteAddr += rwLen;
    return SUCCESS;
  }

  command result_t ConfigWrite.write[configstorage_t configId](config_addr_t addr, void* buf, config_addr_t len) {

    result_t result;

    if ( state != S_WRITE_READY )
      return FAIL;
    
    // make sure length is not too big and address is not already written
    if ( addr + len > config_header.size || addr < nextWriteAddr )
      return FAIL;

    rwAddr = addr;
    rwBuf = buf;
    rwLen = len;

    if ( nextWriteAddr < addr )
      result = copyConfigBlock();
    else
      result = writeData();

    return result;

  }

  result_t validateBlock() {
    config_header.id = idMap[client];
    if ( call SectorStorage.write[client](endAddr, &config_header, sizeof(config_header_t))
	 == FAIL )
      return FAIL;
    state = S_END_WRITE;
    return SUCCESS;
  }

  command result_t ConfigWrite.endWrite[configstorage_t configId]() {

    result_t result;

    if ( state != S_WRITE_READY )
      return FAIL;

    // commit block
    if ( nextWriteAddr < config_header.size ) {
      rwAddr = config_header.size;
      rwBuf = NULL;
      result = copyConfigBlock();
    }
    else {
      result = validateBlock();
    }

    if (result == SUCCESS)
      client = configId;

    return result;

  }

  event void SectorStorage.writeDone[configstorage_t configId](storage_result_t result) {

    if (state == S_BEGIN_WRITE) {
      if ( swappingBufs && rwAddr != idMap[client] ) {
	nextWriteAddr++;
	if ( nextWriteAddr < config_header.size )
	  copyConfigBlock();
	else {
	  endAddr += sizeof(config_header_t) + config_header.size;
	  swapBuffers();
	}
	return;
      }
    }
    else if (state == S_COPY_HEADER) {
      rwAddr++;
      endAddr++;
      if ( ( rwAddr % STM25P_SECTOR_SIZE ) < CONFIG_DATA_ADDR ) {
	result = copyData( endAddr, rwAddr );
      }
      else {
	rwAddr = 0;
	endAddr = toAddr(CONFIG_DATA_ADDR, !curSector);
	result = swapBuffers();
      }
      if ( result == FAIL )
	signalDone(STORAGE_FAIL);
      return;
    }
    else if (state == S_COPY_WRITE) {
      nextWriteAddr++;
      
      if ( nextWriteAddr < rwAddr )
	result = copyConfigBlock();
      else if ( rwBuf == NULL )
	result = validateBlock();
      else
	result = writeData();

      if ( result == FAIL )
	signalDone( STORAGE_FAIL );
      return;
    }
    else if (state == S_END_WRITE) {
      endAddr += sizeof(config_header_t) + config_header.size;
      // if swapping bufs, write new version number
      if ( swappingBufs ) {
	if ( call SectorStorage.read[client](toAddr(0, curSector), &config_sector_header, 
					     sizeof(config_sector_header_t)) == FAIL )
	  signalDone(STORAGE_FAIL);
	config_sector_header.ver++;
	if ( call SectorStorage.write[client](toAddr(0, !curSector), &config_sector_header, 
					      sizeof(config_sector_header_t)) == FAIL )
	  signalDone(STORAGE_FAIL);
	state = S_SWAP_BUFS;
	return;
      }
    }
    else if (state == S_SWAP_BUFS) {
      curSector = !curSector;
      swappingBufs = FALSE;
      state = S_END_WRITE;
    }

    signalDone(result);

  }

  event void SectorStorage.eraseDone[configstorage_t configId](storage_result_t result) {
    swappingBufs = TRUE;
    
    // start copying header entries
    endAddr = toAddr(sizeof(config_sector_header_t), !curSector);
    rwAddr = toAddr(sizeof(config_sector_header_t), curSector);
    state = S_COPY_HEADER;
    if ( copyData( endAddr, rwAddr ) == FAIL )
      signalDone(STORAGE_FAIL);
  }

  default event void ConfigRead.openDone[configstorage_t configId](storage_result_t result, char* name) {}
  default event void ConfigRead.readDone[configstorage_t configId](storage_result_t result, config_addr_t addr, void* data, config_addr_t len) {}
  default event void ConfigWrite.createDone[configstorage_t configId](storage_result_t result, char* name) {}
  default event void ConfigWrite.beginWriteDone[configstorage_t configId](storage_result_t result, config_addr_t len) {}
  default event void ConfigWrite.writeDone[configstorage_t configId](storage_result_t result, config_addr_t addr, void* data, config_addr_t len) {}
  default event void ConfigWrite.endWriteDone[configstorage_t configId](storage_result_t result) {}
  default event void Mount.mountDone[configstorage_t configId](storage_result_t result, volume_id_t id) {}

}
