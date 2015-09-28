using Grib.Api.Interop.SWIG;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace Grib.Api.Interop
{
    public abstract class GribRef: AutoRef
    {
        public GribRef () : this(IntPtr.Zero) { }

        public GribRef (IntPtr handle)
        {
            Reference = new HandleRef(this, handle);
        }

        protected override void OnDispose ()
        {
        }

        public HandleRef Reference { get; protected set; }
        public IntPtr pReference { get { return Reference.Handle; } }
    }

    public class GribHandle : GribRef
    {
        public GribHandle (IntPtr h) : base(h)
        {
        }

        protected override void OnDispose ()
        {
            GribApiProxy.GribHandleDelete(this);
        }
    }

    public class GribContext : GribRef
    {
        public GribContext (IntPtr h)
            : base(h)
        {
        }

        protected override void OnDispose ()
        {
            GribApiProxy.GribContextDelete(this);
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
