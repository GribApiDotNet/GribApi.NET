using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api
{
	public struct GribNearestValue
	{
		public GeoSpatialValue Value { get; set; }
		public double Distance { get; set; }
		public int Index { get; set; }

		public GribNearestValue (double latitude, double longitude, double value, double distance, int index)
		{
			this.Value = new GeoSpatialValue(latitude, longitude, value, false);
			this.Distance = distance;
			this.Index = index;
		}
	}
}
