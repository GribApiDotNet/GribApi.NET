using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Grib.Api.Interop.SWIG;
using System.Runtime.InteropServices;
using Grib.Api.Interop;

namespace Grib.Api
{
    public class GribValue
    {
        const uint MAX_KEY_LEN = 255;
        const uint MAX_VAL_LEN = 1024;

        private SWIGTYPE_p_grib_handle _handle;


        internal GribValue(SWIGTYPE_p_grib_handle handle, string keyName)
        {
            _handle = handle;
            Key = keyName;
        }

        /// <summary>
        /// Gets the key's value.
        /// </summary>
        /// <returns></returns>
        public string AsString()
        {
            uint len = MAX_VAL_LEN;
            uint ptLen = 0;

            // not sure it's worth checking the length here--could just use MAX_VAL_LEN
            GribApiProxy.GribGetLength(_handle, Key, ref ptLen);
            StringBuilder val = new StringBuilder((int) ptLen);
            
            GribApiProxy.GribGetString(_handle, Key, val, ref len);

            return val.ToString();
        }

        /// <summary>
        /// Sets the key's value.
        /// </summary>
        /// <param name="newValue">The new value.</param>
        public void AsString(string newValue)
        {
            uint len = (uint)newValue.Length;
            GribApiProxy.GribSetString(_handle, Key, newValue, ref len);
        }

        /// <summary>
        /// Gets the key's value.
        /// </summary>
        /// <returns></returns>
        public int AsInt()
        {
            int val;

            GribApiProxy.GribGetLong(_handle, Key, out val);

            return val;
        }

        /// <summary>
        /// Sets the key's value.
        /// </summary>
        /// <param name="newValue">The new value.</param>
        public void AsInt(int newValue)
        {
            GribApiProxy.GribSetLong(_handle, Key, newValue);
        }

        /// <summary>
        /// Gets the key's value.
        /// </summary>
        /// <returns></returns>
        public int[] AsIntArray ()
        {
            uint sz = 0;
            GribApiProxy.GribGetSize(_handle, Key, ref sz);

            int[] values = new int[sz];
            GribApiProxy.GribGetLongArray(_handle, Key, values, ref sz);

            return values;
        }

        /// <summary>
        /// Sets the key's value.
        /// </summary>
        /// <param name="newValues">The new values.</param>
        public void AsIntArray(int[] newValues)
        {
            GribApiProxy.GribSetLongArray(_handle, Key, newValues, (uint) newValues.Length);
        }

        /// <summary>
        /// Gets the key's value.
        /// </summary>
        /// <returns></returns>
        public double AsDouble()
        {
            double val;

            GribApiProxy.GribGetDouble(_handle, Key, out val);

            return val;
        }

        /// <summary>
        /// Sets the key's value.
        /// </summary>
        /// <param name="newValue">The new value.</param>
        public void AsDouble(double newValue)
        {
            GribApiProxy.GribSetDouble(_handle, Key, newValue);
        }

        /// <summary>
        /// Gets the key's value.
        /// </summary>
        /// <returns></returns>
        public double[] AsDoubleArray ()
        {
            uint sz = 0;
            GribApiProxy.GribGetSize(_handle, Key, ref sz);

            double[] values = new double[sz];
            GribApiProxy.GribGetDoubleArray(_handle, Key, values, ref sz);

            return values;
        }

        /// <summary>
        /// Sets the key's value.
        /// </summary>
        /// <param name="newValues">The new values.</param>
        /// <param name="force">if set to <c>true</c> [force].</param>
        public void AsDoubleArray (double[] newValues, bool force = false)
        {
            if (force)
            {
                GribApiProxy.GribSetForceDoubleArray(_handle, Key, newValues, (uint) newValues.Length);
            } else
            {
                GribApiProxy.GribSetDoubleArray(_handle, Key, newValues, (uint) newValues.Length);
            }
        }


        /// <summary>
        /// Gets the key name for this value.
        /// </summary>
        /// <value>
        /// The key name.
        /// </value>
        public string Key { get; private set; }

        /// <summary>
        /// Gets or sets a value indicating whether the value associated with this key is missing.
        /// Setting to <c>false</c> throws a <see cref="GribApiException"/>.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if this value is missing; otherwise, <c>false</c>.
        /// </value>
        public bool IsMissing
        {
            set
            {
                if (!value)
                {
                    throw new GribApiException("To set a value as not missing, simply set the value.");
                }

                GribApiProxy.GribSetMissing(_handle, Key);
            }

            get
            {
                int err;
                return GribApiProxy.GribIsMissing(_handle, Key, out err);
            }
        }

        /// <summary>
        /// Return true if the given key exists (is defined) in the grib message.
        /// </summary>
        /// <value>
        /// <c>true</c> if key is defined; otherwise, <c>false</c>.
        /// </value>
        public bool IsDefined
        {
            get
            {
                return GribApiProxy.GribIsDefined(_handle, Key);
            }
        }

        /// <summary>
        /// Gets an enum describing the value's representation within the message.
        /// </summary>
        /// <value>
        /// The type of the native.
        /// </value>
        public GribValueType NativeType
        {
            get
            {
                int type = 0;

                GribApiProxy.GribGetNativeType(_handle, Key, out type);
                
                return (GribValueType) type;
            }
        }
    }
}
