using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api
{
	public struct GribNearestValue
	{
		public double[] Latitudes { get; set; }
		public double[] Longitudes { get; set; }
		public double[] Distances { get; set; }
		public double[] Values { get; set; }
		public int[] Indexes { get; set; }

		public GribNearestValue (GribNearest nearest, double latitude, double longitude)
		{
			this.Latitudes = new double[] { 0, 0, 0, 0 };
			this.Longitudes = new double[] { 0, 0, 0, 0 };
			this.Distances = new double[] { 0, 0, 0, 0 };
			this.Values = new double[] { 0, 0, 0, 0 };
			this.Indexes = new int[] { 0, 0, 0, 0 };

			Interop.SizeT len = 0;
			Interop.SWIG.GribApiProxy.GribNearestFind(nearest.Nearest, nearest.FileHandle, latitude, longitude, 0,
				                                    this.Latitudes, this.Longitudes, this.Values, this.Distances,
													this.Indexes, ref len);

		}
	}
}
