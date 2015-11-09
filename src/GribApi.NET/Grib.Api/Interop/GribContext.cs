using Grib.Api.Interop.SWIG;
using System;

namespace Grib.Api.Interop
{
    /// <summary>
    /// Wraps grib_context struct.
    /// </summary>
    public class GribContext : AutoRef
    {
        private static GribContext _dfltCxt = GribApiProxy.GribContextGetDefault();
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

                _enableMultipleFieldMessages = value;
            }
        }
        private bool _enableMultipleFieldMessages = false;

        /// <summary>
        /// Creates an instance.
        /// </summary>
        /// <returns></returns>
        public static GribContext Create()
        {
           // GribContext defaultContext = GribApiProxy.GribContextGetDefault();
           // return GribApiProxy.GribContextNew(_dfltCxt);
            var c = new GribContext(IntPtr.Zero);
            return GribApiProxy.GribContextNew(c);
        }
    }
}
