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

		public GribNearestValue FindNearestValue (double latitude, double longitude)
		{
			return new GribNearestValue(this, latitude, longitude);
		}

		public static GribNearest Create(GribHandle fileHandle)
		{
			int err = 0;

			var nearest = GribApiProxy.GribNearestNew(fileHandle, out err);

			if (err != 0)
			{
				throw GribApiException.Create(err);
			}
			
			return new GribNearest(nearest, fileHandle);
		}
	}
}
