/*
 * Copyright (c) 2004, Intel Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * Neither the name of the Intel Corporation nor the names of its contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#define TIC TOSH_SET_LED7_PIN();TOSH_CLR_LED7_PIN()
#define RS_LOW TOSH_CLR_LED2_PIN()
#define RS_HI  TOSH_SET_LED2_PIN()
#define CE_LOW TOSH_CLR_LED5_PIN()
#define CE_HI  TOSH_SET_LED5_PIN()
#define SEND0  TOSH_CLR_LED6_PIN()
#define SEND1  TOSH_SET_LED6_PIN()

#define TABLE_SZ 96*5
#define REMOVED 32
#define NUM_DISP_CHAR 4
#define MAX_NUM_STAT_CHAR 2
#define MAX_SCROLL_CHAR 40
#define COLUMNS_PER_CHAR 5
#define BITS_PER_COLUMN 8

module AlphaDispM {
  provides {
    interface AlphaDisp;
  }
  uses {
    interface Timer;
  }
}
implementation
{
  char buf[TABLE_SZ]; // buffer where the Display bitmaps are stored
                      // format is 5 bytes per ASCII character
                      // each byte corresponds to a column in the bitmap

  char outbuf[NUM_DISP_CHAR*COLUMNS_PER_CHAR];

  uint8 num_active; // number of characters available to staticDisp() and scrollInit()
  uint8 num_status; // number of characters used to display status
  char status_bitmap[COLUMNS_PER_CHAR*MAX_NUM_STAT_CHAR]; // status can use up to 10 columns of display

  int s_len, s_i;
  char s_bitmap[MAX_SCROLL_CHAR*COLUMNS_PER_CHAR+NUM_DISP_CHAR*COLUMNS_PER_CHAR];
  int refresh_rate; // number of msec

  void blankDisp();
  void setBright(uint8 bright);
  void updateDisp (char *buffer);
  char* copyBitmap (char *dest, char *src);

  command result_t AlphaDisp.init(uint8 numStatus) {
    int i;
    //uint8 c;
    char buf_i[TABLE_SZ] = {
    // The first 32 characters of the ASCII table are control characters which are not
    // used in the display.  Therefor the corresponding bitmap is commented out to save
    // memory.
    /*0x3f,0x3f,0x3f,0x3f,0x0,0x8,0x1c,0x3e,0x1c,0x8,0x2a,0x15,0x2a,0x15,0x0,0xf,0x12,0x7f,0x10,0x0,
    0xf,0x5,0x78,0x28,0x0,0x7,0x7d,0x28,0x50,0x0,0x7,0x4,0x78,0x28,0x0,0x0,0x2,0x5,0x2,0x0,
    0x0,0x12,0x17,0x12,0x0,0xf,0x2,0x74,0x4f,0x0,0x7,0x18,0x77,0x10,0x0,0x8,0x8,0xf,0x0,0x0,
    0x8,0x8,0x78,0x0,0x0,0x0,0x0,0x78,0x8,0x8,0x0,0x0,0xf,0x8,0x8,0x8,0x8,0x7f,0x8,0x8,
    0x2,0x2,0x2,0x2,0x2,0x4,0x4,0x4,0x4,0x4,0x8,0x8,0x8,0x8,0x8,0x10,0x10,0x10,0x10,0x10,
    0x20,0x20,0x20,0x20,0x20,0x0,0x0,0x7f,0x8,0x8,0x8,0x8,0x7f,0x0,0x0,0x8,0x8,0xf,0x8,0x8,
    0x8,0x8,0x78,0x8,0x8,0x0,0x0,0x7f,0x0,0x0,0x0,0x24,0x2a,0x31,0x0,0x0,0x31,0x2a,0x24,0x0,
    0x0,0x3c,0x4,0x3c,0x0,0x0,0x34,0x1c,0x16,0x0,0x28,0x1c,0x2a,0x22,0x0,0x0,0x0,0x8,0x0,0x0,*/
    0x0,0x0,0x0,0x0,0x0,0xa,0x0,0x75,0x0,0xa,0x0,0x7,0x0,0x7,0x0,0x14,0x3e,0x14,0x3e,0x14,
    0x4,0x2a,0x3e,0x2a,0x10,0x13,0x8,0x4,0x32,0x0,0x14,0x2a,0x14,0x20,0x0,0x4,0x3,0x1,0x0,0x0,
    0x0,0x1e,0x21,0x0,0x0,0x0,0x21,0x1e,0x0,0x0,0x2a,0x1c,0x2a,0x0,0x0,0x8,0x8,0x3e,0x8,0x8,
    0x40,0x30,0x10,0x0,0x0,0x8,0x8,0x8,0x8,0x0,0x0,0x30,0x30,0x0,0x0,0x10,0x8,0x4,0x2,0x0,
    0x1e,0x21,0x1e,0x0,0x0,0x22,0x3f,0x20,0x0,0x0,0x22,0x31,0x29,0x26,0x0,0x11,0x25,0x25,0x1b,0x0,
    0xc,0xa,0x3f,0x8,0x0,0x17,0x25,0x25,0x19,0x0,0x1e,0x25,0x25,0x18,0x0,0x1,0x31,0xd,0x3,0x0,
    0x1a,0x25,0x25,0x1a,0x0,0x6,0x29,0x29,0x1e,0x0,0x0,0x36,0x36,0x0,0x0,0x40,0x36,0x16,0x0,0x0,
    0x8,0x14,0x22,0x0,0x0,0x14,0x14,0x14,0x14,0x0,0x22,0x14,0x8,0x0,0x0,0x2,0x29,0x6,0x0,0x0,
    0x1e,0x21,0x2d,0xe,0x0,0x3e,0x9,0x9,0x3e,0x0,0x3f,0x25,0x25,0x1a,0x0,0x1e,0x21,0x21,0x12,0x0,
    0x3f,0x21,0x21,0x1e,0x0,0x3f,0x25,0x25,0x21,0x0,0x3f,0x5,0x5,0x1,0x0,0x1e,0x21,0x29,0x3a,0x0,
    0x3f,0x4,0x4,0x3f,0x0,0x21,0x3f,0x21,0x0,0x0,0x10,0x20,0x20,0x1f,0x0,0x3f,0xc,0x12,0x21,0x0,
    0x3f,0x20,0x20,0x20,0x0,0x3f,0x6,0x6,0x3f,0x0,0x3f,0x6,0x18,0x3f,0x0,0x1e,0x21,0x21,0x1e,0x0,
    0x3f,0x9,0x9,0x6,0x0,0x1e,0x31,0x21,0x5e,0x0,0x3f,0x9,0x19,0x26,0x0,0x12,0x25,0x29,0x12,0x0,
    0x1,0x3f,0x1,0x0,0x0,0x1f,0x20,0x20,0x1f,0x0,0xf,0x30,0x30,0xf,0x0,0x3f,0x18,0x18,0x3f,0x0,
    0x33,0xc,0xc,0x33,0x0,0x7,0x38,0x7,0x0,0x0,0x31,0x29,0x25,0x23,0x0,0x3f,0x21,0x21,0x0,0x0,
    0x2,0x4,0x8,0x10,0x0,0x21,0x21,0x3f,0x0,0x0,0x2,0x1,0x2,0x0,0x0,0x20,0x20,0x20,0x20,0x0,
    0x1,0x3,0x4,0x0,0x0,0x18,0x24,0x14,0x3c,0x0,0x3f,0x24,0x24,0x18,0x0,0x18,0x24,0x24,0x0,0x0,
    0x18,0x24,0x24,0x3f,0x0,0x18,0x34,0x2c,0x8,0x0,0x8,0x3e,0x9,0x2,0x0,0x28,0x54,0x54,0x4c,0x0,
    0x3f,0x4,0x4,0x38,0x0,0x24,0x3d,0x20,0x0,0x0,0x20,0x40,0x3d,0x0,0x0,0x3f,0x8,0x14,0x20,0x0,
    0x21,0x3f,0x20,0x0,0x0,0x3c,0x8,0xc,0x38,0x0,0x3c,0x4,0x4,0x38,0x0,0x18,0x24,0x24,0x18,0x0,
    0x7c,0x24,0x24,0x18,0x0,0x18,0x24,0x24,0x7c,0x0,0x3c,0x4,0x4,0x8,0x0,0x28,0x2c,0x34,0x14,0x0,
    0x4,0x1f,0x24,0x20,0x0,0x1c,0x20,0x20,0x3c,0x0,0x1c,0x20,0x1c,0x0,0x0,0x3c,0x30,0x30,0x3c,0x0,
    0x24,0x18,0x18,0x24,0x0,0xc,0x50,0x20,0x1c,0x0,0x24,0x34,0x2c,0x24,0x0,0x4,0x1e,0x21,0x0,0x0,
    0x0,0x3f,0x0,0x0,0x0,0x21,0x1e,0x4,0x0,0x0,0x2,0x1,0x2,0x1,0x0};

    /* clear DOT register */
    blankDisp();

    /* set to lowest power consumption */
    setBright(1);

    /* initialize the bitmap table */
    for (i=0; i<TABLE_SZ; i++)
      buf[i]=buf_i[i];

    if (numStatus<=2) {
       num_status = numStatus;
       num_active = NUM_DISP_CHAR - numStatus;
    }
    else {
       num_status = 0;
       num_active = NUM_DISP_CHAR;
    }

    for (i=0; i<numStatus*COLUMNS_PER_CHAR; i++)
       status_bitmap[i]=0;

    refresh_rate = 300; // default rate of update is 300 msec

    return SUCCESS;
  }

  // put display to sleep
  command result_t AlphaDisp.sleep() {
    uint8 c;
    int i;
    call Timer.stop();
    RS_HI;
    CE_LOW;
    c = 0x00;
    for (i=7; i>=0; i--) {
      if ((c & (1<<i)) == 0)
        SEND0;
      else
        SEND1;
      TIC;
    }
    CE_HI;
    return SUCCESS;
  }

  // display static characters
  command result_t AlphaDisp.staticDisp(char *c, uint8 count, uint8 bright) {
    int i;
    char *buf_ptr, *bitmap_ptr, c_temp;
    uint16 buf_st;
    if (count>num_active)
      count = num_active;
    call Timer.stop(); // disable the scrolling
    blankDisp();
    setBright(bright);
    bitmap_ptr = &outbuf[0];
    for (i=0; i<count; i++) {
      c_temp = c[i] & 0x7f;
      buf_st = (c_temp-REMOVED)*COLUMNS_PER_CHAR;
      buf_ptr = &buf[buf_st];
      bitmap_ptr=copyBitmap(bitmap_ptr, buf_ptr);
    }
    if (num_status>2)
      buf_ptr = &status_bitmap[0];
    else
      buf_ptr = &status_bitmap[5];
    //for (i=count; i<NUM_DISP_CHAR; i++)
    //  bitmap_ptr=copyBitmap(bitmap_ptr, buf_ptr);
    updateDisp(outbuf);
    return SUCCESS;
  }

  // scroll the characters continuously
  command result_t AlphaDisp.scrollInit(char *c, uint8 count, uint8 bright) {
    int i, buf_st;
    char *bitmap_ptr, *buf_ptr, c_temp;

    blankDisp();
    setBright(bright);

    s_len = count*COLUMNS_PER_CHAR+NUM_DISP_CHAR*COLUMNS_PER_CHAR; // blank the first 4 characters

    bitmap_ptr = &s_bitmap[0];
    for (i=0; i<NUM_DISP_CHAR*COLUMNS_PER_CHAR; i++)
      *bitmap_ptr++=0;

    for (i=0; i<count; i++) {
      c_temp = c[i] & 0x7f;
      buf_st = (c_temp-REMOVED)*COLUMNS_PER_CHAR;
      buf_ptr = &buf[buf_st];
      bitmap_ptr=copyBitmap(bitmap_ptr, buf_ptr);
    }
    s_i = 0;
    call Timer.start(TIMER_REPEAT, refresh_rate);
    return SUCCESS;
  }

  // set refresh rate
  // refresh value is in msec
  command result_t AlphaDisp.setRefresh(int refresh) {
    refresh_rate = refresh;
    call Timer.start(TIMER_REPEAT, refresh_rate);
    return SUCCESS;
  }

  // update scroll characters
  event result_t Timer.fired() {
    //char outbuf[COLUMNS_PER_CHAR*NUM_DISP_CHAR];
    int i, offset, offset2;

    for (i=0; i<COLUMNS_PER_CHAR*num_active; i++) {
    	if (s_i==s_len)
    	  s_i = 0;
    	outbuf[i]=s_bitmap[s_i++];
    }
    s_i = s_i-(num_active-1)*COLUMNS_PER_CHAR;
    if (s_i<0)
      s_i = s_len+s_i;

    offset = i;
    offset2 = 0;
    if (num_status <=2)
       offset2 = 5;
    for (i=0; i<num_status*COLUMNS_PER_CHAR; i++)
       outbuf[i+offset]=status_bitmap[i+offset2];

    updateDisp(outbuf);
    return SUCCESS;
  }

  // update status character bitmap according to linkQuality value
  command result_t AlphaDisp.linkStatusDisp(uint8 dispId, uint8 linkQuality) {
    char temp[15], tempBitmap[COLUMNS_PER_CHAR], *ptr, mask;
    int i, j, sh;
    //if ((dispId>>1) != (num_status>>1))
    //  return FAIL;
    for (i=0; i<linkQuality; i++)
      temp[i]=1;
    for (i=linkQuality; i<15; i++)
      temp[i]=0;
    ptr = &temp[0];
    for (i=0; i<COLUMNS_PER_CHAR; i++) {
      tempBitmap[i]=0;
      for (j=0; j<3; j++)
        tempBitmap[i] = tempBitmap[i] | (*ptr++ << j);
    }
    if ((dispId&1) == 0) {
      mask = 0x70;
      sh = 0;
    }
    else {
      mask = 0x07;
      sh = 4;
    }
    if ((dispId&2) == 0)
      //ptr = &status_bitmap[5];
      ptr = &outbuf[15];
    else
      //ptr = &status_bitmap[0];
      ptr = &outbuf[10];
    for (i=0; i<COLUMNS_PER_CHAR; i++) {
      *ptr = *ptr & mask;
      *ptr = *ptr++ | (tempBitmap[i] << sh);
    }
    updateDisp(outbuf);

    return SUCCESS;
  }

  // display the bitmap stored in outbuf
  void updateDisp (char *buffer) {
    int i, j;
    RS_LOW;
    CE_LOW;
    for (i=0; i<COLUMNS_PER_CHAR*NUM_DISP_CHAR; i++) {
      for (j=7; j>=0; j--) {
        if ((buf[i] & (1<<j)) == 0)
          SEND0;
        else
          SEND1;
        TIC;
      }
    }
    CE_HI;
  }

  // put display to sleep
  void blankDisp() {
  int i;
    RS_LOW;
    CE_LOW;
    for (i=0; i<BITS_PER_COLUMN*COLUMNS_PER_CHAR*NUM_DISP_CHAR; i++) {
      SEND0;
      TIC;
    }
    CE_HI;

  }

  // set brightness of display
  // bright = 1    ---->>    dimest
  // bright = 15   ---->>    brightest
  void setBright(uint8 bright) {
    uint8 ctrl;
    int i;
    RS_HI;
    CE_LOW;
    ctrl = 0x60 | (bright&0xf);
    for (i=7; i>=0; i--) {
      if ((ctrl & (1<<i)) == 0)
        SEND0;
      else
        SEND1;
      TIC;
    }
    CE_HI;
  }

  // copy the bitmap of 1 ASCII character
  char* copyBitmap (char *dest, char *src) {
      *dest++ = *src++;
      *dest++ = *src++;
      *dest++ = *src++;
      *dest++ = *src++;
      *dest++ = *src++;
      return dest;
  }
}
