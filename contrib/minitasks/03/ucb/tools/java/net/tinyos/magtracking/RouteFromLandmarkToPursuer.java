/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'RouteFromLandmarkToPursuer'
 * message type.
 */

package net.tinyos.magtracking;

public class RouteFromLandmarkToPursuer extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 5;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 54;

    /** Create a new RouteFromLandmarkToPursuer of size 5. */
    public RouteFromLandmarkToPursuer() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new RouteFromLandmarkToPursuer of the given data_length. */
    public RouteFromLandmarkToPursuer(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new RouteFromLandmarkToPursuer with the given data_length
     * and base offset.
     */
    public RouteFromLandmarkToPursuer(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new RouteFromLandmarkToPursuer using the given byte array
     * as backing store.
     */
    public RouteFromLandmarkToPursuer(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new RouteFromLandmarkToPursuer using the given byte array
     * as backing store, with the given base offset.
     */
    public RouteFromLandmarkToPursuer(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new RouteFromLandmarkToPursuer using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public RouteFromLandmarkToPursuer(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new RouteFromLandmarkToPursuer embedded in the given message
     * at the given base offset.
     */
    public RouteFromLandmarkToPursuer(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new RouteFromLandmarkToPursuer embedded in the given message
     * at the given base offset and length.
     */
    public RouteFromLandmarkToPursuer(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <RouteFromLandmarkToPursuer> \n";
      try {
        s += "  [type=0x"+Long.toHexString(get_type())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [pursureDestId=0x"+Long.toHexString(get_pursureDestId())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [crumbNo=0x"+Long.toHexString(get_crumbNo())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [length=0x"+Long.toHexString(get_length())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: type
    //   Field type: short, unsigned
    //   Offset (bits): 0
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'type' is signed (false).
     */
    public static boolean isSigned_type() {
        return false;
    }

    /**
     * Return whether the field 'type' is an array (false).
     */
    public static boolean isArray_type() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'type'
     */
    public static int offset_type() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'type'
     */
    public static int offsetBits_type() {
        return 0;
    }

    /**
     * Return the value (as a short) of the field 'type'
     */
    public short get_type() {
        return (short)getUIntElement(offsetBits_type(), 8);
    }

    /**
     * Set the value of the field 'type'
     */
    public void set_type(short value) {
        setUIntElement(offsetBits_type(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'type'
     */
    public static int size_type() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'type'
     */
    public static int sizeBits_type() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: pursureDestId
    //   Field type: short, unsigned
    //   Offset (bits): 8
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'pursureDestId' is signed (false).
     */
    public static boolean isSigned_pursureDestId() {
        return false;
    }

    /**
     * Return whether the field 'pursureDestId' is an array (false).
     */
    public static boolean isArray_pursureDestId() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'pursureDestId'
     */
    public static int offset_pursureDestId() {
        return (8 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'pursureDestId'
     */
    public static int offsetBits_pursureDestId() {
        return 8;
    }

    /**
     * Return the value (as a short) of the field 'pursureDestId'
     */
    public short get_pursureDestId() {
        return (short)getUIntElement(offsetBits_pursureDestId(), 8);
    }

    /**
     * Set the value of the field 'pursureDestId'
     */
    public void set_pursureDestId(short value) {
        setUIntElement(offsetBits_pursureDestId(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'pursureDestId'
     */
    public static int size_pursureDestId() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'pursureDestId'
     */
    public static int sizeBits_pursureDestId() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: crumbNo
    //   Field type: int, unsigned
    //   Offset (bits): 16
    //   Size (bits): 16
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'crumbNo' is signed (false).
     */
    public static boolean isSigned_crumbNo() {
        return false;
    }

    /**
     * Return whether the field 'crumbNo' is an array (false).
     */
    public static boolean isArray_crumbNo() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'crumbNo'
     */
    public static int offset_crumbNo() {
        return (16 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'crumbNo'
     */
    public static int offsetBits_crumbNo() {
        return 16;
    }

    /**
     * Return the value (as a int) of the field 'crumbNo'
     */
    public int get_crumbNo() {
        return (int)getUIntElement(offsetBits_crumbNo(), 16);
    }

    /**
     * Set the value of the field 'crumbNo'
     */
    public void set_crumbNo(int value) {
        setUIntElement(offsetBits_crumbNo(), 16, value);
    }

    /**
     * Return the size, in bytes, of the field 'crumbNo'
     */
    public static int size_crumbNo() {
        return (16 / 8);
    }

    /**
     * Return the size, in bits, of the field 'crumbNo'
     */
    public static int sizeBits_crumbNo() {
        return 16;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: length
    //   Field type: short, unsigned
    //   Offset (bits): 32
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'length' is signed (false).
     */
    public static boolean isSigned_length() {
        return false;
    }

    /**
     * Return whether the field 'length' is an array (false).
     */
    public static boolean isArray_length() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'length'
     */
    public static int offset_length() {
        return (32 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'length'
     */
    public static int offsetBits_length() {
        return 32;
    }

    /**
     * Return the value (as a short) of the field 'length'
     */
    public short get_length() {
        return (short)getUIntElement(offsetBits_length(), 8);
    }

    /**
     * Set the value of the field 'length'
     */
    public void set_length(short value) {
        setUIntElement(offsetBits_length(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'length'
     */
    public static int size_length() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'length'
     */
    public static int sizeBits_length() {
        return 8;
    }

}
