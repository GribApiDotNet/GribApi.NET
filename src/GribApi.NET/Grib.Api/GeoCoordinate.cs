using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api
{
    public struct GeoCoordinate
    {
        public double Latitude { get; set; }
        public double Longitude { get; set; }

        public GeoCoordinate(double lat, double lon) : this()
        {
            this.Latitude = lat;
            this.Longitude = lon;
        }
    }
}
