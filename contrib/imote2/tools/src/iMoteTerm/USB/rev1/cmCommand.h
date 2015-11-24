// All command strings end with 0x00 terminator for send function, and begin with a byte count
// of the real packet.

// auto baud detection
static unsigned char cmd_autobaud[] = { 0x01, 0x55, 0x00};
// command to retrieve the camera module revision
static unsigned char cmd_getrev[] = { 0x04, 0x01, 0x00, 0x00, 0x02, 0x00};
// set uart packet size
static unsigned char cmd_init1[] = { 0x06, 0x00, 0x00, 0x20, 0x00, 0x0C, 0x02, 0x00};
static unsigned char cmd_init2[] = { 0x08, 0x00, 0x00, 0x0C, 0xB9, 0x40, 0xB9, 0x40, 0x02, 0x00};
static unsigned char cmd_init3[] = { 0x0C, 0x00, 0x00, 0x26, 0x01, 0x60, 0x01, 0x60, 
                            0x01, 0x60, 0x01, 0x60, 0x02, 0x00};
// Set the JPEG file size
static unsigned char cmd_init4[] = { 0x08, 0x00, 0x00, 0x3E, 0x03, 0xC0, 0x03, 0xC0, 0x02, 0x00};
//static unsigned char cmd_init4[] = { 0x08, 0x00, 0x00, 0x3E, 0x27, 0x10, 0x27, 0x10, 0x02, 0x00};
//static unsigned char cmd_init4[] = { 0x08, 0x00, 0x00, 0x3E, 0x0A, 0x00, 0x0A, 0x00, 0x02, 0x00};
//
static unsigned char cmd_init5[] = { 0x08, 0x00, 0x00, 0x46, 0x03, 0xC0, 0x03, 0xC0, 0x02, 0x00};
static unsigned char cmd_init6[] = { 0x06, 0x00, 0x00, 0x42, 0x00, 0x00, 0x02, 0x00};
// VIDEO mode
static unsigned char cmd_initcmd[] = { 0x07, 0x00, 0x00, 0xEE, 0x02, 0x00, 0x01, 0x02, 0x00};
static unsigned char cmd_setflow[] = { 0x06, 0x00, 0x00, 0x24, 0x00, 0x01, 0x02, 0x00};
// this cmd takes a snapshot
static unsigned char cmd_initcmd1[] = { 0x06, 0x00, 0x00, 0x04, 0x00, 0x01, 0x02, 0x00};
static unsigned char cmd_getcmd2[] = { 0x04, 0x01, 0x00, 0x04, 0x02, 0x00};
// read status register
static unsigned char cmd_status[] = { 0x04, 0x01, 0x00, 0x74, 0x02, 0x00};
// full reset
static unsigned char cmd_reset[] = { 0x06, 0x00, 0x00,  0x04, 0x10, 0x60,  0x02, 0x00};
// abort image bit 11 of register 04
static unsigned char cmd_abort[] = { 0x06, 0x00, 0x00,  0x04, 0x10, 0x00,  0x02, 0x00};


// General status flags register 
#define CM_STATUS_FLAGS   0x74
#define CM_STATUS_FLAGS_AEWB_C_MASK     0x0040     
    // Auto Exposure/White Balance Convergence
    // 0 = Not converted
    // 1 = Converged
#define CM_STATUS_FLAGS_FB_C_OK_MASK    0x0080
    // Frame Buffer Contents
    // 0 = Bad Frame
    // 1 = Good Frame
// SET UP INITIAL PARAMETERS
// These values should be either read in from a file or set in some
// other way that does not require recompiling the program everytime
// there is a change
#define PACKET_SIZE 12          // packet size for image transfer
#define CM_SZR_IN_W 352     // Sizer Input Width
#define CM_SZR_IN_H 352     // Sizer Input Height
#define CM_SZR_OUT_W 352    // Sizer Output Width
#define CM_SZR_OUT_H 352    // Sizer Output Height

