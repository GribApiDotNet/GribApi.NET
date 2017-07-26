using Grib.Api.Interop.SWIG;
using Grib.Api.Interop.Util;
using System;
using System.Runtime.InteropServices;

namespace Grib.Api.Interop
{
    /// <summary>
    /// Wraps grib_context struct.
    /// </summary>
    public class GribContext : AutoRef
    {
		public static readonly GribContext Default = GribApiProxy.GribContextGetDefault();

        /// <summary>
        /// Initializes a new instance of the <see cref="GribContext"/> class.
        /// </summary>
        /// <param name="h">The h.</param>
        public GribContext (IntPtr h)
            : base(h)
        {
        }

        /// <summary>
        /// Called when [dispose].
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void OnDispose (bool disposing)
        {
            // This causes AccessViolation when disposing
            // GribApiProxy.GribContextDelete(this);
        }

        /// <summary>
        /// Gets or sets a value indicating whether to [enable multiple field messages]. grib_api documentation discourages use of this feature.
        /// </summary>
        /// <value>
        /// <c>true</c> if [enable multiple field messages]; otherwise, <c>false</c>.
        /// </value>
        public bool EnableMultipleFieldMessages
        {
            get { return _enableMultipleFieldMessages; }
            set
            {
                if (value)
                {
                    GribApiProxy.GribMultiSupportOn(this);
                } else
                {
                    GribApiProxy.GribMultiSupportOff(this);
                }

                _enableMultipleFieldMessages = value;
            }
        }
        private bool _enableMultipleFieldMessages = false;
    }
}
