package com.moteiv.demos.spram;
/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'SpramRequestMsg'
 * message type.
 */

public class SpramRequestMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 12;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 34;

    /** Create a new SpramRequestMsg of size 12. */
    public SpramRequestMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new SpramRequestMsg of the given data_length. */
    public SpramRequestMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new SpramRequestMsg with the given data_length
     * and base offset.
     */
    public SpramRequestMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new SpramRequestMsg using the given byte array
     * as backing store.
     */
    public SpramRequestMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new SpramRequestMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public SpramRequestMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new SpramRequestMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public SpramRequestMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new SpramRequestMsg embedded in the given message
     * at the given base offset.
     */
    public SpramRequestMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new SpramRequestMsg embedded in the given message
     * at the given base offset and length.
     */
    public SpramRequestMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <SpramRequestMsg> \n";
      try {
        s += "  [addrRequester=0x"+Long.toHexString(get_addrRequester())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [bytesBegin=0x"+Long.toHexString(get_bytesBegin())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [bytesEnd=0x"+Long.toHexString(get_bytesEnd())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [bytesTotal=0x"+Long.toHexString(get_bytesTotal())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [versionToken=0x"+Long.toHexString(get_versionToken())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [version=0x"+Long.toHexString(get_version())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [flags=0x"+Long.toHexString(get_flags())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: addrRequester
    //   Field type: int, unsigned
    //   Offset (bits): 0
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'addrRequester' is signed (false).
     */
    public static boolean isSigned_addrRequester() {
        return false;
    }

    /**
     * Return whether the field 'addrRequester' is an array (false).
     */
    public static boolean isArray_addrRequester() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'addrRequester'
     */
    public static int offset_addrRequester() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'addrRequester'
     */
    public static int offsetBits_addrRequester() {
        return 0;
    }

    /**
     * Return the value (as a int) of the field 'addrRequester'
     */
    public int get_addrRequester() {
        return (int)getUIntElement(offsetBits_addrRequester(), 16);
    }

    /**
     * Set the value of the field 'addrRequester'
     */
    public void set_addrRequester(int value) {
        setUIntElement(offsetBits_addrRequester(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'addrRequester'
     */
    public static int size_addrRequester() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'addrRequester'
     */
    public static int sizeBits_addrRequester() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: bytesBegin
    //   Field type: int, unsigned
    //   Offset (bits): 16
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'bytesBegin' is signed (false).
     */
    public static boolean isSigned_bytesBegin() {
        return false;
    }

    /**
     * Return whether the field 'bytesBegin' is an array (false).
     */
    public static boolean isArray_bytesBegin() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'bytesBegin'
     */
    public static int offset_bytesBegin() {
        return (16 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'bytesBegin'
     */
    public static int offsetBits_bytesBegin() {
        return 16;
    }

    /**
     * Return the value (as a int) of the field 'bytesBegin'
     */
    public int get_bytesBegin() {
        return (int)getUIntElement(offsetBits_bytesBegin(), 16);
    }

    /**
     * Set the value of the field 'bytesBegin'
     */
    public void set_bytesBegin(int value) {
        setUIntElement(offsetBits_bytesBegin(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'bytesBegin'
     */
    public static int size_bytesBegin() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'bytesBegin'
     */
    public static int sizeBits_bytesBegin() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: bytesEnd
    //   Field type: int, unsigned
    //   Offset (bits): 32
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'bytesEnd' is signed (false).
     */
    public static boolean isSigned_bytesEnd() {
        return false;
    }

    /**
     * Return whether the field 'bytesEnd' is an array (false).
     */
    public static boolean isArray_bytesEnd() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'bytesEnd'
     */
    public static int offset_bytesEnd() {
        return (32 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'bytesEnd'
     */
    public static int offsetBits_bytesEnd() {
        return 32;
    }

    /**
     * Return the value (as a int) of the field 'bytesEnd'
     */
    public int get_bytesEnd() {
        return (int)getUIntElement(offsetBits_bytesEnd(), 16);
    }

    /**
     * Set the value of the field 'bytesEnd'
     */
    public void set_bytesEnd(int value) {
        setUIntElement(offsetBits_bytesEnd(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'bytesEnd'
     */
    public static int size_bytesEnd() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'bytesEnd'
     */
    public static int sizeBits_bytesEnd() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: bytesTotal
    //   Field type: int, unsigned
    //   Offset (bits): 48
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'bytesTotal' is signed (false).
     */
    public static boolean isSigned_bytesTotal() {
        return false;
    }

    /**
     * Return whether the field 'bytesTotal' is an array (false).
     */
    public static boolean isArray_bytesTotal() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'bytesTotal'
     */
    public static int offset_bytesTotal() {
        return (48 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'bytesTotal'
     */
    public static int offsetBits_bytesTotal() {
        return 48;
    }

    /**
     * Return the value (as a int) of the field 'bytesTotal'
     */
    public int get_bytesTotal() {
        return (int)getUIntElement(offsetBits_bytesTotal(), 16);
    }

    /**
     * Set the value of the field 'bytesTotal'
     */
    public void set_bytesTotal(int value) {
        setUIntElement(offsetBits_bytesTotal(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'bytesTotal'
     */
    public static int size_bytesTotal() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'bytesTotal'
     */
    public static int sizeBits_bytesTotal() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: versionToken
    //   Field type: int, unsigned
    //   Offset (bits): 64
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'versionToken' is signed (false).
     */
    public static boolean isSigned_versionToken() {
        return false;
    }

    /**
     * Return whether the field 'versionToken' is an array (false).
     */
    public static boolean isArray_versionToken() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'versionToken'
     */
    public static int offset_versionToken() {
        return (64 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'versionToken'
     */
    public static int offsetBits_versionToken() {
        return 64;
    }

    /**
     * Return the value (as a int) of the field 'versionToken'
     */
    public int get_versionToken() {
        return (int)getUIntElement(offsetBits_versionToken(), 16);
    }

    /**
     * Set the value of the field 'versionToken'
     */
    public void set_versionToken(int value) {
        setUIntElement(offsetBits_versionToken(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'versionToken'
     */
    public static int size_versionToken() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'versionToken'
     */
    public static int sizeBits_versionToken() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: version
    //   Field type: short, unsigned
    //   Offset (bits): 80
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'version' is signed (false).
     */
    public static boolean isSigned_version() {
        return false;
    }

    /**
     * Return whether the field 'version' is an array (false).
     */
    public static boolean isArray_version() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'version'
     */
    public static int offset_version() {
        return (80 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'version'
     */
    public static int offsetBits_version() {
        return 80;
    }

    /**
     * Return the value (as a short) of the field 'version'
     */
    public short get_version() {
        return (short)getUIntElement(offsetBits_version(), 8);
    }

    /**
     * Set the value of the field 'version'
     */
    public void set_version(short value) {
        setUIntElement(offsetBits_version(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'version'
     */
    public static int size_version() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'version'
     */
    public static int sizeBits_version() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: flags
    //   Field type: short, unsigned
    //   Offset (bits): 88
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'flags' is signed (false).
     */
    public static boolean isSigned_flags() {
        return false;
    }

    /**
     * Return whether the field 'flags' is an array (false).
     */
    public static boolean isArray_flags() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'flags'
     */
    public static int offset_flags() {
        return (88 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'flags'
     */
    public static int offsetBits_flags() {
        return 88;
    }

    /**
     * Return the value (as a short) of the field 'flags'
     */
    public short get_flags() {
        return (short)getUIntElement(offsetBits_flags(), 8);
    }

    /**
     * Set the value of the field 'flags'
     */
    public void set_flags(short value) {
        setUIntElement(offsetBits_flags(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'flags'
     */
    public static int size_flags() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'flags'
     */
    public static int sizeBits_flags() {
        return 8;
    }

}
