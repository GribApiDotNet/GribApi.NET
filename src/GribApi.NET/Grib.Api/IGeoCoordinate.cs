using System;
namespace Grib.Api
{
    interface IGeoCoordinate
    {
        double Latitude { get; set; }
        double Longitude { get; set; }
    }
}
