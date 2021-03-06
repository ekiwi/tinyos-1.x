// $Id: FileWrite.nc,v 1.1 2006/10/11 00:11:09 lnachman Exp $

/*									tab:4
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
 * 
 * Ported to Imote2 by Junaith Ahemed
 */

includes BlockStorage;

interface FileWrite 
{
  /**
   * BlockWrite.write
   * 
   * Data from <I>buf</I> is written to a mounted file for given length <I>len</I>.
   * The logical starting address should be passed as the first parameter to the
   * function. addr + len should be less than the size of the file or the funtion will
   * return an error.
   *
   * @param addr Virtual address ranging from 0x0 to SIZE_OF_FILE
   * @param buf Buffer contaning data to be written to the file.
   * @param len Number of bytes to be written to the file.
   *  
   * @return SUCCESS | FAIL
   */
  command result_t write(block_addr_t addr, void* buf, block_addr_t len);

  /**
   * SectorStorage.writeDone
   *
   * Event generated by StorageManager module to notify that the
   * write request is completed.
   *
   * @param result STORAGE_OK | STORAGE_FAIL
   */  
  event void writeDone(storage_result_t result, block_addr_t addr, 
                       void* buf, block_addr_t len);

  /**
   * BlockWrite.erase
   *
   * The blocks allocated for the file will be erased and the write pointer will
   * be set to 0x0. This is useful if a file has to be reused with new data because
   * the current implementation does not allow the manipulation of already used
   * space in a file.
   * 
   * @return SUCCESS | FAIL
   */
  command result_t erase();

  /**
   * SectorStorage.eraseDone
   *
   * Event generated by StorageManager module to notify that the
   * erase request is completed.
   *
   * @param result STORAGE_OK | STORAGE_FAIL
   */  
  event void eraseDone(storage_result_t result);

  /**
   * BlockWrite.commit
   * 
   * NOT IMPLEMENTED. DOES NOT HAVE ANY EFFECT.
   * FIXME Should be removed.
   */  
  command result_t commit();
  event void commitDone(storage_result_t result);

  /**
   * BlockWrite.append
   *
   * Data from <I>buf</I> is appended to a mounted file for given length <I>len</I>.
   * Current write pointer will be used as the logical starting address. len + 
   * currWritePtr should be less than the size of the file or the funtion will
   * return an error.
   * The function performs the book keeping locally and changes the state to
   * S_WRITE.
   *
   * @param buf Buffer contaning data to be written to the file.
   * @param len Number of bytes to be written to the file.
   *  
   * @return SUCCESS | FAIL
   */  
  command result_t append(void* buf, block_addr_t len);

  /**
   * BlockWrite.getWritePtr
   *
   * The function returns the current write pointer for the mounted
   * file.
   *
   * @return WritePtr Current logical address for writing or Write Pointer.
   *
   * @return SUCCESS | FAIL
   */  
  command block_addr_t getWritePtr ();

  /**
   * BlockWrite.resetWritePtr
   *
   * The function will reset the write pointer to 0x0. This is essentially
   * same as erasing the file as resetting the write pointer will allow
   * write operation starting from 0x0, which in turn means that the 
   * blocks has to be prepared for writing new data.
   *
   * NOTE - The content of the file will be lost.
   *
   * @return SUCCESS | FAIL
   */  
  command result_t resetWritePtr ();
}
