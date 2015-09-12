using Grib.Api.Interop.SWIG;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api
{
    public class GribApiException: Exception
    {
        protected GribApiException (string msg) : base(msg) { }

        public static GribApiException Create(int errCode)
        {
            string msg = GribApiProxy.GribGetErrorMessage(errCode);
            return new Grib.Api.GribApiException(msg);
        }
    }
}
