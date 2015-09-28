using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Grib.Api.Templates
{
    abstract class ParameterNumbers
    {
        // TODO add constants

        //000 Reserved  
        //001 Pressure Pa 
        //002 Pressure reduced to MSL Pa 
        //003 Pressure tendency Pa s-1 
        //004 Potential vorticity K m2 kg-1 s-1 
        //005 ICAO Standard Atmosphere reference height m 
        //006 Geopotential m2 s-2 
        //007 Geopotential height gpm 
        //008 Geometrical height m 
        //009 Standard deviation of height m 
        //010 Total ozone Dobson 
        //011 Temperature K 
        //012 Virtual temperature K 
        //013 Potential temperature K 
        //014 Pseudo-adiabatic potential temperature K 
        //015 Maximum temperature K 
        //016 Minimum temperature K 
        //017 Dew-point temperature K 
        //018 Dew-point depression (or deficit) K 
        //019 Lapse rate K m-1 
        //020 Visibility m 
        //021 Radar spectra (1) - 
        //022 Radar spectra (2) - 
        //023 Radar spectra (3) - 
        //024 Parcel lifted index (to 500 hPa) (see Note 6) K 
        //025 Temperature anomaly K 
        //026 Pressure anomaly Pa 
        //027 Geopotential height anomaly gpm 
        //028 Wave spectra (1) - 
        //029 Wave spectra (2) - 
        //030 Wave spectra (3) - 
        //031 Wind direction Degree true 
        //032 Wind speed m s-1 
        //033 u-component of wind (see Note 4) m s-1 
        //034 v-component of wind (see Note 4) m s-1 
        //035 Stream function m2 s-1 
        //036 Velocity potential m2 s-1 
        //037 Montgomery stream function m2 s-1 
        //038 Sigma coordinate vertical velocity s-1 
        //039 Vertical velocity Pa s-1 
        //040 Vertical velocity m s-1 
        //041 Absolute vorticity s-1 
        //042 Absolute divergence s-1 
        //043 Relative vorticity s-1 
        //044 Relative divergence s-1 
        //045 Vertical u-component shear (see Note 4) s-1 
        //046 Vertical v-component shear (see Note 4) s-1 
        //047 Direction of current Degree true 
        //048 Speed of current m s-1 
        //049 u-component of current (see Note 4) m s-1 
        //050 v-component of current (see Note 4) m s-1 
        //051 Specific humidity kg kg-1 
        //052 Relative humidity % 
        //053 Humidity mixing ratio kg kg-1 
        //054 Precipitable water kg m-2 
        //055 Vapor pressure Pa 
        //056 Saturation deficit Pa 
        //057 Evaporation kg m-2 
        //058 Cloud ice kg m-2 
        //059 Precipitation rate kg m-2 s-1 
        //060 Thunderstorm probability % 
        //061 Total precipitation kg m-2 
        //062 Large scale precipitation kg m-2 
        //063 Convective precipitation kg m-2 
        //064 Snowfall rate water equivalent kg m-2 s-1 
        //065 Water equivalent of accumulated snow depth kg m-2 
        //066 Snow depth m 
        //067 Mixed layer depth m 
        //068 Transient thermocline depth m 
        //069 Main thermocline depth m 
        //070 Main thermocline anomaly m 
        //071 Total cloud cover % 
        //072 Convective cloud cover % 
        //073 Low cloud cover % 
        //074 Medium cloud cover % 
        //075 High cloud cover % 
        //076 Cloud water kg m-2 
        //077 Best lifted index (to 500 hPa) (see Note 6) K 
        //078 Convective snow kg m-2 
        //079 Large scale snow kg m-2 
        //080 Water temperature K 
        //081 Land cover (1 = land, 0 = sea) Proportion 
        //082 Deviation of sea level from mean m 
        //083 Surface roughness m 
        //084 Albedo % 
        //085 Soil temperature K 
        //086 Soil moisture content kg m-2 
        //087 Vegetation % 
        //088 Salinity kg kg-1 
        //089 Density kg m-3 
        //090 Water run-off kg m-2 
        //091 Ice cover (1 = ice, 0 = no ice) Proportion 
        //092 Ice thickness m 
        //093 Direction of ice drift Degree true 
        //094 Speed of ice drift m s-1 
        //095 u-component of ice drift (see Note 4) m s-1 
        //096 v-component of ice drift (see Note 4) m s-1 
        //097 Ice growth rate m s-1 
        //098 Ice divergence s-1 
        //099 Snow melt kg m-2 
        //100 Significant height of combined wind waves and swell m 
        //101 Direction of wind waves Degree true 
        //102 Significant height of wind waves m 
        //103 Mean period of wind waves s 
        //104 Direction of swell waves Degree true 
        //105 Significant height of swell waves m 
        //106 Mean period of swell waves s 
        //107 Primary wave direction Degree true 
        //108 Primary wave mean period s 
        //109 Secondary wave direction Degree true 
        //110 Secondary wave mean period s 
        //111 Net short-wave radiation flux (surface) (see Note 3) W m-2 
        //112 Net long-wave radiation flux (surface) (see Note 3) W m-2 
        //113 Net short-wave radiation flux (top of atmosphere) (see Note 3) W m-2 
        //114 Net long-wave radiation flux (top of atmosphere) (see Note 3) W m-2 
        //115 Long-wave radiation flux (see Note 3) W m-2 
        //116 Short-wave radiation flux (see Note 3) W m-2 
        //117 Global radiation flux (see Note 3) W m-2 
        //118 Brightness temperature K 
        //119 Radiance (with respect to wave number) W m-1 sr-1 
        //120 Radiance (with respect to wave length) W m-3 sr-1 
        //121 Latent heat flux W m-2 
        //122 Sensible heat flux W m-2 
        //123 Boundary layer dissipation W m-2 
        //124 Momentum flux, u-component (see Note 4) N m-2 
        //125 Momentum flux, v-component (see Note 4) N m-2 
        //126 Wind mixing energy J 
        //127 Image data  
        //128-254 Reserved for originating center use  
        //255 Missing value 
    }
}
