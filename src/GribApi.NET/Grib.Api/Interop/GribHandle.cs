using Grib.Api.Interop.SWIG;
using System;

namespace Grib.Api.Interop
{
    /// <summary>
    /// Wraps grib_handle struct.
    /// </summary>
    public class GribHandle : AutoRef
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="GribHandle"/> class.
        /// </summary>
        /// <param name="h">The h.</param>
        public GribHandle (IntPtr h)
            : base(h)
        {
        }

        /// <summary>
        /// Called when [dispose].
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void OnDispose (bool disposing)
        {
            GribApiProxy.GribHandleDelete(this);
        }
    }
}
