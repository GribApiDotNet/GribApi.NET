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
    /// <summary>
    /// Encapsulates logic for encoding and decoding a value within a GRIB message.
    /// </summary>
    public class GribValue
    {
        const uint MAX_KEY_LEN = 255;
        const uint MAX_VAL_LEN = 1024;

        private SWIGTYPE_p_grib_handle _handle;

        /// <summary>
        /// Initializes a new instance of the <see cref="GribValue"/> class.
        /// </summary>
        /// <param name="handle">The handle.</param>
        /// <param name="keyName">Name of the key.</param>
        internal GribValue(SWIGTYPE_p_grib_handle handle, string keyName)
        {
            _handle = handle;
            Key = keyName;
        }

        /// <summary>
        /// Gets the key's value.
        /// </summary>
        /// <param name="inDegrees">if set to <c>true</c>, GribApi.NET will convert the value to degrees when possible.</param>
        /// <returns></returns>
        public string AsString(bool inDegrees = true)
        {
            uint len = MAX_VAL_LEN;
            uint ptLen = 0;
            string valueKey = Key;

            if (CanConvertToDegrees)
            {
                valueKey = BuildTokenForDouble(inDegrees);
            }

            // not sure it's worth checking the length here--could just use MAX_VAL_LEN
            GribApiProxy.GribGetLength(_handle, valueKey, ref ptLen);
            StringBuilder msg = new StringBuilder((int) ptLen);

            GribApiProxy.GribGetString(_handle, valueKey, msg, ref len);

            return msg.ToString();
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
        /// <param name="inDegrees">if set to <c>true</c>, GribApi.NET will return the value [in degrees] when possible.</param>
        /// <returns></returns>
        public double AsDouble(bool inDegrees = true)
        {
            double val;
            string valueKey = BuildTokenForDouble(inDegrees);

            GribApiProxy.GribGetDouble(_handle, valueKey, out val);

            return val;
        }

        /// <summary>
        /// Sets the key's value.
        /// </summary>
        /// <param name="newValue">The new value.</param>
        /// <param name="inDegrees">if set to <c>true</c> [in degrees], GribApi.NET will set the value [in degrees] when possible.</param>
        public void AsDouble(double newValue, bool inDegrees = true)
        {
            string valueKey = BuildTokenForDouble(inDegrees);

            GribApiProxy.GribSetDouble(_handle, valueKey, newValue);
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
        /// Builds the token for accesing/mutating double values, accounting for degree conversions.
        /// </summary>
        /// <param name="inDegrees">if set to <c>true</c> [in degrees].</param>
        /// <returns></returns>
        private string BuildTokenForDouble (bool inDegrees)
        {
            string valueKey = Key;

            if (inDegrees && !Key.EndsWith("InDegrees") && CanConvertToDegrees)
            {
                valueKey += "InDegrees";
            } else if (!inDegrees && Key.EndsWith("InDegrees"))
            {
                valueKey = valueKey.Substring(0, Key.Length - "InDegrees".Length);
            }

            return valueKey;
        }

        /// <summary>
        /// Determines whether this instance's value [can convert to degrees]. The ECMWF's grib_api
        /// documentation states degree conversion should be used whenever possible. Only relevant
        /// to coordinates.
        /// </summary>
        /// <returns></returns>
        public bool CanConvertToDegrees
        {
            get
            {
                string degreeToken = Key.EndsWith("InDegrees") ? Key : Key + "InDegrees";

                return GribApiProxy.GribIsDefined(_handle, degreeToken);
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
                    throw new GribApiException("To mark a value as not missing, simply set the value.");
                }

                GribApiProxy.GribSetMissing(_handle, Key);
            }

            get
            {
                int err;

                bool isMissing = GribApiProxy.GribIsMissing(_handle, Key, out err);
                
                if (err != 0)
                {
                    throw GribApiException.Create(err);
                }

                return isMissing;
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
