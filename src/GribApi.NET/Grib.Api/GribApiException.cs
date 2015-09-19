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

        /// <summary>
        /// Initializes a new instance of the <see cref="GribApiException"/> class.
        /// </summary>
        /// <param name="msg">The MSG.</param>
        /// <param name="innerException">The inner exception.</param>
        public GribApiException (string msg, Exception innerException = null) : base(msg, innerException)
        {
        }

        /// <summary>
        /// Creates a GribApiException instance using an error code returned by grib_api.
        /// </summary>
        /// <param name="errCode">The error code.</param>
        /// <returns></returns>
        public static GribApiException Create(int errCode)
        {
            string msg = GribApiProxy.GribGetErrorMessage(errCode);
            return new Grib.Api.GribApiException(msg);
        }
    }
}
