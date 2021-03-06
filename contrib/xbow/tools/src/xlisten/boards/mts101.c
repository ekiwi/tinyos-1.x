/**
 * Handles conversion to engineering units of mts101 packets.
 *
 * @file      mts101.c
 * @author    Hu Siquan
 * @version   2004/4/12    husq      Initial version
 *
 * Refer to:
 *   -  Xbow MTS/MDA Sensor and DataAcquistion Manual  
 *
 * Copyright (c) 2004 Crossbow Technology, Inc.   All rights reserved.
 * 
 * $Id: mts101.c,v 1.7 2005/02/01 18:11:11 mturon Exp $
 */

#include <math.h>
#include "../xsensors.h"

/** MTS101 XSensor packet 1 -- contains battery, thermistor, and adc2-7. */
typedef struct {
	uint16_t battery;
    uint16_t thermistor;
    uint16_t light;
} XSensorMTS101Data;

extern XPacketHandler mts101_packet_handler;

/** 
 * Converts mica2 battery reading from raw ADC data to engineering units.
 *
 * @author    Martin Turon
 *
 * To compute the battery voltage after measuring the voltage ref:
 *   BV = RV*ADC_FS/data
 *   where:
 *   BV = Battery Voltage
 *   ADC_FS = 1023
 *   RV = Voltage Reference for mica2 (1.223 volts)
 *   data = data from the adc measurement of channel 1
 *   BV (volts) = 1252.352/data
 *   BV (mv) = 1252352/data 
 *
 * Note:
 *   The thermistor resistance to temperature conversion is highly non-linear.
 *
 * @version   2004/3/29       mturon      Initial revision
 *
 */
uint16_t mts101_convert_battery(XbowSensorboardPacket *packet) 
{
    XSensorMTS101Data *data = (XSensorMTS101Data *)packet->data;
    float    x     = (float)data->battery;
    uint16_t vdata = (uint16_t) (1252352 / x);  
    return vdata;
}



/** 
 * Converts thermistor reading from raw ADC data to engineering units.
 *
 * @author    Martin Turon, Alan Broad
 *
 * To compute the thermistor resistance after measuring the thermistor voltage:
 * - Thermistor is a temperature variable resistor
 * - There is a 10K resistor in series with the thermistor resistor.
 * - Compute expected adc output from voltage on thermistor as: 
 *       ADC= 1023*Rthr/(R1+Rthr)
 *       where  R1 = 10K
 *              Rthr = unknown thermistor resistance
 *       Rthr = R1*(ADC_FS-ADC)/ADC
 *       where  ADC_FS = 1023
 *
 * Note:
 *   The thermistor resistance to temperature conversion is highly non-linear.
 *
 * @return    Thermistor resistance as a uint16 in unit (Ohms)
 *
 * @version   2004/3/11       mturon      Initial revision
 *
 */
uint16_t mts101_convert_thermistor_resistance(XbowSensorboardPacket *packet) 
{
    XSensorMTS101Data *data = (XSensorMTS101Data *)packet->data;
    float    x     = (float)data->thermistor;
    uint16_t vdata = 10000*(1023-x) /x ;
    return vdata;
}

/** 
 * Converts thermistor reading from raw ADC data to engineering units.
 *
 * @author    Martin Turon
 *
 * @return    Temperature reading from thermistor as a float in degrees Celcius
 *
 * @version   2004/3/22       mturon      Initial revision
 *
 */
float mts101_convert_thermistor_temperature(XbowSensorboardPacket *packet) 
{
    //XSensorMTS101Data *data = (XSensorMTS101Data *)packet->data;

    float temperature, a, b, c, Rt;
    a  = 0.001307050;
    b  = 0.000214381;
    c  = 0.000000093;
    Rt = mts101_convert_thermistor_resistance(packet);

    temperature = 1 / (a + b * log(Rt) + c * pow(log(Rt),3));
    temperature -= 273.15;   // Convert from Kelvin to Celcius

    return temperature;
}

/** 
 * Computes the Clairex CL94L light sensor reading 
 *
 * @author    Hu Siquan
 *
 * @return    Voltage of ADC channel as an unsigned integer in mV
 *
 * @version   2004/4/12       husq      Initial revision
 * @n         2004/4/19       husq      Convert ADC reading to mv
 *
 */
uint16_t mts101_convert_light(XbowSensorboardPacket *packet) 
{
    XSensorMTS101Data *data = (XSensorMTS101Data *)packet->data;
    float    Vbat = mts101_convert_battery(packet);
    uint16_t Vadc = (uint16_t) ((data->light) * Vbat / 1023);
    return Vadc;
}


/** MTS101 Specific outputs of raw readings within an XBowSensorboardPacket */
void mts101_print_raw(XbowSensorboardPacket *packet) 
{
    XSensorMTS101Data *data = (XSensorMTS101Data *)packet->data;
    printf("mts101 id=%02x battery=%04x thrm=%04x light=%04x\n",
           packet->node_id, data->battery, data->thermistor, data->light);
}

/** MTS101 specific display of converted readings from XBowSensorboardPacket */
void mts101_print_cooked(XbowSensorboardPacket *packet) 
{
    printf("MTS101 [sensor data converted to engineering units]:\n"
           "   health:     node id=%i\n"
           "   battery:  = %i mv \n"
           "   tempurature: =%0.2f degC\n" 
           "   light: = %i mv \n", 
           packet->node_id,
           mts101_convert_battery(packet),
           mts101_convert_thermistor_temperature(packet),
           mts101_convert_light(packet));
    printf("\n");
}

const char *mts101_db_create_table = 
    "CREATE TABLE %s%s ( result_time timestamp without time zone, "
    "epoch integer, nodeid integer, parent integer, "
    "voltage integer, temp integer, light integer)";

const char *mts101_db_create_rule = 
    "CREATE RULE cache_%s AS ON INSERT TO %s DO ( "
    "DELETE FROM %s_L WHERE nodeid = NEW.nodeid; "
    "INSERT INTO %s_L VALUES (NEW.*); )";
    
/** 
 * Logs raw readings to a Postgres database.
 * 
 * @author    Martin Turon
 *
 * @version   2004/7/28       mturon      Initial revision
 *
 */
void mts101_log_raw(XbowSensorboardPacket *packet) 
{
	XSensorMTS101Data *data = (XSensorMTS101Data *)packet->data;

    char command[512];
    char *table = xdb_get_table();
    if (!*table) table = "mts101_results";

    if (!mts101_packet_handler.flags.table_init) {
	int exists = xdb_table_exists(table);
	if (!exists) {
	    // Create results table.
	    sprintf(command, mts101_db_create_table, table, "");
	    xdb_execute(command);
	    // Create last result cache
	    sprintf(command, mts101_db_create_table, table, "_L");
	    xdb_execute(command);
	    
	    // Add rule to populate last result table
	    sprintf(command, mts101_db_create_rule, table, table, table, table);
	    xdb_execute(command);

	    // Add results table to query log.
	    int q_id = XTYPE_MTS101, sample_time = 99000;
	    sprintf(command, "INSERT INTO task_query_log "
		    "(query_id, tinydb_qid, query_text, query_type, "
		    "table_name) VALUES (%i, %i, 'SELECT nodeid,parent,voltage,temp,light "
		    "SAMPLE PERIOD %i', 'sensor', '%s')", q_id, q_id,
		    sample_time, table);
	    xdb_execute(command);

	    // Log start time of query in time log.
	    sprintf(command, "INSERT INTO task_query_time_log "
		    "(query_id, start_time) VALUES (%i, now())", q_id);
	    xdb_execute(command);
	}
	mts101_packet_handler.flags.table_init = 1;
    }

    sprintf(command, 
	    "INSERT into %s "
	    "(result_time,nodeid,parent,voltage,temp,light)"
	    " values (now(),%u,%u,%u,%u,%u)", 
	    table,
	    //timestring,
	    packet->node_id, packet->parent, 
        data->battery, data->thermistor, data->light
	);

    xdb_execute(command);   
}


XPacketHandler mts101_packet_handler = 
{
    XTYPE_MTS101,
    "$Id: mts101.c,v 1.7 2005/02/01 18:11:11 mturon Exp $",
    mts101_print_raw,
    mts101_print_cooked,
    mts101_print_raw,
    mts101_print_cooked,
    mts101_log_raw
};

void mts101_initialize() {
    xpacket_add_type(&mts101_packet_handler);
}
