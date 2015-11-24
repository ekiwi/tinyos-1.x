// $Id: BlockCipherMode.nc,v 1.1.1.1 2007/11/05 19:09:02 jpolastre Exp $

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

/* Authors: Naveen Sastry
 * Date:    10/7/02
 */

/**
 * Presents an encryption mode interface on type of the BlockCipher interface.
 * Typical modes include CBC, OFB, BC.
 *
 * In general, this interface should be used for encryption over the
 * BlockCipher interface since encrypting the same data (using different IV's)
 * using any of the above modes will produce different ciphertexts.
 * @author Naveen Sastry
 */

includes crypto;
interface BlockCipherMode
{
  /**
   * Initialize the BlockCipherMode.  It uses the underlying BlockCipher's
   * preferred block cipher mode, and passes the key and keySize parameters
   * to the underlying BlockCipher.
   *
   * @param context structure to hold the opaque data from this initialization
   *        call. It should be passed to future invocations of this module
   *        which use this particular key. It also contains the opaque
   *        context for the underlying BlockCipher as well.
   * @param keySize key size in bytes
   * @param key pointer to the key
   * @return Whether initialization was successful. The command may be
   *         unsuccessful if the key size is not valid for the given cipher
   *         implementation. It can also fail if the preferred block size of
   *         the cipher does not agree with the preferred size of the mode.
   */
  command result_t init(CipherModeContext * context, 
                        uint8_t keySize, uint8_t * key);

  /**
   * Encrypts numBytes of plainText data using the key from the init phase.
   * There must be at least blockSize bytes.  Some encryption modes require
   * that the plainText size be a multiple of blockSize; using these modes
   * with a plainText array which is not a blockSize will result in a failure
   * return code. The IV is a pointer to the initialization vector (of size
   * equal to the blockSize) which is used to initialize the encryption.
   *
   * @param context holds the module specific opaque data related to the
   *        key (perhaps key expansions) and other internal state
   * @param plainText an array of at least blockSize bytes.  
   * @param cipherText an array of equal size to the plainText which will hold
   *        the results of the encryption; may be the plainText array.
   * @param numBytes number of data bytes to encrypt.
   * @param IV an array of the initialization vector. It should be of
   *        blockSize bytes
   * @return Whether the encryption was successful. Possible failure reasons
   *        include not calling init() or an incorrectly sized plain-text
   *        array.
   */
  async command result_t encrypt(CipherModeContext * context,
				 uint8_t * plainText, uint8_t * cipherText,
				 uint16_t numBytes, uint8_t * IV);

  /**
   * Decrypts numBytes of plainText data using the key from the init phase.
   * There must be at least blockSize bytes.  Some encryption modes require
   * that the plainText size be a multiple of blockSize; using these modes
   * with a plainText array which is not a blockSize will result in a failure
   * return code. The IV is a pointer to the initialization vector (of size
   * equal to the blockSize) which is used to initialize the encryption.
   *
   * @param context holds the module specific opaque data related to the
   *        key (perhaps key expansions) and other internal state.
   * @param cipherText an array of at lest blockSize bytes which contains
   *        encrypted data using the key from the init phase.
   * @param plainText an array of equal size to the cipherText which will hold
   *        the results of the decryption. may be the cipherText array.
   * @param numBytes number of data bytes to decrypt.
   * @param IV an array of the initialization vector. It should be of
   *        blockSize bytes
   * @return Whether the decryption was successful. Possible failure reasons
   *        include not calling init() or an incorrectly sized cipher-text
   *        array.
   */
  async command result_t decrypt(CipherModeContext * context,
				 uint8_t * cipherBlock, uint8_t * plainBlock,
				 uint16_t numBytes, uint8_t * IV);

  /**
   * Initializes the mode for an incremental decryption operation. This step
   * is necessary for incremental decryption where the incoming data stream is
   * processed a byte at a time and cipher operations are done as soon as
   * possible. This is meant to allow for better overlapping of decryption
   * with a slower process that receives the encrypted stream (say via the
   * network ).
   *
   * This call may induce a block cipher call.
   
   * @param context holds the module specific opaque data related to the
   *        key (perhaps key expansions) and other internal state.
   * @param IV The initialization vector that was used to encrypt this
   *        particular data stream. This array must have a length equal to
   *        one block size.
   * @param The exact length of the data stream in bytes; this must be at
   *        least the underlying block cipher size.
   * @return Whether the initialization was successful. Possible failure
   *        reasons include not calling init() or an underlying failure in the
   *        block cipher.
   */
  async command result_t initIncrementalDecrypt (CipherModeContext * context,
						 uint8_t * IV,
						 uint16_t length);

  /**
   * Performs an incremental decryption operation. It executes roughly one
   * block cipher call for every block's worth of ciphertext provided, placing
   * the result into the plaintext buffer. The done out parameter gives an
   * indication of the amount of data that has been successfully been
   * decrypted.
   *
   * @param context holds the module specific opaque data related to the
   *        key (perhaps key expansions) and other internal state.
   * @param ciphertext Pointer to the start of the next ciphertext buffer.
   * @param plaintext Pointer to the start of the buffer which is large enough
   *        to hold the entire ciphertext. This buffer must be passed in every
   *        time to the incrementalDecrypt function.  After this call,
   *        <i>done</i> bytes of the plaintext buffer will be available for
   *        consumption. 
   * @param length The number of bytes that is being provided in the ciphertext
   * @param done A pointer to an int which will be filled in after the call
   *        completes with the number of bytes of plaintext which is
   *        available. 
   * @return Whether the call was successful or not. Possible failure reasons
   *        include not calling init(), an underlying failure in the block
   *        cipher, or providing more ciphertext than is expected.
   */
  async command result_t incrementalDecrypt (CipherModeContext * context,
					     uint8_t * ciphertext, 
					     uint8_t * plaintext,
					     uint16_t length,
					     uint16_t * done);
}
