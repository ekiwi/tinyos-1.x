//$Id: byteorder.h,v 1.1.1.1 2007/11/05 19:09:06 jpolastre Exp $

#ifndef __BYTEORDER
#define __BYTEORDER

inline int is_host_msb()
{
   const uint8_t n[2] = {0,1};
   return ((*(uint16_t*)n) == 1);
}

inline int is_host_lsb()
{
   const uint8_t n[2] = {1,0};
   return ((*(uint16_t*)n) == 1);
}

inline uint16_t toLSB16( uint16_t a )
{
   return is_host_lsb() ? a : ((a<<8)|(a>>8));
}

inline uint16_t fromLSB16( uint16_t a )
{
   return is_host_lsb() ? a : ((a<<8)|(a>>8));
}

#endif
