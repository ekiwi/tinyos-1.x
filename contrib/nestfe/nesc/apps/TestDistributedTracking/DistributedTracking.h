/*									tab:2
 * "Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 */

/*
 * @author Michael Manzo <mpm@eecs.berkeley.edu>
 */

enum {
  DEFAULT_SIMPLE_THRESHOLD = 3000,
#ifdef CALCULATE_NEIGHBORS_BY_DISTANCE
  NBRS_RADIUS = 49, // 7^2 should catch all of them.
#endif
  MAX_TRACK_LENGTH = 8,
  MAX_LOCATIONS_PER_MESSAGE = 8,
#ifdef CALCULATE_NEIGHBORS_BY_DISTANCE
  MAX_NBRHOOD_SIZE = 8,
#else
  MAX_NBRHOOD_SIZE = 4,
  MAX_NUM_NODES = 36,
  // Wouldn't need this if I weren't too lazy to find or write a sqrt function:
  MAX_NUM_NODES_SQRT = 6,
#endif
  //PERIOD_TO_WAIT_FOR_TIME_SYNC_VALIDITY = 1024, // binary milliseconds
  //PERIOD_TO_WAIT_FOR_TIME_SYNC_VALIDITY = 5120, // 5 sec in binary milliseconds
  //PERIOD_TO_WAIT_FOR_TIME_SYNC_VALIDITY = 10240, // 10 sec in binary milliseconds
  PERIOD_TO_WAIT_FOR_TIME_SYNC_VALIDITY = 15360, // 15 sec in binary milliseconds
  //DEFAULT_TRACKING_PERIOD = 512, // binary milliseconds
  DEFAULT_TRACKING_PERIOD = 1024, // binary milliseconds
  MIN_TRACKING_PERIOD = 128, // binary milliseconds
  MAX_TRACKING_PERIOD = 5120, // binary milliseconds
  //DEFAULT_BACKTRACKING_PERIOD = 512, // binary milliseconds. 
  //DEFAULT_BACKTRACKING_PERIOD = 1024, // binary milliseconds. 
  DEFAULT_BACKTRACKING_PERIOD = 1024, // binary milliseconds. 
  MIN_BACKTRACKING_PERIOD = 128, // binary milliseconds. 
  MAX_BACKTRACKING_PERIOD = 5120, // binary milliseconds. 
};

enum {
  AM_TRACKCMDMSG = 96, // == 60 in hex
  AM_REPORTTRACKMSG = 97, // == 61 in hex
  AM_BACKTRACKINGMSG = 98, // == 62 in hex
  AM_TRACKINGMSG = 99, // == 63 in hex
#ifdef SEND_TRACKING_DEBUG_MSGS
  AM_TRACKINGDEBUGMSG = 101, // == 65 in hex
#endif
#ifdef SEND_BACKTRACKING_DEBUG_MSGS
  AM_BACKTRACKINGDEBUGMSG = 102, // == 66 in hex
#endif
#ifdef USE_FAKE_DETECTIONS
  AM_FAKEDETECTIONSMSG = 103, // == 67 in hex
#endif
};

enum {
  SINGLE_BACKTRACK = 3,
  START_TRACKING = 4,
};

typedef struct TrackingCmdMsg {
  uint16_t cmd;
  // period is used for Track.startRepeatTrackReport
  uint16_t requester; // so the end-point knows who to send it back to.
#ifdef USE_TOSBASE_AS_HEARTBEAT
  uint16_t myThreshold;
  uint32_t trackingPeriod;
  uint32_t backtrackingPeriod;
  uint16_t trackLength;
#endif
} TrackingCmdMsg;

#ifdef USE_FAKE_DETECTIONS
typedef struct FakeDetectionsMsg {
  uint16_t detections[MAX_LOCATIONS_PER_MESSAGE];
} FakeDetectionsMsg;
#endif

#ifdef SEND_TRACKING_DEBUG_MSGS
typedef struct TrackingDebugMsg {
  uint16_t time;
  uint16_t origin;
  uint16_t numNbrTrackingMsgsReceived;
#ifdef CALCULATE_NEIGHBORS_BY_DISTANCE
  uint16_t currentNumNbrs;
#endif
  uint16_t lastConfidence;
  uint16_t anyUpdateOccured;
  uint16_t track[MAX_LOCATIONS_PER_MESSAGE];
} TrackingDebugMsg;
#endif

typedef struct TrackingMsg {
  float delta; 
  float lastBestDelta; // XXX: for debugging  
#ifdef CALCULATE_NEIGHBORS_BY_DISTANCE
  int32_t xLocation;
  int32_t yLocation;
#endif
  uint16_t origin;
  // trackingTime should be used in the same way as BacktrackingTime:
  uint16_t trackingTime;
  uint16_t bestNbr;
  uint8_t detectionOccured;
} TrackingMsg;

typedef struct ReportTrackMsg {
  float delta;
  uint16_t seqNo; 
  uint16_t track [MAX_LOCATIONS_PER_MESSAGE];
  // index_of_first_location is the index of the first location in this
  // message as it appears in the longer track, which is MAX_TRACK_LENGTH long.
  // XXX: uh, what was I talking about? I don't see the purpose of 
  // index_of_first_location, so I'm commenting it out.
  //uint8_t index_of_first_location;
} ReportTrackMsg;

#ifdef SEND_BACKTRACKING_DEBUG_MSGS
typedef struct BacktrackingDebugMsg {
  uint16_t time;
  uint16_t origin;
  uint16_t track[MAX_LOCATIONS_PER_MESSAGE];
} BacktrackingDebugMsg;
#endif

typedef struct BacktrackingMsg {
  float delta;
  uint16_t track [MAX_LOCATIONS_PER_MESSAGE];
  // backtrackingTime is used so the nodes know if the BacktrackingMsgs
  // they get are from the current (i.e. correct) backtracking time step
  uint16_t origin;
  // !!!: Be careful about the order of the elements of these structs,
  // since I think the compiler is putting the elements on 16-bit
  // boundaries and that gets messed up somewhere before the message
  // is read by the receiver.
  uint16_t backtrackingTime;
  uint16_t numNbrsReportedBacktracking;
} BacktrackingMsg;

// A terrible hack until we get RegistryStore working or use an RSSI-based neighborhood generation
// scheme.
int locations[684][3] = {
{1001,30,40},
{1001,30,40},
{1002,30,45},
{1002,30,45},
{1003,30,50},
{1003,30,50},
{1004,30,55},
{1004,30,55},
{1005,30,60},
{1005,30,60},
{1006,30,65},
{1006,30,65},
{1007,30,70},
{1007,30,70},
{1008,30,75},
{1008,30,75},
{1009,30,80},
{1009,30,80},
{1010,30,85},
{1010,30,85},
{1011,30,90},
{1011,30,90},
{1012,35,40},
{1012,35,40},
{1013,35,45},
{1013,35,45},
{1014,35,50},
{1014,35,50},
{1015,35,55},
{1015,35,55},
{1016,35,60},
{1016,35,60},
{1017,35,65},
{1017,35,65},
{1018,35,70},
{1018,35,70},
{1019,35,75},
{1019,35,75},
{1020,35,80},
{1020,35,80},
{1021,35,85},
{1021,35,85},
{1022,35,90},
{1022,35,90},
{1023,40,40},
{1023,40,40},
{1024,40,45},
{1024,40,45},
{1025,40,50},
{1025,40,50},
{1026,40,55},
{1026,40,55},
{1027,40,60},
{1027,40,60},
{1028,40,65},
{1028,40,65},
{1029,40,70},
{1029,40,70},
{1030,40,75},
{1030,40,75},
{1031,40,80},
{1031,40,80},
{1032,40,85},
{1032,40,85},
{1033,40,90},
{1033,40,90},
{1034,45,40},
{1034,45,40},
{1035,45,45},
{1035,45,45},
{1036,45,50},
{1036,45,50},
{1037,45,55},
{1037,45,55},
{1038,45,60},
{1038,45,60},
{1039,45,65},
{1039,45,65},
{1040,45,70},
{1040,45,70},
{1041,45,75},
{1041,45,75},
{1042,45,80},
{1042,45,80},
{1043,45,85},
{1043,45,85},
{1044,45,90},
{1044,45,90},
{1045,50,40},
{1045,50,40},
{1046,50,45},
{1046,50,45},
{1047,50,50},
{1047,50,50},
{1048,50,55},
{1048,50,55},
{1049,50,60},
{1049,50,60},
{1050,50,65},
{1050,50,65},
{1051,50,70},
{1051,50,70},
{1052,50,75},
{1052,50,75},
{1053,50,80},
{1053,50,80},
{1054,50,85},
{1054,50,85},
{1055,50,90},
{1055,50,90},
{1056,55,40},
{1056,55,40},
{1057,55,45},
{1057,55,45},
{1058,55,50},
{1058,55,50},
{1059,55,55},
{1059,55,55},
{1060,55,60},
{1060,55,60},
{1061,55,65},
{1061,55,65},
{1062,55,70},
{1062,55,70},
{1063,55,75},
{1063,55,75},
{1064,55,80},
{1064,55,80},
{1065,55,85},
{1065,55,85},
{1066,55,90},
{1066,55,90},
{1067,60,40},
{1067,60,40},
{1068,60,45},
{1068,60,45},
{1069,60,50},
{1069,60,50},
{1070,60,55},
{1070,60,55},
{1071,60,60},
{1071,60,60},
{1072,60,65},
{1072,60,65},
{1073,60,70},
{1073,60,70},
{1074,60,75},
{1074,60,75},
{1075,60,80},
{1075,60,80},
{1076,60,85},
{1076,60,85},
{1077,60,90},
{1077,60,90},
{1078,65,40},
{1078,65,40},
{1079,65,45},
{1079,65,45},
{1080,65,50},
{1080,65,50},
{1081,65,55},
{1081,65,55},
{1082,65,60},
{1082,65,60},
{1083,65,65},
{1083,65,65},
{1084,65,70},
{1084,65,70},
{1085,65,75},
{1085,65,75},
{1086,65,80},
{1086,65,80},
{1087,65,85},
{1087,65,85},
{1088,65,90},
{1088,65,90},
{1089,70,40},
{1089,70,40},
{1090,70,45},
{1090,70,45},
{1091,70,50},
{1091,70,50},
{1092,70,55},
{1092,70,55},
{1093,70,60},
{1093,70,60},
{1094,70,65},
{1094,70,65},
{1095,70,70},
{1095,70,70},
{1096,70,75},
{1096,70,75},
{1097,70,80},
{1097,70,80},
{1098,70,85},
{1098,70,85},
{1099,70,90},
{1099,70,90},
{1101,5,40},
{1101,5,40},
{1102,5,45},
{1102,5,45},
{1103,5,50},
{1103,5,50},
{1104,5,55},
{1104,5,55},
{1105,5,60},
{1105,5,60},
{1106,5,65},
{1106,5,65},
{1107,5,70},
{1107,5,70},
{1108,5,75},
{1108,5,75},
{1109,5,80},
{1109,5,80},
{1110,5,85},
{1110,5,85},
{1111,10,40},
{1111,10,40},
{1112,10,45},
{1112,10,45},
{1113,10,50},
{1113,10,50},
{1114,10,55},
{1114,10,55},
{1115,10,60},
{1115,10,60},
{1116,10,65},
{1116,10,65},
{1117,10,70},
{1117,10,70},
{1118,10,75},
{1118,10,75},
{1119,10,80},
{1119,10,80},
{1120,10,85},
{1120,10,85},
{1121,15,40},
{1121,15,40},
{1122,15,45},
{1122,15,45},
{1123,15,50},
{1123,15,50},
{1124,15,55},
{1124,15,55},
{1125,15,60},
{1125,15,60},
{1126,15,65},
{1126,15,65},
{1127,15,70},
{1127,15,70},
{1128,15,75},
{1128,15,75},
{1129,15,80},
{1129,15,80},
{1130,15,85},
{1130,15,85},
{1131,20,40},
{1131,20,40},
{1132,20,45},
{1132,20,45},
{1133,20,50},
{1133,20,50},
{1134,20,55},
{1134,20,55},
{1135,20,60},
{1135,20,60},
{1136,20,65},
{1136,20,65},
{1137,20,70},
{1137,20,70},
{1138,20,75},
{1138,20,75},
{1139,20,80},
{1139,20,80},
{1140,20,85},
{1140,20,85},
{1141,25,40},
{1141,25,40},
{1142,25,45},
{1142,25,45},
{1143,25,50},
{1143,25,50},
{1144,25,55},
{1144,25,55},
{1145,25,60},
{1145,25,60},
{1146,25,65},
{1146,25,65},
{1147,25,70},
{1147,25,70},
{1148,25,75},
{1148,25,75},
{1149,25,80},
{1149,25,80},
{1150,25,85},
{1150,25,85},
{1151,0,0},
{1151,0,0},
{1152,0,5},
{1152,0,5},
{1153,0,10},
{1153,0,10},
{1154,0,15},
{1154,0,15},
{1155,0,20},
{1155,0,20},
{1156,0,25},
{1156,0,25},
{1157,0,30},
{1157,0,30},
{1158,0,35},
{1158,0,35},
{1159,5,0},
{1159,5,0},
{1160,5,5},
{1160,5,5},
{1161,5,10},
{1161,5,10},
{1162,5,15},
{1162,5,15},
{1163,5,20},
{1163,5,20},
{1164,5,25},
{1164,5,25},
{1165,5,30},
{1165,5,30},
{1166,5,35},
{1166,5,35},
{1167,10,0},
{1167,10,0},
{1168,10,5},
{1168,10,5},
{1169,10,10},
{1169,10,10},
{1170,10,15},
{1170,10,15},
{1171,10,20},
{1171,10,20},
{1172,10,25},
{1172,10,25},
{1173,10,30},
{1173,10,30},
{1174,10,35},
{1174,10,35},
{1175,15,0},
{1175,15,0},
{1176,15,5},
{1176,15,5},
{1177,15,10},
{1177,15,10},
{1178,15,15},
{1178,15,15},
{1179,15,20},
{1179,15,20},
{1180,15,25},
{1180,15,25},
{1181,15,30},
{1181,15,30},
{1182,15,35},
{1182,15,35},
{1183,20,0},
{1183,20,0},
{1184,20,5},
{1184,20,5},
{1185,20,10},
{1185,20,10},
{1186,20,15},
{1186,20,15},
{1187,20,20},
{1187,20,20},
{1188,20,25},
{1188,20,25},
{1189,20,30},
{1189,20,30},
{1190,20,35},
{1190,20,35},
{1191,25,0},
{1191,25,0},
{1192,25,5},
{1192,25,5},
{1193,25,10},
{1193,25,10},
{1194,25,15},
{1194,25,15},
{1195,25,20},
{1195,25,20},
{1196,25,25},
{1196,25,25},
{1197,25,30},
{1197,25,30},
{1198,25,35},
{1198,25,35},
{1199,30,5},
{1199,30,5},
{1200,30,10},
{1200,30,10},
{1201,30,15},
{1201,30,15},
{1202,30,20},
{1202,30,20},
{1203,30,25},
{1203,30,25},
{1204,30,30},
{1204,30,30},
{1205,30,35},
{1205,30,35},
{1206,35,0},
{1206,35,0},
{1207,35,5},
{1207,35,5},
{1208,35,10},
{1208,35,10},
{1209,35,15},
{1209,35,15},
{1210,35,20},
{1210,35,20},
{1211,35,25},
{1211,35,25},
{1212,35,30},
{1212,35,30},
{1213,35,35},
{1213,35,35},
{1214,40,0},
{1214,40,0},
{1215,40,5},
{1215,40,5},
{1216,40,10},
{1216,40,10},
{1217,40,15},
{1217,40,15},
{1218,40,20},
{1218,40,20},
{1219,40,25},
{1219,40,25},
{1220,40,30},
{1220,40,30},
{1221,40,35},
{1221,40,35},
{1222,45,0},
{1222,45,0},
{1223,45,5},
{1223,45,5},
{1224,45,10},
{1224,45,10},
{1225,45,15},
{1225,45,15},
{1226,45,20},
{1226,45,20},
{1227,45,25},
{1227,45,25},
{1228,45,30},
{1228,45,30},
{1229,45,35},
{1229,45,35},
{1230,50,0},
{1230,50,0},
{1231,50,5},
{1231,50,5},
{1232,50,10},
{1232,50,10},
{1233,50,15},
{1233,50,15},
{1234,50,20},
{1234,50,20},
{1235,50,25},
{1235,50,25},
{1236,50,30},
{1236,50,30},
{1237,50,35},
{1237,50,35},
{1238,55,0},
{1238,55,0},
{1239,55,5},
{1239,55,5},
{1240,55,10},
{1240,55,10},
{1241,55,15},
{1241,55,15},
{1242,55,20},
{1242,55,20},
{1243,55,25},
{1243,55,25},
{1244,55,30},
{1244,55,30},
{1245,55,35},
{1245,55,35},
{1246,60,0},
{1246,60,0},
{1247,60,5},
{1247,60,5},
{1248,60,10},
{1248,60,10},
{1249,60,15},
{1249,60,15},
{1250,60,20},
{1250,60,20},
{1251,60,25},
{1251,60,25},
{1252,60,30},
{1252,60,30},
{1253,60,35},
{1253,60,35},
{1254,65,0},
{1254,65,0},
{1255,65,5},
{1255,65,5},
{1256,65,10},
{1256,65,10},
{1257,65,15},
{1257,65,15},
{1258,65,20},
{1258,65,20},
{1259,65,25},
{1259,65,25},
{1260,65,30},
{1260,65,30},
{1261,65,35},
{1261,65,35},
{1262,70,0},
{1262,70,0},
{1263,70,5},
{1263,70,5},
{1264,70,10},
{1264,70,10},
{1265,70,15},
{1265,70,15},
{1266,70,20},
{1266,70,20},
{1267,70,25},
{1267,70,25},
{1268,70,30},
{1268,70,30},
{1269,70,35},
{1269,70,35},
{1271,-5,40},
{1271,-5,40},
{1272,-5,45},
{1272,-5,45},
{1273,-5,50},
{1273,-5,50},
{1274,-5,55},
{1274,-5,55},
{1275,-5,60},
{1275,-5,60},
{1276,-5,65},
{1276,-5,65},
{1277,-5,70},
{1277,-5,70},
{1278,-5,75},
{1278,-5,75},
{1279,-5,80},
{1279,-5,80},
{1280,-5,85},
{1280,-5,85},
{1281,0,40},
{1281,0,40},
{1282,0,45},
{1282,0,45},
{1283,0,50},
{1283,0,50},
{1284,0,55},
{1284,0,55},
{1285,0,60},
{1285,0,60},
{1286,0,65},
{1286,0,65},
{1287,0,70},
{1287,0,70},
{1288,0,75},
{1288,0,75},
{1289,0,80},
{1289,0,80},
{1290,0,85},
{1290,0,85},
{1093,-100,0},
{1188,-90,0},
{1094,-80,0},
{1205,-70,0},
{1181,-60,0},
{1100,-50,0},
{1094,-40,0},
{1096,-30,0},
{1314,-20,0},
{1315,-20,10},
{1316,-20,20},
{1317,-20,30},
{1318,-20,40},
{1319,-20,50},
{1320,-10,0},
{1321,-10,10},
{1322,-10,20},
{1323,-10,30},
{1334,-10,40},
{1335,-10,50},
{1326,0,0},
{1327,0,10},
{1328,0,20},
{1329,0,30},
{1330,0,40},
{1331,0,50},
{1332,10,10},
{1333,10,30},
{1334,10,40},
{1335,10,50},
{1336,10,60},
{1337,10,70},
{1338,10,80},
{1339,10,90},
{1340,10,100},
{1341,10,110},
{1342,10,120},
{1343,10,130},
{1344,10,140},
{1345,10,150},
{1346,10,160},
{1347,10,170},
{1348,10,180},
{1349,20,60},
{1350,20,70},
{1351,20,80},
{1352,20,90},
{1353,20,100},
{1354,20,110},
{1356,20,130},
{1357,20,140},
{1358,20,150},
{1359,20,160},
{1360,20,170},
{1361,20,180},
{1362,30,60},
{1363,30,70},
{1364,30,80},
{1365,30,90},
{1366,30,100},
{1367,30,110},
{1368,30,120},
{1369,25,120},
{1370,25,130},
{1371,25,140},
{1372,25,150},
{1373,25,160},
{1374,25,170},
{1375,25,180},
{1376,25,190},
{1378,40,60},
{1379,40,70},
{1380,40,80},
{1381,40,90},
{1382,40,100},
{1383,40,110},
{1413,0,0},
{1412,0,-5},
{1411,0,-10},
{1414,0,-15},
{1415,0,-20},
{1416,0,-25},
{1417,0,-30},
{1418,0,-35},
{1419,0,-40},
{1420,0,-45},
{1421,0,-50},
{1293,-5,0},
{1294,-10,0},
{1295,-15,0},
{1296,-20,0},
{1297,-25,0},
{1298,-30,0},
{1299,-35,0},
{1300,-5,-5},
{1301,-10,-5},
{1302,-15,-5},
{1303,-20,-5},
{1304,-25,-5},
{1305,-30,-5},
{1306,-35,-5},
{1307,-5,-10},
{1308,-10,-10},
{1309,-15,-10},
{1310,-20,-10},
{1311,-25,-10},
{1312,-30,-10},
{1313,-35,-10},
};
