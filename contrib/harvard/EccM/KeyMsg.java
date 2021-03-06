/**
 * This class is automatically generated by mig. DO NOT EDIT THIS FILE.
 * This class implements a Java interface to the 'KeyMsg'
 * message type.
 */

public class KeyMsg extends net.tinyos.message.Message {

    /** The default size of this message type in bytes. */
    public static final int DEFAULT_MESSAGE_SIZE = 22;

    /** The Active Message type associated with this message. */
    public static final int AM_TYPE = 131;

    /** Create a new KeyMsg of size 22. */
    public KeyMsg() {
        super(DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /** Create a new KeyMsg of the given data_length. */
    public KeyMsg(int data_length) {
        super(data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new KeyMsg with the given data_length
     * and base offset.
     */
    public KeyMsg(int data_length, int base_offset) {
        super(data_length, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new KeyMsg using the given byte array
     * as backing store.
     */
    public KeyMsg(byte[] data) {
        super(data);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new KeyMsg using the given byte array
     * as backing store, with the given base offset.
     */
    public KeyMsg(byte[] data, int base_offset) {
        super(data, base_offset);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new KeyMsg using the given byte array
     * as backing store, with the given base offset and data length.
     */
    public KeyMsg(byte[] data, int base_offset, int data_length) {
        super(data, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new KeyMsg embedded in the given message
     * at the given base offset.
     */
    public KeyMsg(net.tinyos.message.Message msg, int base_offset) {
        super(msg, base_offset, DEFAULT_MESSAGE_SIZE);
        amTypeSet(AM_TYPE);
    }

    /**
     * Create a new KeyMsg embedded in the given message
     * at the given base offset and length.
     */
    public KeyMsg(net.tinyos.message.Message msg, int base_offset, int data_length) {
        super(msg, base_offset, data_length);
        amTypeSet(AM_TYPE);
    }

    /**
    /* Return a String representation of this message. Includes the
     * message type name and the non-indexed field values.
     */
    public String toString() {
      String s = "Message <KeyMsg> \n";
      try {
        s += "  [isX=0x"+Long.toHexString(get_isX())+"]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      try {
        s += "  [coord=";
        for (int i = 0; i < 21; i++) {
          s += "0x"+Long.toHexString(getElement_coord(i) & 0xff)+" ";
        }
        s += "]\n";
      } catch (ArrayIndexOutOfBoundsException aioobe) { /* Skip field */ }
      return s;
    }

    // Message-type-specific access methods appear below.

    /////////////////////////////////////////////////////////
    // Accessor methods for field: isX
    //   Field type: short, unsigned
    //   Offset (bits): 0
    //   Size (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'isX' is signed (false).
     */
    public static boolean isSigned_isX() {
        return false;
    }

    /**
     * Return whether the field 'isX' is an array (false).
     */
    public static boolean isArray_isX() {
        return false;
    }

    /**
     * Return the offset (in bytes) of the field 'isX'
     */
    public static int offset_isX() {
        return (0 / 8);
    }

    /**
     * Return the offset (in bits) of the field 'isX'
     */
    public static int offsetBits_isX() {
        return 0;
    }

    /**
     * Return the value (as a short) of the field 'isX'
     */
    public short get_isX() {
        return (short)getUIntElement(offsetBits_isX(), 8);
    }

    /**
     * Set the value of the field 'isX'
     */
    public void set_isX(short value) {
        setUIntElement(offsetBits_isX(), 8, value);
    }

    /**
     * Return the size, in bytes, of the field 'isX'
     */
    public static int size_isX() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of the field 'isX'
     */
    public static int sizeBits_isX() {
        return 8;
    }

    /////////////////////////////////////////////////////////
    // Accessor methods for field: coord
    //   Field type: short[], unsigned
    //   Offset (bits): 8
    //   Size of each element (bits): 8
    /////////////////////////////////////////////////////////

    /**
     * Return whether the field 'coord' is signed (false).
     */
    public static boolean isSigned_coord() {
        return false;
    }

    /**
     * Return whether the field 'coord' is an array (true).
     */
    public static boolean isArray_coord() {
        return true;
    }

    /**
     * Return the offset (in bytes) of the field 'coord'
     */
    public static int offset_coord(int index1) {
        int offset = 8;
        if (index1 < 0 || index1 >= 21) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return (offset / 8);
    }

    /**
     * Return the offset (in bits) of the field 'coord'
     */
    public static int offsetBits_coord(int index1) {
        int offset = 8;
        if (index1 < 0 || index1 >= 21) throw new ArrayIndexOutOfBoundsException();
        offset += 0 + index1 * 8;
        return offset;
    }

    /**
     * Return the entire array 'coord' as a short[]
     */
    public short[] get_coord() {
        short[] tmp = new short[21];
        for (int index0 = 0; index0 < numElements_coord(0); index0++) {
            tmp[index0] = getElement_coord(index0);
        }
        return tmp;
    }

    /**
     * Set the contents of the array 'coord' from the given short[]
     */
    public void set_coord(short[] value) {
        for (int index0 = 0; index0 < value.length; index0++) {
            setElement_coord(index0, value[index0]);
        }
    }

    /**
     * Return an element (as a short) of the array 'coord'
     */
    public short getElement_coord(int index1) {
        return (short)getUIntElement(offsetBits_coord(index1), 8);
    }

    /**
     * Set an element of the array 'coord'
     */
    public void setElement_coord(int index1, short value) {
        setUIntElement(offsetBits_coord(index1), 8, value);
    }

    /**
     * Return the total size, in bytes, of the array 'coord'
     */
    public static int totalSize_coord() {
        return (168 / 8);
    }

    /**
     * Return the total size, in bits, of the array 'coord'
     */
    public static int totalSizeBits_coord() {
        return 168;
    }

    /**
     * Return the size, in bytes, of each element of the array 'coord'
     */
    public static int elementSize_coord() {
        return (8 / 8);
    }

    /**
     * Return the size, in bits, of each element of the array 'coord'
     */
    public static int elementSizeBits_coord() {
        return 8;
    }

    /**
     * Return the number of dimensions in the array 'coord'
     */
    public static int numDimensions_coord() {
        return 1;
    }

    /**
     * Return the number of elements in the array 'coord'
     */
    public static int numElements_coord() {
        return 21;
    }

    /**
     * Return the number of elements in the array 'coord'
     * for the given dimension.
     */
    public static int numElements_coord(int dimension) {
      int array_dims[] = { 21,  };
        if (dimension < 0 || dimension >= 1) throw new ArrayIndexOutOfBoundsException();
        if (array_dims[dimension] == 0) throw new IllegalArgumentException("Array dimension "+dimension+" has unknown size");
        return array_dims[dimension];
    }

    /**
     * Fill in the array 'coord' with a String
     */
    public void setString_coord(String s) { 
         int len = s.length();
         int i;
         for (i = 0; i < len; i++) {
             setElement_coord(i, (short)s.charAt(i));
         }
         setElement_coord(i, (short)0); //null terminate
    }

    /**
     * Read the array 'coord' as a String
     */
    public String getString_coord() { 
         char carr[] = new char[Math.min(net.tinyos.message.Message.MAX_CONVERTED_STRING_LENGTH,21)];
         int i;
         for (i = 0; i < carr.length; i++) {
             if ((char)getElement_coord(i) == (char)0) break;
             carr[i] = (char)getElement_coord(i);
         }
         return new String(carr,0,i);
    }

}
