/*
 * Copyright (c) 2002-2004 the University of Southern California
 * Copyright (c) 2004 TU Delft/TNO
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement 
 * is hereby granted, provided that the above copyright notice and the
 * following two paragraphs appear in all copies of this software.
 *
 * IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE TO ANY
 * PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
 * ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE
 * COPYRIGHT HOLDERS HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * THE COPYRIGHT HOLDERS SPECIFICALLY DISCLAIM ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER
 * IS ON AN "AS IS" BASIS, AND THE COPYRIGHT HOLDERS HAVE NO
 * OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
 * MODIFICATIONS.
 *
 * Authors:	Wei Ye (S-MAC version), Tom Parker (T-MAC modifications)
 *
 * this file defines the events in T-MAC for debugging
 */

/**
 * @author Wei Ye
 * @author Tom Parker
 */

#ifndef TMAC_EVENTS
#define TMAC_EVENTS

#define TMAC_MIN_EVENT 9
#define TMAC_INIT_NODE 10

// number of _ at beginning == number of next bytes are state

// packet transmission
#define TX_SYNC_DONE 11
#define TX_RTS_DONE  12
#define _TX_CTS_DONE  13
#define TX_BCAST_DONE 14
#define TX_UCAST_DONE 15
#define TX_ACK_DONE 16

// packet reception
#define RX_SYNC_DONE 17
#define RX_RTS_DONE 18
#define RX_CTS_DONE 19
#define RX_BCAST_DONE 20
#define RX_UCAST_DONE 21
#define RX_ACK_DONE 22
#define __RX_ERROR 23
#define _RX_UNKNOWN_PKT 24

// timer event
#define TIMER_FIRE_NAV 25
#define TIMER_FIRE_NEIGHBOR_NAV 26
#define TIMER_FIRE_BACKOFF 27
#define TIMER_FIRE_WAIT_CTS 29
#define TIMER_FIRE_WAIT_ACK 30
#define TIMER_FIRE_LISTEN_SYNC 31
#define TIMER_FIRE_LISTEN_DATA 32
#define _TIMER_FIRE_SCHED_SLEEP 33
#define TIMER_FIRE_NEED_TX_SYNC 34
#define _TIMER_FIRE_TX_DELAY 35
#define TIMER_FIRE_ADAP_LISTEN_DONE 36
#define TIMER_FIRE_TX_RETRY 37

// carrier sense
#define __CHANNEL_BUSY_DETECTED 38
#define CHANNEL_IDLE_DETECTED 39
#define _START_SYMBOL_DETECTED 40

// other events
#define TRYTOSEND_FAIL_NOT_IDLE 41
#define TRYTOSEND_FAIL_NAV 42
#define TRYTOSEND_FAIL_NEIGHBNAV 43

// tx related flags and events
#define TMAC_TX_REQUEST_IS_0 44
#define TMAC_TX_REQUEST_IS_1 45
#define TMAC_BCAST_REQUEST_REJECTED_TXREQUEST_IS_1 46
#define TMAC_BCAST_REQUEST_REJECTED_DATA_IS_0 47
#define TMAC_BCAST_REQUEST_REJECTED_PKTLEN_ERROR 48
#define TMAC_UCAST_REQUEST_REJECTED_TXREQUEST_IS_1 49
#define TMAC_UCAST_REQUEST_REJECTED_DATA_IS_0 50
#define TMAC_UCAST_REQUEST_REJECTED_PKTLEN_ERROR 51
#define TMAC_UCAST_REQUEST_REJECTED_NUMFRAGS_IS_0 52

// application layer
#define APP_TX_PENDING_IS_0 53
#define APP_TX_PENDING_IS_1 54
#define APP_TX_BCAST_ACCEPTED_BY_MAC 55
#define APP_TX_BCAST_REJECTED_BY_MAC 56
#define APP_TX_UCAST_ACCEPTED_BY_MAC 57
#define APP_TX_UCAST_REJECTED_BY_MAC 58
#define APP_POST_TX_TASK_FAILED 59
#define APP_TIME_COUNT_IS_0 60
#define APP_TIME_COUNT_NOT_RENEW 61

// physical layer
#define PHY_RX_BUF_FULL 62
#define PHY_STATE_IS_RECEIVING 63
#define PHY_STATE_IS_TRANSMITTING 64

#define _TMAC_STATE 65
#define _RADIO_RECV 66
#define _LISTENBITS 67
#define RECV_WEIRD 68
#define _RADIO_TX  69
#define __CARRSENSE_START 70
#define __TMAC_CLOCK 71
//#define __RADIO_RSSI 72
#define _LED_SET 73
#define _LED_UNSET 74
#define _LED_TOGGLE 75
#define _TIMER_FIRE_NEED_TX_DATA 76 
#define INIT_STATE_DIY 77
#define INIT_STATE_DONE 78
// TMACM.nc
#define _RADIO_STATE 79
#define TRYTOSEND_FAIL_TXPKTDONE 80
#define _TX_RESEND 81
#define _STORED_DATA 82
#define RSSI_INVALID 83
#define ____STARTSYM_CHECK 84
#define _OFFSET 85
#define _SYNC_SANITY_FAIL 86
#define _CANT_FIND_UNICAST_NEIGHBOUR 87
#define TIMER_FIRE_WAIT_DATA 88
#define WAIT_FOR_BAD_SEND 89
#define TX_RESEND_LIMIT 90
#define TMAC_SEND_SYNC_NOW 91
#define _PHY_STATE 92
// RadioSPIM.nc
//#define _LL_RADIO_STATE 93
#define _RTS_RX_DISCARD 94
#define HANDLE_ERR_PKT 95
// RadioControlM.nc
#define _MM_RADIO_STATE 96
#define PHY_BAD_SIZE 97
#define _PHY_BAD_STATE 98
#define _LL_BAD_RECV 99
#define _LL_SPI_EVENT 100
#define _LL_RADIO_OLD_STATE 101
//#define _MM_RADIO_OLD_STATE 102
#define _PHY_PKT_SIZE 103
#define __RADIO_FAIL_SLEEP 104
#define _RTS_NOT_FOR_ME 105
#define _TX_DELAY 106
#define _LL_SEND 107
//#define _DISCARD_BYTE 108
#define _LL_REAL_SEND 109
#define _PKT_DATA 110
#define _LL_RADIO_RECV 111
#define __CRC 112
#define _PHY_RADIO_RECV 113
#define INIT_STATE_GOT_BUT_WAIT 114
#define _NUM_NEIGHBOURS 115
#define __SET_SCHED_0_COUNTER 116
#define __PACKET_SLEEPTIME 117
#define __RX_DELAY 118
#define __RESET_TTS 119
#define _PHY_RECV_UNDECODE 120
#define RADIO_TEST_INIT 121
#define START_SYMBOL_DETECTED 122
#define _SCHED_NEW_ID 123
#define __SCHED_UPD_SCHED 124
#define __SCHED_NEW_SCHED 125
#define _PKT_LENGTH 127
#define RADIO_FAIL_SLEEP 128
#define __NEIGH_OLD_SCHED 129
#define __EXCESSIVE_REFTIME 130
#define __BIGWAIT 131
#define __COUNTER_MISSED 132

#define __RADIO_TEST_RECV 0xFA
#define _RADIO_TEST_XMIT 0xFB

#endif // TMAC_EVENTS
