using Grib.Api.Interop.SWIG;
using Grib.Api.Interop.Util;
using System;
using System.Runtime.InteropServices;

namespace Grib.Api.Interop
{
	/// <summary>
	/// Logging handler.
	/// </summary>
	/// <param name="lvl">The level.</param>
	/// <param name="msg">The MSG.</param>
	public delegate void GribApiLogHandler (int lvl, string msg);

    /// <summary>
    /// Wraps grib_context struct.
    /// </summary>
    public class GribContext : AutoRef
    {
		/// <summary>
		/// Occurs when the grib_api library logs a message.
		/// </summary>
		public event GribApiLogHandler OnLog;

        /// <summary>
        /// Initializes a new instance of the <see cref="GribContext"/> class.
        /// </summary>
        /// <param name="h">The h.</param>
        public GribContext (IntPtr h)
            : base(h)
        {
			GribApiNative.GribSetContextLogger(h, this.OnLogReceived);
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
		/// Called when [log received].
		/// </summary>
		/// <param name="ctx">The grib_context generating the log.</param>
		/// <param name="lvl">The level.</param>
		/// <param name="msg">The MSG.</param>
		private void OnLogReceived(IntPtr ctx, int lvl, [MarshalAs(UnmanagedType.LPStr)]string msg)
		{
			if (this.OnLog != null)
			{
				this.OnLog(lvl, msg);
			}
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
    }
}
