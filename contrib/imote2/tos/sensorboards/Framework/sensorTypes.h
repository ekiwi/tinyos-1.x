/**
 *@author Robbie Adler
 **/

#ifndef __SENSOR_TYPES_H__
#define __SENSOR_TYPES_H__

//#define CREATE_MASK(numberofbits, shift) (((1<<(numberofbits)) - 1)<<(shift))
#define CREATE_MASK(numberofbits, shift) (((1<<(numberofbits)) - 1))

#define SENSOR_TYPE_BITS (1)
#define SENSOR_TYPE_POS (0)
#define SENSOR_TYPE_MASK CREATE_MASK(SENSOR_TYPE_BITS, SENSOR_TYPE_POS)
#define SET_SENSOR_TYPE(type) ((type & SENSOR_TYPE_MASK) << SENSOR_TYPE_POS)
#define GET_SENSOR_TYPE(val)  ((val >> SENSOR_TYPE_POS) & SENSOR_TYPE_MASK)
enum {
  SENSOR_ANALOG = 0,
  SENSOR_DIGITAL = 1
};

#define SENSOR_ANALOG_COUPLING_BITS (2)
#define SENSOR_ANALOG_COUPLING_POS (SENSOR_TYPE_POS + SENSOR_TYPE_BITS)
#define SENSOR_ANALOG_COUPLING_MASK CREATE_MASK(SENSOR_ANALOG_COUPLING_BITS, SENSOR_ANALOG_COUPLING_POS)
#define SET_ANALOG_COUPLING(type) ((type & SENSOR_ANALOG_COUPLING_MASK) << SENSOR_ANALOG_COUPLING_POS)
#define GET_ANALOG_COUPLING(val)  ((val >> SENSOR_ANALOG_COUPLING_POS) & SENSOR_ANALOG_COUPLING_MASK)
enum {
  SENSOR_ANALOG_ACCOUPLED = 1,
  SENSOR_ANALOG_DCCOUPLED = 2
};

#define SENSOR_ANALOG_PHYSICAL_TYPE_BITS (2)
#define SENSOR_ANALOG_PHYSICAL_TYPE_POS (SENSOR_ANALOG_COUPLING_POS + SENSOR_ANALOG_COUPLING_BITS)
#define SENSOR_ANALOG_PHYSICAL_TYPE_MASK CREATE_MASK(SENSOR_ANALOG_PHYSICAL_TYPE_BITS, SENSOR_ANALOG_PHYSICAL_TYPE_POS)
#define SET_ANALOG_PHYSICAL_TYPE(type) ((type & SENSOR_ANALOG_PHYSICAL_TYPE_MASK) << SENSOR_ANALOG_PHYSICAL_TYPE_POS)
#define GET_ANALOG_PHYSICAL_TYPE(val)  ((val >> SENSOR_ANALOG_PHYSICAL_TYPE_POS) & SENSOR_ANALOG_PHYSICAL_TYPE_MASK)
enum { 
  SENSOR_ANALOG_VOLTAGE = 1,
  SENSOR_ANALOG_CURRENT = 2
};

#define SENSOR_ANALOG_INPUT_TYPE_BITS (2)
#define SENSOR_ANALOG_INPUT_TYPE_POS (SENSOR_ANALOG_PHYSICAL_TYPE_POS + SENSOR_ANALOG_PHYSICAL_TYPE_BITS)
#define SENSOR_ANALOG_INPUT_TYPE_MASK CREATE_MASK(SENSOR_ANALOG_INPUT_TYPE_BITS, SENSOR_ANALOG_INPUT_TYPE_POS)
#define SET_ANALOG_INPUT_TYPE(type) ((type & SENSOR_ANALOG_INPUT_TYPE_MASK) << SENSOR_ANALOG_INPUT_TYPE_POS)
#define GET_ANALOG_INPUT_TYPE(val)  ((val >> SENSOR_ANALOG_INPUT_TYPE_POS) & SENSOR_ANALOG_INPUT_TYPE_MASK)
enum { 
  SENSOR_ANALOG_SINGLEENDED = 1,
  SENSOR_ANALOG_DIFFERENTIAL = 2
};

#define SENSOR_ANALOG_INPUT_RANGE_BITS (4)
#define SENSOR_ANALOG_INPUT_RANGE_POS (SENSOR_ANALOG_INPUT_TYPE_POS + SENSOR_ANALOG_INPUT_TYPE_BITS)
#define SENSOR_ANALOG_INPUT_RANGE_MASK CREATE_MASK(SENSOR_ANALOG_INPUT_RANGE_BITS, SENSOR_ANALOG_INPUT_RANGE_POS)
#define SET_ANALOG_INPUT_RANGE(type) ((type & SENSOR_ANALOG_INPUT_RANGE_MASK) << SENSOR_ANALOG_INPUT_RANGE_POS)
#define GET_ANALOG_INPUT_RANGE(val)  ((val >> SENSOR_ANALOG_INPUT_RANGE_POS) & SENSOR_ANALOG_INPUT_RANGE_MASK)
enum {
  SENSOR_ANALOG_RANGE_PLUS5V = 1,
  SENSOR_ANALOG_RANGE_PLUSMINUS5V = 2,
  SENSOR_ANALOG_RANGE_PLUS10V = 3,
  SENSOR_ANALOG_RANGE_PLUSMINUS10V = 4,
  SENSOR_ANALOG_RANGE_PLUSMINUS2P5V = 5
  
};  
  
#define SENSOR_DIGITAL_TYPE_BITS (3)
#define SENSOR_DIGITAL_TYPE_POS (SENSOR_TYPE_POS + SENSOR_TYPE_BITS)
#define SENSOR_DIGITAL_TYPE_MASK CREATE_MASK(SENSOR_DIGITAL_TYPE_BITS, SENSOR_DIGITAL_TYPE_POS)
#define SET_DIGITAL_TYPE(type) ((type & SENSOR_DIGITAL_TYPE_MASK) << SENSOR_DIGITAL_TYPE_POS)
#define GET_DIGITAL_TYPE(val)  ((val >> SENSOR_DIGITAL_TYPE_POS) & SENSOR_DIGITAL_TYPE_MASK)
enum { 
  SENSOR_DIGITAL_PWMACCELEROMETER = 1,
  SENSOR_DIGITAL_3AXISACCEL = 2,
  SENSOR_DIGITAL_GENERIC = 3
};

#define ANALOG_SENSOR(coupling,phytype,inputtype,inputrange)  \
(SET_SENSOR_TYPE(SENSOR_ANALOG) | SET_ANALOG_COUPLING((coupling)) | \
SET_ANALOG_PHYSICAL_TYPE((phytype)) | SET_ANALOG_INPUT_TYPE((inputtype)) | \
SET_ANALOG_INPUT_RANGE((inputrange)))    

#define DIGITAL_SENSOR(type) \
(SET_SENSOR_TYPE(SENSOR_DIGITAL) | SET_DIGITAL_TYPE((type)))    

#endif //__SENSOR_TYPES_H__