using Grib.Api.Interop.SWIG;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace Grib.Api.Interop
{
    /// <summary>
    /// RAII-style wrapper for grib_api pointers.
    /// </summary>
    public class GribRef: AutoRef
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="GribRef"/> class.
        /// </summary>
        public GribRef () : this(IntPtr.Zero) { }

        /// <summary>
        /// Initializes a new instance of the <see cref="GribRef"/> class.
        /// </summary>
        /// <param name="handle">The handle.</param>
        public GribRef (IntPtr handle)
        {
            Reference = new HandleRef(this, handle);
        }

        public HandleRef Reference { get; protected set; }
        public IntPtr pReference { get { return Reference.Handle; } }
    }

    /// <summary>
    /// Wraps grib_handle struct.
    /// </summary>
    public class GribHandle : GribRef
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="GribHandle"/> class.
        /// </summary>
        /// <param name="h">The h.</param>
        public GribHandle (IntPtr h) : base(h)
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

    /// <summary>
    /// Wraps grib_context struct.
    /// </summary>
    public class GribContext : GribRef
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

    /// <summary>
    /// Wraps a grib_keys_iterator struct.
    /// </summary>
    public class GribKeysIterator : GribRef
    {
        internal GribKeysIterator(IntPtr h): base(h)
        {
        }

        /// <summary>
        /// Gets the next value in a series.
        /// </summary>
        /// <returns>False if there are no more values.</returns>
        public bool Next ()
        {
            return GribApiProxy.GribKeysIteratorNext(this) != 0;
        }

        /// <summary>
        /// Called when [dispose].
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void OnDispose (bool disposing)
        {
            GribApiProxy.GribKeysIteratorDelete(this);
        }

        public string Name
        {
            get
            {
                StringBuilder sb = new StringBuilder(255);
                Interop.Util.GribApiNative.GetGribKeysIteratorName(sb, this.Reference.Handle);
                
                return sb.ToString();
            }
        }

        /// <summary>
        /// Creates an instance of GribKeysIterator.
        /// </summary>
        /// <param name="handle">The handle of the message to iterate.</param>
        /// <param name="filters">The key filters.</param>
        /// <param name="nspace">The namespace of the keys to iterate.</param>
        /// <returns></returns>
        public static GribKeysIterator Create (GribHandle handle, uint filters, string nspace)
        {
            return GribApiProxy.GribKeysIteratorNew(handle, filters, nspace);
        }
    }

    /// <summary>
    /// Wraps a grib_iterator struct.
    /// </summary>
    public class GribValuesIterator : GribRef
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="GribValuesIterator"/> class.
        /// </summary>
        /// <param name="h">The h.</param>
        internal GribValuesIterator (IntPtr h)
            : base(h)
        {
        }

        /// <summary>
        /// Gets the next value in a series.
        /// </summary>
        /// <param name="isMissingFlag">The is missing flag.</param>
        /// <param name="gsVal">The gs value.</param>
        /// <returns>False if there are no more values.</returns>
        public bool Next(double isMissingFlag, out GeoSpatialValue gsVal)
        {
            double lat, lon, val;
            bool success = GribApiProxy.GribIteratorNext(this, out lat, out lon, out val) != 0;

            gsVal = new GeoSpatialValue(lat, lon, val, val == isMissingFlag);

            return success;
        }

        /// <summary>
        /// Called when [dispose].
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void OnDispose (bool disposing)
        {
            GribApiProxy.GribIteratorDelete(this);
        }

        /// <summary>
        /// Creates an instance of GribValuesIterator.
        /// </summary>
        /// <param name="h">The handle of the message to iterate.</param>
        /// <param name="filters">The filters.</param>
        /// <returns></returns>
        public static GribValuesIterator Create (GribHandle h, uint filters)
        {
            int err = 0;

            GribValuesIterator iter = GribApiProxy.GribIteratorNew(h, filters, out err);

            if (err != 0)
            {
                throw GribApiException.Create(err);
            }

            return iter;
        }
    }
}
