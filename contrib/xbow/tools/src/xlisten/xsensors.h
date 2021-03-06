/**
 * Global definitions for Crossbow sensor boards.
 *
 * @file      xsensors.h
 * @author    Martin Turon
 * @version   2004/3/10    mturon      Initial version
 *
 * Copyright (c) 2004 Crossbow Technology, Inc.   All rights reserved.
 * 
 * $Id: xsensors.h,v 1.39 2005/01/28 05:19:24 mturon Exp $
 */

#ifndef __XSENSORS_H__
#define __XSENSORS_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#ifdef __arm__
typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
#endif

#include "xdb.h"
#include "xconvert.h"

/** 
 *  A unique identifier for each Crossbow sensorboard. 
 *
 *  Note: The sensorboard id is organized to allow for identification of
 *        host mote as well:
 *
 *  if  (sensorboard_id < 0x80)  // mote is a mica2dot
 *  if  (sensorboard_id > 0x7E)  // mote is a mica2
 *
 * @version   2004/3/10    mturon      Initial version
 */
typedef enum {
  // surge packet
  XTYPE_SURGE = 0x00,

  // mica2dot sensorboards 
  XTYPE_MDA500 = 0x01,   
  XTYPE_MTS510,
  XTYPE_MEP500,

  // mote boards
  XTYPE_MICA2 = 0x60,
  XTYPE_MICA2DOT,
  XTYPE_MICAZ,
  
  // mica2 sensorboards 
  XTYPE_MDA400 = 0x80,   
  XTYPE_MDA300,
  XTYPE_MTS101,
  XTYPE_MTS300,
  XTYPE_MTS310,
  XTYPE_MTS400,
  XTYPE_MTS420,
  XTYPE_MEP401,
  XTYPE_XTUTORIAL = 0x88,
  XTYPE_GGBACLTST,

  // mica2 integrated boards
  XTYPE_MSP410 = 0xA0,

} XbowSensorboardType;

typedef enum {
    AMTYPE_XUART      = 0x00,
    AMTYPE_HEALTH     = 0x03,
    AMTYPE_SURGE_MSG  = 0x11,
    AMTYPE_XDEBUG     = 0x31,
    AMTYPE_XSENSOR    = 0x32,
    AMTYPE_XMULTIHOP  = 0x33,
    AMTYPE_MHOP_MSG   = 0xFA
} XbowAMType;

/** 
 * Reserves general packet types that xlisten handles for all sensorboards.
 *
 * @version      2004/4/2     mturon      Initial version
 */
typedef enum {
  // reserved packet ids 
  // reserved packet ids 
  XPACKET_ACK      = 0x40,
  XPACKET_W_ACK    = 0x41,
  XPACKET_NO_ACK   = 0x42,

  XPACKET_ESC      = 0x7D,    //!< Reserved for serial packetizer escape code.
  XPACKET_START    = 0x7E,    //!< Reserved for serial packetizer start code.
  XPACKET_TEXT_MSG = 0xF8,    //!< Special id for sending text error messages.
} XbowGeneralPacketType;

/** Encodes sensor readings into the data payload of a TOS message. */
typedef struct {
    uint8_t  board_id;        //!< Unique sensorboard id
    uint8_t  packet_id;       //!< Unique packet type for sensorboard
    uint8_t  node_id;         //!< Id of originating node
    uint8_t  parent;          //!< Id of node's parent
    uint16_t data[12];        //!< Data payload defaults to 24 bytes
    uint8_t  terminator;      //!< Reserved for null terminator 
} XbowSensorboardPacket;


#define XPACKET_MIN_SIZE            4  //!< minimum valid packet size

#define XPACKET_TYPE                2  //!< offset to type of TOS packet
#define XPACKET_GROUP               3  //!< offset to group id of TOS packet
#define XPACKET_LENGTH              4  //!< offset to length of TOS packet

#define XPACKET_DATASTART_STANDARD  5  //!< Standard offset to data payload
#define XPACKET_DATASTART_MULTIHOP  12 //!< Multihop offset to data payload
#define XPACKET_DATASTART           12 //!< Default offset to data payload

#define XPACKET_BOARD_TABLE        0   //!< offset to XSensor board table
#define XPACKET_AM_TABLE           256 //!< offset to AM lookup table

enum {
	XPACKET_DECODE_MODE_AUTO = 0,
	XPACKET_DECODE_MODE_FRAMED,
	XPACKET_DECODE_MODE_UNFRAMED
};

// Much easier to change arguments.
typedef void (*PacketPrinter)(XbowSensorboardPacket *packet);

typedef union XBoardFlags {
    unsigned flat;
    struct {
	unsigned table_init : 1; //!< whether logging table is validated
    };
} XBoardFlags;

typedef struct XPacketHandler {
    uint8_t  type;               //!< sensorboard id
    char *   version;            //!< CVS version string of boards source file

    PacketPrinter print_parsed;  
    PacketPrinter print_cooked;
    PacketPrinter export_parsed;
    PacketPrinter export_cooked;
    PacketPrinter log_cooked;

    XBoardFlags flags;           //!< flags for board specific management
} XPacketHandler;

/* Linkage to main */
int xmain_get_verbose ();

/* Sensorboard data packet definitions */
void xpacket_print_raw     (unsigned char *tos_packet, int len);
void xpacket_print_ascii   (unsigned char *tos_packet, int len);
void xpacket_print_parsed  (unsigned char *tos_packet);
void xpacket_print_cooked  (unsigned char *tos_packet);
void xpacket_export_parsed (unsigned char *tos_packet);
void xpacket_export_cooked (unsigned char *tos_packet);
void xpacket_log_cooked    (unsigned char *tos_packet);

void xpacket_initialize    ();
void xpacket_decode        (unsigned char *tos_packet, int len, int mode);
void xpacket_add_type      (XPacketHandler *handler);
void xpacket_add_amtype    (XPacketHandler *handler);
void xpacket_print_output  (unsigned out_flags, unsigned char *tos_packet);
void xpacket_print_time    ();
void xpacket_print_versions();
void xpacket_set_start     (unsigned offset);
int  xpacket_get_start     ();

/* Serial port routines. */
int xserial_port_open ();
int xserial_port_dump ();
int xserial_port_sync_packet (int serline);
int xserial_port_read_packet (int serline, unsigned char *buffer);

unsigned xserial_set_baudrate (unsigned baudrate);
unsigned xserial_set_baud     (const char *baud);
void     xserial_set_device   (const char *device);

/* Socket routines. */
int            xsocket_port_open    ();
void           xsocket_set_port     (const char *port);
unsigned       xsocket_get_port     ();
void           xsocket_set_server   (const char *server);
const char *   xsocket_get_server   ();
int            xsocket_read_packet  (int serline, unsigned char *buffer);

void mica2_initialize();    /* From boards/mica2.c */
void mica2dot_initialize();    /* From boards/mica2dot.c */
void micaz_initialize();    /* From boards/micaz.c */

/* Sensorboard specific conversion routines. */
void mda300_initialize();    /* From boards/mda300.c */
void mda400_initialize();    /* From boards/mda500.c */
void mda500_initialize();    /* From boards/mda500.c */

void mts300_initialize();    /* From boards/mts300.c */
void mts310_initialize();    /* From boards/mts300.c */

void mts400_initialize();    /* From boards/mts400.c */
void mts420_initialize();    /* From boards/mts400.c */

void mts510_initialize();    /* From boards/mts510.c */
void mts101_initialize();    /* From boards/mts101.c */
void mep500_initialize();    /* From boards/mep500.c */
void mep401_initialize();    /* From boards/mep401.c */
void ggbacltst_initialize(); /* From boards/ggbacltst.c */
void msp410_initialize();    /* From boards/msp410.c */

void surge_initialize();     /* From boards/surge.c */

void health_initialize();    /* From amtypes/health.c */

void xtutorial_initialize(); /* From baords/xtutorial.c */

#endif  /* __SENSORS_H__ */



