using Grib.Api.Interop.SWIG;
using System;

namespace Grib.Api.Interop
{
    /// <summary>
    /// Wraps grib_context struct.
    /// </summary>
    public class GribContext : AutoRef
    {
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
            // This causes AccessViolation when dispos
            // GribApiProxy.GribContextDelete(this);
        }

        /// <summary>
        /// Gets or sets a value indicating whether [enable multiple field messages].
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
            }
        }
        private bool _enableMultipleFieldMessages = false;
    }
}
