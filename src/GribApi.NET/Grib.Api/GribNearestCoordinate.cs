using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api
{
	public struct GribNearestCoordinate
	{
		public GeoSpatialValue Value;
		public double Distance;
		public int Index;

		public GribNearestCoordinate (double latitude, double longitude, double value, double distance, int index)
		{
			this.Distance = distance;
			this.Index = index;
			this.Value = new GeoSpatialValue(latitude, longitude, value, false);
		}
	}
}
