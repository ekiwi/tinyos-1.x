/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'BlackbookFileMsg'
 * message type.
 */

package com.rincon.blackbook.messages;

public class BlackbookFileMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 5;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 189;

    /** Create a new BlackbookFileMsg of size 5. */
    public BlackbookFileMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new BlackbookFileMsg of the given data_length. */
    public BlackbookFileMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new BlackbookFileMsg with the given data_length
     * and base offset.
     */
    public BlackbookFileMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new BlackbookFileMsg using the given byte array
     * as backing store.
     */
    public BlackbookFileMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new BlackbookFileMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public BlackbookFileMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new BlackbookFileMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public BlackbookFileMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new BlackbookFileMsg embedded in the given message
     * at the given base offset.
     */
    public BlackbookFileMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new BlackbookFileMsg embedded in the given message
     * at the given base offset and length.
     */
    public BlackbookFileMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <BlackbookFileMsg> \n";
      try {
        s += "  [focusedFile.firstNode=0x"+Long.toHexString(get_focusedFile_firstNode())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [focusedFile.filenameCrc=0x"+Long.toHexString(get_focusedFile_filenameCrc())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [focusedFile.state=0x"+Long.toHexString(get_focusedFile_state())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: focusedFile.firstNode
    //   Field type: int
    //   Offset (bits): 0
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'focusedFile.firstNode' is signed (false).
     */
    public static boolean isSigned_focusedFile_firstNode() {
        return false;
    }

    /**
     * Return whether the field 'focusedFile.firstNode' is an array (false).
     */
    public static boolean isArray_focusedFile_firstNode() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'focusedFile.firstNode'
     */
    public static int offset_focusedFile_firstNode() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'focusedFile.firstNode'
     */
    public static int offsetBits_focusedFile_firstNode() {
        return 0;
    }

    /**
     * Return the value (as a int) of the field 'focusedFile.firstNode'
     */
    public int get_focusedFile_firstNode() {
        return (int)getUIntElement(offsetBits_focusedFile_firstNode(), 16);
    }

    /**
     * Set the value of the field 'focusedFile.firstNode'
     */
    public void set_focusedFile_firstNode(int value) {
        setUIntElement(offsetBits_focusedFile_firstNode(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'focusedFile.firstNode'
     */
    public static int size_focusedFile_firstNode() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'focusedFile.firstNode'
     */
    public static int sizeBits_focusedFile_firstNode() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: focusedFile.filenameCrc
    //   Field type: int
    //   Offset (bits): 16
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'focusedFile.filenameCrc' is signed (false).
     */
    public static boolean isSigned_focusedFile_filenameCrc() {
        return false;
    }

    /**
     * Return whether the field 'focusedFile.filenameCrc' is an array (false).
     */
    public static boolean isArray_focusedFile_filenameCrc() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'focusedFile.filenameCrc'
     */
    public static int offset_focusedFile_filenameCrc() {
        return (16 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'focusedFile.filenameCrc'
     */
    public static int offsetBits_focusedFile_filenameCrc() {
        return 16;
    }

    /**
     * Return the value (as a int) of the field 'focusedFile.filenameCrc'
     */
    public int get_focusedFile_filenameCrc() {
        return (int)getUIntElement(offsetBits_focusedFile_filenameCrc(), 16);
    }

    /**
     * Set the value of the field 'focusedFile.filenameCrc'
     */
    public void set_focusedFile_filenameCrc(int value) {
        setUIntElement(offsetBits_focusedFile_filenameCrc(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'focusedFile.filenameCrc'
     */
    public static int size_focusedFile_filenameCrc() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'focusedFile.filenameCrc'
     */
    public static int sizeBits_focusedFile_filenameCrc() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: focusedFile.state
    //   Field type: short
    //   Offset (bits): 32
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'focusedFile.state' is signed (false).
     */
    public static boolean isSigned_focusedFile_state() {
        return false;
    }

    /**
     * Return whether the field 'focusedFile.state' is an array (false).
     */
    public static boolean isArray_focusedFile_state() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'focusedFile.state'
     */
    public static int offset_focusedFile_state() {
        return (32 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'focusedFile.state'
     */
    public static int offsetBits_focusedFile_state() {
        return 32;
    }

    /**
     * Return the value (as a short) of the field 'focusedFile.state'
     */
    public short get_focusedFile_state() {
        return (short)getUIntElement(offsetBits_focusedFile_state(), 8);
    }

    /**
     * Set the value of the field 'focusedFile.state'
     */
    public void set_focusedFile_state(short value) {
        setUIntElement(offsetBits_focusedFile_state(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'focusedFile.state'
     */
    public static int size_focusedFile_state() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'focusedFile.state'
     */
    public static int sizeBits_focusedFile_state() {
        return 8;
    }

}
