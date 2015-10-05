// Copyright 2015 Eric Millin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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

        private GribHandle _handle;
        private readonly static GribValueType[] _asStringBlacklist = { GribValueType.IntArray, 
                                                                       GribValueType.DoubleArray,
                                                                       GribValueType.Bytes };

        /// <summary>
        /// Initializes a new instance of the <see cref="GribValue" /> class.
        /// </summary>
        /// <param name="keyName">Name of the key.</param>
        internal GribValue (string keyName)
        {
            Key = keyName;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="GribValue"/> class.
        /// </summary>
        /// <param name="handle">The handle.</param>
        /// <param name="keyName">Name of the key.</param>
        internal GribValue (GribHandle handle, string keyName)
        {
            _handle = handle;
            Key = keyName;
        }

        /// <summary>
        /// Gets the key's value.
        /// </summary>
        /// <param name="inDegrees">if set to <c>true</c>, GribApi.NET will convert the value to degrees when possible.</param>
        /// <returns></returns>
        public virtual string AsString (bool inDegrees = true)
        {
            if (!IsDefined || _asStringBlacklist.Contains(NativeType) ) { return String.Empty; }

            SizeT ptLen = 0;
            string valueKey = Key;

            if (CanConvertToDegrees)
            {
                valueKey = BuildTokenForDouble(inDegrees);
            }

            // not sure it's worth checking the length here--could just use MAX_VAL_LEN
            GribApiProxy.GribGetLength(_handle, valueKey, ref ptLen);
            StringBuilder msg = new StringBuilder((int) ptLen);

            GribApiProxy.GribGetString(_handle, valueKey, msg, ref ptLen);

            return msg.ToString();
        }

        /// <summary>
        /// Sets the key's value.
        /// </summary>
        /// <param name="newValue">The new value.</param>
        public virtual void AsString (string newValue)
        {
            SizeT len = new SizeT((uint)newValue.Length);
            GribApiProxy.GribSetString(_handle, Key, newValue, ref len);
        }

        /// <summary>
        /// Gets the key's value in bytes.
        /// </summary>
        /// <returns></returns>
        public byte[] AsBytes ()
        {
            if (!IsDefined) { return new byte[0]; }

            TestTypeSafe(GribValueType.Bytes);

            SizeT sz = 0;
            GribApiProxy.GribGetSize(_handle, Key, ref sz);
            byte[] bytes = new byte[sz];

            GribApiProxy.GribGetBytes(_handle, Key, bytes, ref sz);

            return bytes;
        }

        /// <summary>
        /// Sets the key's value in bytes.
        /// </summary>
        /// <param name="newBytes">The new bytes.</param>
        public void AsBytes(byte[] newBytes)
        {
            SizeT sz = new SizeT(newBytes.Length);
            GribApiProxy.GribSetBytes(_handle, Key, newBytes, ref sz);
        }

        /// <summary>
        /// Gets the key's value.
        /// </summary>
        /// <returns></returns>
        public virtual int AsInt ()
        {
            if (!IsDefined) { return 0; }

            TestTypeSafe(GribValueType.Int);

            int val;

            GribApiProxy.GribGetLong(_handle, Key, out val);

            return val;
        }

        /// <summary>
        /// Sets the key's value.
        /// </summary>
        /// <param name="newValue">The new value.</param>
        public virtual void AsInt (int newValue)
        {
            GribApiProxy.GribSetLong(_handle, Key, newValue);
        }

        /// <summary>
        /// Gets a copy of the key's array value. Changing the values of this array does not affect the owning message.
        /// Call ::AsXArray(alteredArray) to set new values.
        /// </summary>
        /// <returns>If the value is defined, returns a *copy* of the key's array. Otherwise returns empty array.</returns>
        public virtual int[] AsIntArray ()
        {
            if (!IsDefined) { return new int[0]; }

            TestTypeSafe(GribValueType.IntArray);

            SizeT sz = 0;
            GribApiProxy.GribGetSize(_handle, Key, ref sz);

            int[] values = new int[sz];
            GribApiProxy.GribGetLongArray(_handle, Key, values, ref sz);

            return values;
        }

        /// <summary>
        /// Sets the key's value.
        /// </summary>
        /// <param name="newValues">The new values.</param>
        public virtual void AsIntArray(int[] newValues)
        {
            GribApiProxy.GribSetLongArray(_handle, Key, newValues, new SizeT(newValues.Length));
        }

        /// <summary>
        /// Gets the key's value.
        /// </summary>
        /// <param name="inDegrees">if set to <c>true</c>, GribApi.NET will return the value [in degrees] when possible.</param>
        /// <returns></returns>
        public virtual double AsDouble (bool inDegrees = true)
        {
            if (!IsDefined) { return Double.NaN; }

            double val;
            string valueKey = BuildTokenForDouble(inDegrees);

            TestTypeSafe(valueKey, NativeTypeForKey(valueKey), GribValueType.Double);

            GribApiProxy.GribGetDouble(_handle, valueKey, out val);

            return val;
        }

        /// <summary>
        /// Sets the key's value.
        /// </summary>
        /// <param name="newValue">The new value.</param>
        /// <param name="inDegrees">if set to <c>true</c> [in degrees], GribApi.NET will set the value [in degrees] when possible.</param>
        public virtual void AsDouble (double newValue, bool inDegrees = true)
        {
            string valueKey = BuildTokenForDouble(inDegrees);

            GribApiProxy.GribSetDouble(_handle, valueKey, newValue);
        }

        /// <summary>
        /// Gets a copy of the key's array value. Changing the values of this array does not affect the owning message.
        /// Call ::AsXArray(alteredArray) to set new values.
        /// </summary>
        /// <returns>If the value is defined, returns a *copy* of the key's array. Otherwise returns 0-length array.</returns>
        public virtual double[] AsDoubleArray ()
        {
            if (!IsDefined) { return new double[0]; }

            TestTypeSafe(GribValueType.DoubleArray);

            SizeT sz = 0;
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
        public virtual void AsDoubleArray (double[] newValues, bool force = false)
        {
            if (force)
            {
                GribApiProxy.GribSetForceDoubleArray(_handle, Key, newValues, new SizeT(newValues.Length));
            } else
            {
                GribApiProxy.GribSetDoubleArray(_handle, Key, newValues, new SizeT(newValues.Length));
            }
        }

        /// <summary>
        /// Builds the token for accesing/mutating double values, accounting for degree conversions.
        /// </summary>
        /// <param name="inDegrees">if set to <c>true</c> [in degrees].</param>
        /// <returns></returns>
        protected string BuildTokenForDouble (bool inDegrees)
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
        /// Returns a <see cref="System.String" /> that represents the value as a string.
        /// </summary>
        /// <returns>
        /// A <see cref="System.String" /> that represents the value as a string.
        /// </returns>
        public override string ToString ()
        {
            return this.AsString();
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
        public string Key { get; protected set; }

        /// <summary>
        /// Gets or sets a value indicating whether the value associated with this key is missing.
        /// </summary>
        /// <value>
        /// <c>true</c> if this value is missing; otherwise, <c>false</c>.
        /// </value>
        public bool IsMissing
        {
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
        public virtual GribValueType NativeType
        {
            get
            {
                GribValueType nativeType = NativeTypeForKey(Key);

                // int[] and double[] values are return as int and double, so
                // determine if the value is an array
                if (nativeType == GribValueType.Int ||
                    nativeType == GribValueType.Double)
                {
                    SizeT sz = 0;
                    GribApiProxy.GribGetSize(_handle, Key, ref sz);

                    if (sz > 1)
                    {
                        nativeType = (nativeType == GribValueType.Int) ?
                                        GribValueType.IntArray :
                                        GribValueType.DoubleArray;
                    }

                }

                return nativeType;
            }
        }

        /// <summary>
        /// Gets an enum describing a key's representation within the message.
        /// </summary>
        /// <param name="key">The key.</param>
        /// <returns></returns>
        private GribValueType NativeTypeForKey(string key)
        {
            int type = 0;

            GribApiProxy.GribGetNativeType(_handle, key, out type);

            return (GribValueType) type;
        }

        /// <summary>
        /// Tests for type safety when accessing this value.
        /// </summary>
        /// <param name="expectedType">The expected type.</param>
        private void TestTypeSafe (GribValueType expectedType)
        {
            GribValue.TestTypeSafe(Key, expectedType, NativeType);
        }

        /// <summary>
        /// Tests for type safety when accessing a GRIB value.
        /// </summary>
        /// <param name="key">The key.</param>
        /// <param name="expectedType">The expected type.</param>
        /// <param name="actualType">The actual type.</param>
        /// <exception cref="GribValueTypeException"></exception>
        private static void TestTypeSafe(string key, GribValueType expectedType, GribValueType actualType)
        {
            if (expectedType != actualType)
            {
                throw new GribValueTypeException(String.Format("Invalid type conversion. Key {0} is GRIB type {1}",
                                                                key, expectedType.AsString()));
            }
        }
    }
}
