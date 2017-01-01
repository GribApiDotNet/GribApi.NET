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
using Grib.Api.Interop.Util;

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
        /// <returns></returns>
        public virtual string AsString ()
        {
            if (!IsDefined || _asStringBlacklist.Contains(NativeType) ) { return String.Empty; }

            SizeT ptLen = 0;
            string valueKey = Key;

            if (CanConvertToDegrees)
            {
                valueKey = BuildTokenForDouble();
            }

            // not sure it's worth checking the length here--could just use MAX_VAL_LEN
            GribApiProxy.GribGetLength(_handle, valueKey, ref ptLen);
            StringBuilder msg = new StringBuilder((int) ptLen);

            GribApiProxy.GribGetString(_handle, valueKey, msg, ref ptLen);

            return msg.ToString().Trim();
        }

        /// <summary>
        /// Sets the key's value.
        /// </summary>
        /// <param name="newValue">The new value.</param>
        public virtual void AsString (string newValue)
        {
            AssertTypeSafe(GribValueType.String);

            SizeT len = (SizeT) newValue.Length;
            GribApiProxy.GribSetString(_handle, Key, newValue, ref len);
        }

        /// <summary>
        /// Gets the key's value in bytes.
        /// </summary>
        /// <returns></returns>
        public byte[] AsBytes ()
        {
            AssertTypeSafe(GribValueType.Bytes);

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
        public void AsBytes (byte[] newBytes)
        {
            AssertTypeSafe(GribValueType.Bytes);

            SizeT sz = (SizeT) newBytes.Length;
            GribApiProxy.GribSetBytes(_handle, Key, newBytes, ref sz);
        }

        /// <summary>
        /// Gets the key's value.
        /// </summary>
        /// <returns></returns>
        public virtual int AsInt ()
        {
            AssertTypeSafe(GribValueType.Int);

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
            AssertTypeSafe(GribValueType.Int);

            GribApiProxy.GribSetLong(_handle, Key, newValue);
        }

        /// <summary>
        /// Gets a copy of the key's array value. Changing the values of this array does not affect the owning message.
        /// Call ::AsXArray(alteredArray) to set new values.
        /// </summary>
        /// <returns>Returns a *copy* of the key's array.</returns>
        public virtual int[] AsIntArray ()
        {
            AssertTypeSafe(GribValueType.IntArray);

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
        public virtual void AsIntArray (int[] newValues)
        {
            AssertTypeSafe(GribValueType.IntArray);

            GribApiProxy.GribSetLongArray(_handle, Key, newValues, (SizeT)newValues.Length);
        }

        /// <summary>
        /// Gets the key's value.
        /// </summary>
        /// <returns></returns>
        public virtual double AsDouble ()
        {
            string valueKey = BuildTokenForDouble();

            AssertTypeSafe(valueKey, NativeTypeForKey(valueKey), GribValueType.Double);

            double val;

            GribApiProxy.GribGetDouble(_handle, valueKey, out val);

            return val;
        }

        /// <summary>
        /// Sets the key's value.
        /// </summary>
        /// <param name="newValue">The new value.</param>
        public virtual void AsDouble (double newValue)
        {
            string valueKey = BuildTokenForDouble();

            AssertTypeSafe(valueKey, NativeTypeForKey(valueKey), GribValueType.Double);

            GribApiProxy.GribSetDouble(_handle, valueKey, newValue);
        }

        /// <summary>
        /// Gets a copy of the key's array value. Changing the values of this array does not affect the owning message.
        /// Call ::AsXArray(alteredArray) to set new values.
        /// </summary>
        /// <returns>Returns a *copy* of the key's array.</returns>
        public virtual double[] AsDoubleArray ()
        {
            AssertTypeSafe(GribValueType.DoubleArray);

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
                GribApiProxy.GribSetForceDoubleArray(_handle, Key, newValues, (SizeT)newValues.Length);
            } else
            {
                AssertTypeSafe(GribValueType.DoubleArray);

                GribApiProxy.GribSetDoubleArray(_handle, Key, newValues, (SizeT)newValues.Length);
            }
        }

        /// <summary>
        /// Builds the token for accesing/mutating double values, accounting for degree conversions.
        /// </summary>
        /// <returns></returns>
        protected string BuildTokenForDouble ()
        {
            string valueKey = Key;

            if (CanConvertToDegrees && !Key.EndsWith("InDegrees"))
            {
                valueKey += "InDegrees";
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
        /// Gets a value indicating whether this value is read only.
        /// </summary>
        /// <value>
        /// <c>true</c> if this instance is read only; otherwise, <c>false</c>.
        /// </value>
        public bool IsReadOnly
        {
            get
            {
                return GribApiNative.GribKeyIsReadOnly(_handle.Reference, Key);
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
        /// <param name="requestedType">The expected type.</param>
        private void AssertTypeSafe (GribValueType requestedType)
        {
            GribValue.AssertTypeSafe(Key, requestedType, NativeType);
        }

        /// <summary>
        /// Tests for type safety when accessing a GRIB value.
        /// </summary>
        /// <param name="key">The key.</param>
        /// <param name="requestedType">The requested type.</param>
        /// <param name="actualType">The actual type.</param>
        /// <exception cref="GribValueTypeException"></exception>
        private static void AssertTypeSafe(string key, GribValueType requestedType, GribValueType actualType)
        {
            if (requestedType != actualType)
            {
                throw new GribValueTypeException(String.Format("Invalid type conversion. Key {0} is GRIB type {1}",
                                                                key, actualType.AsString()));
            }
        }
    }
}
