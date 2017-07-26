using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api.Tests
{
    static class Settings
    {
        public const string PACIFIC_WIND = ".\\TestData\\Pacific.wind.7days.grb";
        public const string GRIB = ".\\TestData\\GRIB.grb";
        public const string REG_LATLON_GRB1 = ".\\TestData\\regular_latlon_surface.grib1";
        public const string REDUCED_LATLON_GRB2 = ".\\TestData\\reduced_latlon_surface.grib2";
        public const string OUT_INDEX = ".\\TestData\\out.index";
        public const string OUT_GRIB = ".\\TestData\\out.grb";
		public const string REG_GAUSSIAN_SURFACE_GRB2 = ".\\TestData\\regular_gaussian_surface.grib2";
		public const string REG_GAUSSIAN_MODEL_GRB1 = ".\\TestData\\reduced_gaussian_model_level.grib1";
		public const string SPHERICAL_PRESS_LVL = ".\\TestData\\spherical_pressure_level.grib1";
        public const string PNG_COMPRESSION = ".\\TestData\\MRMS2.grib2";
        public const string COMPLEX_GRID = ".\\TestData\\spectral_complex.grib1";
        public const string BAD = ".\\TestData\\bad.grb";
        public const string EMPTY = ".\\TestData\\empty.grb";
		public const string TIME = ".\\TestData\\time.grb";
		public const string STEREO = ".\\TestData\\polar_stereo.grib2";
	}
}
