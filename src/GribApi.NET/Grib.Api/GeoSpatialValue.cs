using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api
{
    public struct GeoSpatialValue : IGeoCoordinate
    {
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public double Value { get; set; }
        public bool IsMissing { get; private set; }

        public GeoSpatialValue(double lat, double lon, double val, bool isMissing) :this()
        {
            this.Latitude = lat;
            this.Longitude = lon;
            this.Value = val;
            this.IsMissing = isMissing;
        }
    }
}
