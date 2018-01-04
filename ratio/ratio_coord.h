#pragma once

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

#ifdef __cplusplus
extern "C"
{
#endif

    /*
     * TYPE DEFINITION of MercPoint and RatioLngLat
     */
typedef struct RatioLngLat {
    double longitude;
    double latitude;
} RatioLngLat;

    extern const RatioLngLat INVALID_LNG_LAT; // {.longitude=NAN, .latitude=NAN}

    inline bool isValidLngLat(const RatioLngLat* lnglat) { return lnglat != NULL && !isnan(lnglat->longitude); };
    
typedef struct MercPoint {
    int32_t x;
    int32_t y;
} MercPoint;

    extern const MercPoint INVALID_MERC_POINT;

    /*
     * Coordinates on EARTH
     */
    
    inline void MercPoint_correctForView(MercPoint* pt){
        if((pt->x & 0xffff) == 0xffff) (pt->x)++;
        if((pt->y & 0xffff) == 0xffff) (pt->y)++;
    };

#ifdef __cplusplus
}
#endif
