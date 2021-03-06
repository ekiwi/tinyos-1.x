//------------------------------------------------------------------------------
//
//
//    Project:      Dynamic Script Converter 
//
//  File name:    DSC_ScriptConverter.c 
//
//  Author:       Charles Liu 
// 
// 
//  Copyright (c) 2002 Zeevo Inc. All rights reserved. 
// 
//------------------------------------------------------------------------------
//******************************************************************************
//*                                                                            *
//*                              IMPORTANT                                     *
//*                                                                            *
//*   This file is automatically generated. This file MUST not be changed.      *
//*                                                                            *
//******************************************************************************

#ifndef __ZvDynamicConfig__H
#define __ZvDynamicConfig__H

typedef struct t_ZvDynamicCfg { 
shortbool  Platform_FPGA                            ; // false 
shortbool  Platform_DEV                             ; // false 
shortbool  Platform_P4                              ; // true 
shortbool  Platform_ME                              ; // false 
shortbool  Interface_EMBEDDED                       ; // false 
shortbool  Interface_HCI                            ; // false 
shortbool  Interface_AGENT                          ; // true 
shortbool  Interface_ZERIAL                         ; // false 
shortbool  Profile_SPP                              ; // false 
shortbool  Profile_DUN                              ; // false 
shortbool  Profile_FAX                              ; // false 
shortbool  Profile_HS                               ; // false 
shortbool  Profile_LAN                              ; // false 
shortbool  Profile_PAN                              ; // false 
shortbool  Profile_BNEP                             ; // false 
shortbool  Profile_HID                              ; // false 
shortbool  Profile_HCRP                             ; // false 
shortbool  System_DeepSleepEnable                   ; // true 
shortbool  ZerialSys_PageScanDisableLock            ; // false 
shortbool  ZerialSys_InqScanDisableLock             ; // false 
shortbool  Zerial_Dynamic_Config_PIN                ; // false 
shortbool  System_Use_32_7K_Crystal                 ; // false 
shortbool  Debug_UsingBackupRadio                   ; // false 
shortbool  Debug_ProbeMuxOn                         ; // false 
shortbool  Debug_EnableDefaultMuxGroup              ; // false 
shortbool  Debug_EnableGoggleBoard                  ; // false 
shortbool  Debug_EnableRfJtag                       ; // false 
shortbool  Debug_XramLogForP4                       ; // false 
shortbool  Debug_EnableLedsToGpio                   ; // true 
shortbool  Debug_DisableGpioInterrupt               ; // false 
shortbool  Debug_RfpEnable_34                       ; // false 
shortbool  Debug_RfpEnable_34_Late                  ; // false 
shortbool  Debug_RfpEnable_40                       ; // false 
shortbool  Debug_RfpEnable_42                       ; // false 
shortbool  Debug_RfpEnable_44                       ; // false 
shortbool  Debug_RfpEnable_46                       ; // false 
shortbool  Debug_RfpEnable_48                       ; // false 
shortbool  Debug_RfpEnable_4A                       ; // false 
shortbool  Debug_RfpEnable_4C                       ; // false 
shortbool  Debug_RfpEnable_4E                       ; // false 
shortbool  Debug_RfpEnable_50                       ; // false 
shortbool  Debug_RfpEnable_52                       ; // false 
shortbool  Debug_RfpEnable_54                       ; // false 
shortbool  Debug_RfpEnable_56                       ; // false 
shortbool  Debug_RfpEnable_58                       ; // false 
shortbool  Debug_RfpEnable_5A                       ; // false 
shortbool  Debug_RfpEnable_5C                       ; // false 
shortbool  Debug_RfpEnable_5E                       ; // false 
shortbool  Debug_RfpEnable_60                       ; // false 
shortbool  Debug_RfpEnable_62                       ; // false 
shortbool  Debug_RfpEnable_64                       ; // false 
shortbool  Debug_RfpEnable_66                       ; // false 
shortbool  Debug_RfpEnable_68                       ; // false 
shortbool  Debug_RfpEnable_6A                       ; // false 
shortbool  Debug_RfpEnable_6C                       ; // false 
shortbool  Debug_RfpEnable_6E                       ; // false 
shortbool  Debug_RfpEnable_70                       ; // false 
shortbool  Debug_RfpEnable_72                       ; // false 
shortbool  Debug_RfpEnable_74                       ; // false 
shortbool  Debug_RfpEnable_76                       ; // false 
shortbool  Debug_RfpEnable_78                       ; // false 
shortbool  Debug_RfpEnable_7A                       ; // false 
shortbool  Debug_RfpEnable_7C                       ; // false 
shortbool  Debug_RfpEnable_7E                       ; // false 
shortbool  System_ForceHciUsingUartInterface        ; // false 
shortbool  System_UsbSidebandSig                    ; // false 
shortbool  System_Class1                            ; // false 
shortbool  LM_Feature0_00_3_SLOT_PKT                ; // true 
shortbool  LM_Feature0_01_5_SLOT_PKT                ; // true 
shortbool  LM_Feature0_02_ENCRYPTION                ; // true 
shortbool  LM_Feature0_03_SLOT_OFFSET               ; // true 
shortbool  LM_Feature0_04_TIMING_ACCURACY           ; // true 
shortbool  LM_Feature0_05_SWITCH                    ; // true 
shortbool  LM_Feature0_06_HOLD_MODE                 ; // true 
shortbool  LM_Feature0_07_SNIFF_MODE                ; // true 
shortbool  LM_Feature1_00_PARK_MODE                 ; // true 
shortbool  LM_Feature1_01_RSSI                      ; // true 
shortbool  LM_Feature1_02_CHANN_QUAL_DATA_RATE      ; // true 
shortbool  LM_Feature1_03_SCO_LINK                  ; // true 
shortbool  LM_Feature1_04_HV2_PKT                   ; // true 
shortbool  LM_Feature1_05_HV3_PKT                   ; // true 
shortbool  LM_Feature1_06_U_LAW                     ; // true 
shortbool  LM_Feature1_07_A_LAW                     ; // true 
shortbool  LM_Feature2_00_CVSD                      ; // true 
shortbool  LM_Feature2_01_PAGING_SCHEME             ; // false 
shortbool  LM_Feature2_02_POWER_CONTROL             ; // true 
shortbool  LM_Feature2_03_TRANS_SCO_DATA            ; // false 
shortbool  LM_Feature2_04_FLOW_CONTROL_LAG_0        ; // false 
shortbool  LM_Feature2_05_FLOW_CONTROL_LAG_1        ; // false 
shortbool  LM_Feature2_06_FLOW_CONTROL_LAG_2        ; // false 
shortbool  LM_Feature2_07_BCAST_ENCRYPTION          ; // true 
shortbool  LM_Feature3_00_SCATTER_MODE              ; // true 
shortbool  LM_Feature3_03_ENHANCED_1STFHS_INQ_SCAN  ; // true 
shortbool  LM_Feature3_04_INTERLACED_INQ_SCAN       ; // true 
shortbool  LM_Feature3_05_INTERLACED_PAGE_SCAN      ; // true 
shortbool  LM_Feature3_06_INQ_RESULT_WITH_RSSI      ; // true 
shortbool  LM_Feature3_07_EXTENDED_SCO_EV3          ; // true 
shortbool  LM_Feature4_00_EXTENDED_SCO_EV4          ; // true 
shortbool  LM_Feature4_01_EXTENDED_SCO_EV5          ; // true 
shortbool  LM_Feature4_02_ABSENCE_MASKS             ; // false 
shortbool  LM_Feature4_03_AFH_CAPABLE_SLAVE         ; // true 
shortbool  LM_Feature4_04_AFH_CLASSFN_SLAVE         ; // true 
shortbool  LM_Feature4_05_ALIAS_AUTHENTICATION      ; // false 
shortbool  LM_Feature4_06_ANONYMITY_MODE            ; // true 
shortbool  LM_Feature5_03_AFH_CAPABLE_MASTER        ; // true 
shortbool  LM_Feature5_04_AFH_CLASSFN_MASTER        ; // true 
shortbool  LM_Feature7_07_EXTENDED_FEATURES         ; // false 
shortbool  Uls_BTE_FECLock                          ; // false 
shortbool  L2_EnableRaw                             ; // true 
shortbool  SDP_Enable                               ; // true 
shortbool  RFC_Enable                               ; // true 
shortbool  HS_SetHeadSetRoleToAG                    ; // false 
shortbool  BNEP_Enable                              ; // false 
shortbool  HIDAPP_NormallyConnectable               ; // true 
shortbool  HIDAPP_MouseEnabled                      ; // true 
shortbool  HIDAPP_MouseReconnectInit                ; // true 
shortbool  HIDAPP_KeyboardEnabled                   ; // false 
shortbool  HIDAPP_KeyboardReconnectInit             ; // true 
shortbool  Temp_UlsTest_00                          ; // false 
shortbool  Temp_UlsTest_01                          ; // false 
shortbool  Temp_UlsTest_02                          ; // false 
shortbool  Temp_UlsTest_03                          ; // false 
shortbool  Temp_UlsTest_04                          ; // false 
shortbool  Temp_UlsTest_05                          ; // false 
uint8      System_UartDefaultBaud                   ; // 8        : 0x8       
uint8      System_UartDmaFlushThreshold             ; // 8        : 0x8       
uint8      System_UartDmaRtsThreshold               ; // 10       : 0xa       
uint8      ZR_Flags                                 ; // 1        : 0x1       
uint8      ZR_CodByte2                              ; // 0        : 0x0       
uint8      ZR_CodByte1                              ; // 0        : 0x0       
uint8      ZR_CodByte0                              ; // 0        : 0x0       
uint8      ZR_ZerialName0                           ; // 90       : 0x5a      
uint8      ZR_ZerialName1                           ; // 101      : 0x65      
uint8      ZR_ZerialName2                           ; // 101      : 0x65      
uint8      ZR_ZerialName3                           ; // 118      : 0x76      
uint8      ZR_ZerialName4                           ; // 111      : 0x6f      
uint8      ZR_ZerialName5                           ; // 69       : 0x45      
uint8      ZR_ZerialName6                           ; // 109      : 0x6d      
uint8      ZR_ZerialName7                           ; // 98       : 0x62      
uint8      ZR_ZerialName8                           ; // 101      : 0x65      
uint8      ZR_ZerialName9                           ; // 100      : 0x64      
uint8      ZR_ZerialName10                          ; // 100      : 0x64      
uint8      ZR_ZerialName11                          ; // 101      : 0x65      
uint8      ZR_ZerialName12                          ; // 100      : 0x64      
uint8      ZR_ZerialName13                          ; // 68       : 0x44      
uint8      ZR_ZerialName14                          ; // 101      : 0x65      
uint8      ZR_ZerialName15                          ; // 118      : 0x76      
uint8      ZR_ZerialName16                          ; // 105      : 0x69      
uint8      ZR_ZerialName17                          ; // 99       : 0x63      
uint8      ZR_ZerialName18                          ; // 101      : 0x65      
uint8      ZR_ZerialName19                          ; // 0        : 0x0       
uint8      Zerial_PIN0                              ; // 49       : 0x31      
uint8      Zerial_PIN1                              ; // 50       : 0x32      
uint8      Zerial_PIN2                              ; // 51       : 0x33      
uint8      Zerial_PIN3                              ; // 52       : 0x34      
uint8      Zerial_PIN4                              ; // 0        : 0x0       
uint8      Zerial_PIN5                              ; // 0        : 0x0       
uint8      Zerial_PIN6                              ; // 0        : 0x0       
uint8      Zerial_PIN7                              ; // 0        : 0x0       
uint8      Zerial_PIN8                              ; // 0        : 0x0       
uint8      Zerial_PIN9                              ; // 0        : 0x0       
uint8      Zerial_PIN10                             ; // 0        : 0x0       
uint8      Zerial_PIN11                             ; // 0        : 0x0       
uint8      Zerial_PIN12                             ; // 0        : 0x0       
uint8      Zerial_PIN13                             ; // 0        : 0x0       
uint8      Zerial_PIN14                             ; // 0        : 0x0       
uint8      Zerial_PIN15                             ; // 0        : 0x0       
uint8      HTL_GeneralShortBufNum                   ; // 12       : 0xc       
uint8      HTL_GeneralLongBufNum                    ; // 2        : 0x2       
uint8      BP_BufMemPoolBlocks                      ; // 0        : 0x0       
uint8      GKI_Buf0_Max                             ; // 5        : 0x5       
uint8      GKI_Buf1_Max                             ; // 2        : 0x2       
uint8      GKI_Buf2_Max                             ; // 10       : 0xa       
uint8      GKI_Buf3_Max                             ; // 2        : 0x2       
uint8      GKI_Buf4_Max                             ; // 5        : 0x5       
uint8      TS_PrintfBufNum                          ; // 8        : 0x8       
uint8      HTL_ToLmNoOfBuffers                      ; // 12       : 0xc       
uint8      HTL_ToLmDataBufferHeaderSize             ; // 64       : 0x40      
uint8      HTL_ToLmNoOfScoBuffers                   ; // 12       : 0xc       
uint8      HTL_ToLmScoBufferHeaderSize              ; // 32       : 0x20      
uint8      BBD_Codec                                ; // 3        : 0x3       
uint8      LM_NoOfDataBuffers                       ; // 14       : 0xe       
uint8      LM_UpperHeadSize                         ; // 72       : 0x48      
uint8      LM_NOfRxScoBuffers                       ; // 6        : 0x6       
uint8      LM_NOfRxScoHeaderSize                    ; // 72       : 0x48      
uint8      LM_MaxNoLinksAllowed                     ; // 10       : 0xa       
uint8      LM_MaxNoOfParkedSlaves                   ; // 10       : 0xa       
uint8      LM_NoOfBNCB                              ; // 20       : 0x14      
uint8      LM_SchedulingType                        ; // 0        : 0x0       
uint8      ULS_MaxNoTxBufs                          ; // 20       : 0x14      
uint8      ULS_NoOfDataBufs                         ; // 1        : 0x1       
uint8      ULS_NoP2pBufs                            ; // 10       : 0xa       
uint8      L2_MaxLLCons                             ; // 7        : 0x7       
uint8      L2_RawHeaderSize                         ; // 9        : 0x9       
uint8      L2_MaxNoUpperLayers                      ; // 5        : 0x5       
uint8      L2_MaxNoCons                             ; // 10       : 0xa       
uint8      L2_UseTimers                             ; // 1        : 0x1       
uint8      L2_UseLLDiscTimer                        ; // 1        : 0x1       
uint8      SDP_NoOfServiceRecords                   ; // 2        : 0x2       
uint8      RFC_NoProfilesSupported                  ; // 10       : 0xa       
uint8      RFC_MaxNoOfCons                          ; // 10       : 0xa       
uint8      Stuffing_0                               ; // alignment 
uint8      Stuffing_1                               ; // alignment 
uint8      Stuffing_2                               ; // alignment 
uint16     System_12MCrystalWakeupDelay_TC2000      ; // 32       : 0x20      
uint16     System_12MCrystalWakeupDelay_TC2001      ; // 13       : 0xd       
uint16     System_12MCrystalWakeupDelay_ZV4002      ; // 13       : 0xd       
uint16     System_DeepSleepSwWakeupDelay            ; // 4        : 0x4       
uint16     Debug_RfpValue__34                       ; // 0        : 0x0       
uint16     Debug_RfpValue__34_Late                  ; // 0        : 0x0       
uint16     Debug_RfpValue__40                       ; // 0        : 0x0       
uint16     Debug_RfpValue__42                       ; // 0        : 0x0       
uint16     Debug_RfpValue__44                       ; // 0        : 0x0       
uint16     Debug_RfpValue__46                       ; // 0        : 0x0       
uint16     Debug_RfpValue__48                       ; // 0        : 0x0       
uint16     Debug_RfpValue__4A                       ; // 0        : 0x0       
uint16     Debug_RfpValue__4C                       ; // 0        : 0x0       
uint16     Debug_RfpValue__4E                       ; // 0        : 0x0       
uint16     Debug_RfpValue__50                       ; // 0        : 0x0       
uint16     Debug_RfpValue__52                       ; // 0        : 0x0       
uint16     Debug_RfpValue__54                       ; // 0        : 0x0       
uint16     Debug_RfpValue__56                       ; // 0        : 0x0       
uint16     Debug_RfpValue__58                       ; // 0        : 0x0       
uint16     Debug_RfpValue__5A                       ; // 0        : 0x0       
uint16     Debug_RfpValue__5C                       ; // 0        : 0x0       
uint16     Debug_RfpValue__5E                       ; // 0        : 0x0       
uint16     Debug_RfpValue__60                       ; // 0        : 0x0       
uint16     Debug_RfpValue__62                       ; // 0        : 0x0       
uint16     Debug_RfpValue__64                       ; // 0        : 0x0       
uint16     Debug_RfpValue__66                       ; // 0        : 0x0       
uint16     Debug_RfpValue__68                       ; // 0        : 0x0       
uint16     Debug_RfpValue__6A                       ; // 0        : 0x0       
uint16     Debug_RfpValue__6C                       ; // 0        : 0x0       
uint16     Debug_RfpValue__6E                       ; // 0        : 0x0       
uint16     Debug_RfpValue__70                       ; // 0        : 0x0       
uint16     Debug_RfpValue__72                       ; // 0        : 0x0       
uint16     Debug_RfpValue__74                       ; // 0        : 0x0       
uint16     Debug_RfpValue__76                       ; // 0        : 0x0       
uint16     Debug_RfpValue__78                       ; // 0        : 0x0       
uint16     Debug_RfpValue__7A                       ; // 0        : 0x0       
uint16     Debug_RfpValue__7C                       ; // 0        : 0x0       
uint16     Debug_RfpValue__7E                       ; // 0        : 0x0       
uint16     System_UsbVid                            ; // 2938     : 0xb7a     
uint16     System_UsbPid                            ; // 2000     : 0x7d0     
uint16     System_MaxNumOfTimers                    ; // 20       : 0x14      
uint16     System_NonGPIOPadResisterCfg             ; // 0        : 0x0       
uint16     System_GPIOPadResisterCfg                ; // 0        : 0x0       
uint16     System_XramEndHighAddr                   ; // 64       : 0x40      
uint16     HTL_GeneralShortBufSize                  ; // 120      : 0x78      
uint16     HTL_GeneralLongBufSize                   ; // 400      : 0x190     
uint16     BP_BufMemPoolBlockSize                   ; // 0        : 0x0       
uint16     TS_PrintfBufSize                         ; // 70       : 0x46      
uint16     HTL_ToLmDataBufferSize                   ; // 400      : 0x190     
uint16     HTL_ToLmScoBufferSize                    ; // 120      : 0x78      
uint16     HTL_ScoDropThreshold                     ; // 100      : 0x64      
uint16     BBD_ScoAddSampleThreshold                ; // 4        : 0x4       
uint16     BBD_ScoDropSampleThreshold               ; // 8        : 0x8       
uint16     BBD_ScoDropBufThreshold                  ; // 100      : 0x64      
uint16     BBD_Tpoll                                ; // 20       : 0x14      
uint16     LM_DataBodySize                          ; // 393      : 0x189     
uint16     LM_NOfRxScoBodySize                      ; // 240      : 0xf0      
uint16     LM_LinkSupervisionTimeout                ; // 32000    : 0x7d00    
uint16     ULS_DataBufferSize                       ; // 1        : 0x1       
uint16     ULS_P2pBufSize                           ; // 370      : 0x172     
uint16     L2_MaxInMtu                              ; // 335      : 0x14f     
uint16     SDP_ServiceRecordMaxSize                 ; // 200      : 0xc8      
uint16     BNEP_L2Mtu                               ; // 1691     : 0x69b     
uint8      Stuffing_3                               ; // alignment 
uint8      Stuffing_4                               ; // alignment 
uint32     Version                                  ; // 0        : 0x0       
uint32     Debug_MuxGroup                           ; // 0        : 0x0       
uint32     Debug_MuxGpio                            ; // 0        : 0x0       
uint32     Debug_MaxLogSize                         ; // 5000     : 0x1388    
} t_ZvDynamicCfg ; 


extern t_ZvDynamicCfg *pZvDynamicCfg; 
#endif // __ZvDynamicConfig__H

