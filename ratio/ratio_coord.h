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
#define INVALID_LNG_LAT RatioLngLat{.longitude=NAN, .latitude=NAN}

typedef struct RatioLngLat {
    double longitude;
    double latitude;
} RatioLngLat;

    inline bool isValidLngLat(const RatioLngLat* lnglat) { return lnglat != NULL && !isnan(lnglat->longitude); };
    
#define INVALID_MERC_POINT MercPoint{.x = 0, .y = 0}

typedef struct MercPoint {
    int32_t x;
    int32_t y;
} MercPoint;

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
