using Grib.Api.Interop;
using Grib.Api.Interop.SWIG;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api
{
	[Flags]
	public enum GribNearestToSame: uint
	{
		GRID = 1<<0,
		DATA = 1<<1,
		POINT = 1<<2
	}

	public class GribNearest: AutoRef
	{
		public SWIGTYPE_p_grib_nearest Nearest = null;
		public GribHandle FileHandle = null;

		internal GribNearest (SWIGTYPE_p_grib_nearest nearest, GribHandle fileHandle): base()
		{
			this.Reference = SWIGTYPE_p_grib_nearest.getCPtr(nearest);
			this.Nearest = nearest;
			this.FileHandle = fileHandle;
		}

		protected override void OnDispose(bool disposing)
		{
			if (this.pReference != IntPtr.Zero)
			{
				GribApiProxy.GribNearestDelete(Nearest);
				this.Nearest = null;
				this.FileHandle = null;
			}
		}


		public GribNearestValue[] FindNearestValue (double latitude, double longitude, GribNearestToSame flags = GribNearestToSame.POINT)
		{
			var latitudes = new double[] { 0, 0, 0, 0 };
			var longitudes = new double[] { 0, 0, 0, 0 };
			var distances = new double[] { 0, 0, 0, 0 };
			var values = new double[] { 0, 0, 0, 0 };
			var indexes = new int[] { 0, 0, 0, 0 };

			Interop.SizeT len = 0;
			Interop.SWIG.GribApiProxy.GribNearestFind(this.Nearest, this.FileHandle, latitude, longitude, (uint)flags,
													latitudes, longitudes, values, distances,
													indexes, ref len);

			var vals = new GribNearestValue[len];

			for (var i = 0; i < len; i++)
			{
				vals[i] = new GribNearestValue(latitudes[i], longitudes[i], values[i], distances[i], indexes[i]);
			}

			return vals;
		}

		public static GribNearest Create(GribHandle handle)
		{
			int err = 0;

			var nearest = GribApiProxy.GribNearestNew(handle, out err);

			if (err != 0)
			{
				throw GribApiException.Create(err);
			}
			
			return new GribNearest(nearest, handle);
		}
	}
}
