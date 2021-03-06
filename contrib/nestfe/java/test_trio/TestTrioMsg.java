/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'TestTrioMsg'
 * message type.
 */

package test_trio;

public class TestTrioMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 10;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 65;

    /** Create a new TestTrioMsg of size 10. */
    public TestTrioMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new TestTrioMsg of the given data_length. */
    public TestTrioMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TestTrioMsg with the given data_length
     * and base offset.
     */
    public TestTrioMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TestTrioMsg using the given byte array
     * as backing store.
     */
    public TestTrioMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TestTrioMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public TestTrioMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TestTrioMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public TestTrioMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TestTrioMsg embedded in the given message
     * at the given base offset.
     */
    public TestTrioMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new TestTrioMsg embedded in the given message
     * at the given base offset and length.
     */
    public TestTrioMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <TestTrioMsg> \n";
      try {
        s += "  [cmd=0x"+Long.toHexString(get_cmd())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [subcmd=0x"+Long.toHexString(get_subcmd())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [arg=";
        for (int i = 0; i < 8; i++) {
          s += "0x"+Long.toHexString(getElement_arg(i) & 0xff)+" ";
        }
        s += "]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: cmd
    //   Field type: short, unsigned
    //   Offset (bits): 0
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'cmd' is signed (false).
     */
    public static boolean isSigned_cmd() {
        return false;
    }

    /**
     * Return whether the field 'cmd' is an array (false).
     */
    public static boolean isArray_cmd() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'cmd'
     */
    public static int offset_cmd() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'cmd'
     */
    public static int offsetBits_cmd() {
        return 0;
    }

    /**
     * Return the value (as a short) of the field 'cmd'
     */
    public short get_cmd() {
        return (short)getUIntElement(offsetBits_cmd(), 8);
    }

    /**
     * Set the value of the field 'cmd'
     */
    public void set_cmd(short value) {
        setUIntElement(offsetBits_cmd(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'cmd'
     */
    public static int size_cmd() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'cmd'
     */
    public static int sizeBits_cmd() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: subcmd
    //   Field type: short, unsigned
    //   Offset (bits): 8
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'subcmd' is signed (false).
     */
    public static boolean isSigned_subcmd() {
        return false;
    }

    /**
     * Return whether the field 'subcmd' is an array (false).
     */
    public static boolean isArray_subcmd() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'subcmd'
     */
    public static int offset_subcmd() {
        return (8 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'subcmd'
     */
    public static int offsetBits_subcmd() {
        return 8;
    }

    /**
     * Return the value (as a short) of the field 'subcmd'
     */
    public short get_subcmd() {
        return (short)getUIntElement(offsetBits_subcmd(), 8);
    }

    /**
     * Set the value of the field 'subcmd'
     */
    public void set_subcmd(short value) {
        setUIntElement(offsetBits_subcmd(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'subcmd'
     */
    public static int size_subcmd() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'subcmd'
     */
    public static int sizeBits_subcmd() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: arg
    //   Field type: short[], unsigned
    //   Offset (bits): 16
    //   Size of each element (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'arg' is signed (false).
     */
    public static boolean isSigned_arg() {
        return false;
    }

    /**
     * Return whether the field 'arg' is an array (true).
     */
    public static boolean isArray_arg() {
        return true;
    }

    /**
     * Return the offset (in bytes) of the field 'arg'
     */
    public static int offset_arg(int index1) {
        int offset = 16;
        if (index1 < 0 || index1 >= 8) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return (offset / 8);
    }

    /**
     * Return the offset (in bits) of the field 'arg'
     */
    public static int offsetBits_arg(int index1) {
        int offset = 16;
        if (index1 < 0 || index1 >= 8) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return offset;
    }

    /**
     * Return the entire array 'arg' as a short[]
     */
    public short[] get_arg() {
        short[] tmp = new short[8];
        for (int index0 = 0; index0 < numElements_arg(0); index0++) {
            tmp[index0] = getElement_arg(index0);
        }
        return tmp;
    }

    /**
     * Set the contents of the array 'arg' from the given short[]
     */
    public void set_arg(short[] value) {
        for (int index0 = 0; index0 < value.length; index0++) {
            setElement_arg(index0, value[index0]);
        }
    }

    /**
     * Return an element (as a short) of the array 'arg'
     */
    public short getElement_arg(int index1) {
        return (short)getUIntElement(offsetBits_arg(index1), 8);
    }

    /**
     * Set an element of the array 'arg'
     */
    public void setElement_arg(int index1, short value) {
        setUIntElement(offsetBits_arg(index1), 8, value);
    }

    /**
     * Return the total size, in bytes, of the array 'arg'
     */
    public static int totalSize_arg() {
        return (64 / 8);
    }

    /**
     * Return the total size, in bits, of the array 'arg'
     */
    public static int totalSizeBits_arg() {
        return 64;
    }

    /**
     * Return the size, in bytes, of each element of the array 'arg'
     */
    public static int elementSize_arg() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of each element of the array 'arg'
     */
    public static int elementSizeBits_arg() {
        return 8;
    }

    /**
     * Return the number of dimensions in the array 'arg'
     */
    public static int numDimensions_arg() {
        return 1;
    }

    /**
     * Return the number of elements in the array 'arg'
     */
    public static int numElements_arg() {
        return 8;
    }

    /**
     * Return the number of elements in the array 'arg'
     * for the given dimension.
     */
    public static int numElements_arg(int dimension) {
      int array_dims[] = { 8,  };
        if (dimension < 0 || dimension >= 1) throw new ArrayIndexOutOfBoundsException();
        if (array_dims[dimension] == 0) throw new IllegalArgumentException("Array dimension "+dimension+" has unknown size");
        return array_dims[dimension];
    }

    /**
     * Fill in the array 'arg' with a String
     */
    public void setString_arg(String s) { 
         int len = s.length();
         int i;
         for (i = 0; i < len; i++) {
             setElement_arg(i, (short)s.charAt(i));
         }
         setElement_arg(i, (short)0); //null terminate
    }

    /**
     * Read the array 'arg' as a String
     */
    public String getString_arg() { 
         char carr[] = new char[Math.min(net.tinyos.message.Message.MAX_CONVERTED_STRING_LENGTH,8)];
         int i;
         for (i = 0; i < carr.length; i++) {
             if ((char)getElement_arg(i) == (char)0) break;
             carr[i] = (char)getElement_arg(i);
         }
         return new String(carr,0,i);
    }

}
