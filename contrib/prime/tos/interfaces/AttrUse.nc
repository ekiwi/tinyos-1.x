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
 * Date:     6/27/2002
 *
 */

includes SchemaType;
includes Attr;

/** Interface for using Attributes.  Attributes provided a generic mechanism for 
	registering named attribute-value pairs and retrieving their values.
    <p>
    See lib/Attributes/... for examples of components that register attributes
    <p>
    See interfaces/Attr.h for the data structures used in this interface 
    <p>
    Implemented by lib/Attr.td
    <p>
    @author Wei Hong (wei.hong@intel-research.net)
*/

interface AttrUse
{
  /** Get a descriptor for the specified attribute
      @param name The (8 byte or shorted, null-terminated) name for the attribute of interest.
      @return A pointer to the attribute descriptior, or NULL if no such attribute exists.
  */
  command AttrDescPtr getAttr(char *name);

  /** Get a descriptor for the specified attribute
      @param attrIdx THe (0-based) index of the attribute of interest
      @return A pointer to the attribute descriptior, or NULL if no such attribute exists.
  */
  command AttrDescPtr getAttrById(uint8_t attrIdx);

  /** Get the number of attributes currently registered with the system
      @return The number of attributes currently registered with the system. 
  */	
  command uint8_t numAttrs();

  /** Returns a list of all attributes in the system.
      @return A list of all the attributes in the system 
  */
  command AttrDescsPtr getAttrs();

  /** Get the value of a specified attribute.
      @param name The name of the attribute to fetch
      @param resultBuf The buffer to write the value into (must be at least sizeOf(AttrDescPtr.type) long)
      @param errorNo (on return) The error code, if any (see SchemaType.h for a list of error codes.) Note that
             the error code may be SCHEMA_RESULT_PENDING, in which case a getAttrDone event will be fired
	     at some point to indicate that the data has been written into resultBuf.
  */	     
  command result_t getAttrValue(char *name, char *resultBuf, SchemaErrorNo *errorNo);

  /** Set the value of the specified attribute.
      @param name The attribute to set
      @param attrVal The value to set it to
  */
  command result_t setAttrValue(char *name, char *attrVal);

  /** Signal that a specific getAttrValue command is complete.
      @param name The name of the command that finished
      @param resultBuf The buffer that the value was written into
      @param errorNo The result code from the get command
  */
  event result_t getAttrDone(char *name, char *resultBuf, SchemaErrorNo errorNo);
}
