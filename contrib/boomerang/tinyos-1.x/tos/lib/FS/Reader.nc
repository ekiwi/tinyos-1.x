// $Id: Reader.nc,v 1.1.1.1 2007/11/05 19:09:13 jpolastre Exp $

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
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
includes IFS;
module Reader {
  provides interface IFileRead[uint8_t fd];
  uses {
    interface IFileBlock;
    interface IFileBlockMeta;
    interface IFileBlockMeta as RemainingMeta;
    event void newBlock(fileblock_t block);
  }
#include "massert.h"
}
implementation {
  struct fileState {
    fileblock_t block, nextBlock;
    fileblockoffset_t lastOffset, offset;
    bool check;
  } fds[FS_NUM_RFDS];

  char *readto;
  uint8_t readfd;
  filesize_t readSize, requestedSize;

  command void IFileRead.open[uint8_t fd](fileblock_t firstBlock,
					  fileblockoffset_t skipBytes,
					  bool check) {
    fds[fd].block = firstBlock;
    fds[fd].offset = skipBytes;
    fds[fd].lastOffset = IFS_PAGE_SIZE + 1; // invalid value
    fds[fd].check = check;
  }

  default event void IFileRead.readDone[uint8_t id](filesize_t nRead, fileresult_t result) {
    assert(0);
  }

  void readComplete(fileresult_t result) {
    signal IFileRead.readDone[readfd](requestedSize - readSize, result);
  }

  void loadInfo() {
    call IFileBlockMeta.read(fds[readfd].block, fds[readfd].check);
  }

  void continueRead() {
    fileblockoffset_t count;

    // check if done
    if (readSize == 0)
      {
	readComplete(FS_OK);
	return;
      }

    // Read last byte used if unknown
    if (fds[readfd].lastOffset > IFS_PAGE_SIZE)
      {
	loadInfo();
	return;
      }

    if (readSize >= IFS_PAGE_SIZE ||
	readSize + fds[readfd].offset > fds[readfd].lastOffset)
      count = fds[readfd].lastOffset - fds[readfd].offset;
    else
      count = readSize;

    if (count > 0)
      {
	call IFileBlock.read(fds[readfd].block, fds[readfd].offset,
			     readto, count);
	fds[readfd].offset += count;
	readto += count;
	readSize -= count;
      }
    else if (fds[readfd].nextBlock == IFS_EOF_BLOCK ||
	     fds[readfd].lastOffset < IFS_PAGE_SIZE)
      readComplete(FS_OK);
    else
      {
	fds[readfd].block = fds[readfd].nextBlock;
	fds[readfd].offset = 0;
	loadInfo();
      }
  }

  event void IFileBlock.readDone(fileresult_t result) {
    if (result == FS_OK)
      continueRead();
    else
      readComplete(result);
  }

  event void IFileBlockMeta.readDone(fileblock_t nextBlock,
				     fileblockoffset_t lastByte,
				     fileresult_t result) {
    if (result == FS_OK)
      {
	signal newBlock(nextBlock);
	fds[readfd].nextBlock = nextBlock;
	fds[readfd].lastOffset = lastByte;
	continueRead();
      }
    else
      readComplete(result);
  }

  task void readCompleteTask() {
    readComplete(FS_OK);
  }

  command void IFileRead.read[uint8_t fd](void *buffer, filesize_t n) {
    readfd = fd;
    readto = buffer;
    requestedSize = readSize = n;

    if (requestedSize == 0)
      post readCompleteTask();
    else
      continueRead();
  }

  void seekComplete(fileresult_t result) {
    signal IFileRead.remaining[readfd](readSize - fds[readfd].offset, result);
  }

  void seekToEnd(fileblock_t nextBlock, fileblockoffset_t lastOffset) {
    readSize += lastOffset;
    if (nextBlock == IFS_EOF_BLOCK || lastOffset < IFS_PAGE_SIZE)
      seekComplete(FS_OK);
    else
      call RemainingMeta.read(nextBlock, FALSE);
  }

  event void RemainingMeta.readDone(fileblock_t nextBlock,
				    fileblockoffset_t lastByte,
				    fileresult_t result) {
    if (result == FS_OK)
      seekToEnd(nextBlock, lastByte);
    else
      seekComplete(result);
  }

  command void IFileRead.getRemaining[uint8_t fd]() {
    readfd = fd;
    readSize = 0;

    if (fds[fd].lastOffset > IFS_PAGE_SIZE)
      call RemainingMeta.read(fds[fd].block, FALSE);
    else
      seekToEnd(fds[fd].nextBlock, fds[fd].lastOffset);
  }

  event void IFileBlockMeta.writeDone(fileresult_t result) { 
    assert(0);
  }
  event void RemainingMeta.writeDone(fileresult_t result) { 
    assert(0);
  }
  event void IFileBlock.writeDone(fileresult_t result) {
    assert(0);
  }
  event void IFileBlock.syncDone(fileresult_t result) {
    assert(0);
  }
  event void IFileBlock.flushDone(fileresult_t result) {
    assert(0);
  }
  default event void IFileRead.remaining[uint8_t id](filesize_t n, fileresult_t result) {
    assert(0);
  }
}
