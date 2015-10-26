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

using Grib.Api.Interop.SWIG;

namespace Grib.Api.Interop
{
    /// <summary>
    /// Values returned by grib_api to indicate the type associated with a key.
    /// </summary>
    /// <remarks>
    /// /* Types */
    ///  /*  undefined */
    ///  #define GRIB_TYPE_UNDEFINED 0
    ///  /*  long integer */
    ///  #define GRIB_TYPE_LONG 1
    ///  /*  double */
    ///  #define GRIB_TYPE_DOUBLE 2
    ///  /*  char*    */
    ///  #define GRIB_TYPE_STRING 3
    ///  /*  bytes */
    ///  #define GRIB_TYPE_BYTES 4
    ///  /*  section */
    ///  #define GRIB_TYPE_SECTION 5
    ///  /*  label */
    ///  #define GRIB_TYPE_LABEL 6
    ///  /*  missing */
    ///  #define GRIB_TYPE_MISSING 7
    /// </remarks>
    public enum GribValueType
    {
        Undefined = 0,
        Int = 1,
        Double = 2,
        String = 3,
        Bytes = 4,
        Section = 5,
        Label = 6,
        Missing = 7,

        // uninque to GribApi.NET
        IntArray = 1000,
        DoubleArray = 1001
    }

    public static class GribValueTypeExtension
    {
        /// <summary>
        /// Retrieves the GRIB key's type name.
        /// </summary>
        /// <param name="vt">The vt.</param>
        /// <returns></returns>
        public static string AsString(this GribValueType vt)
        {
            if ((int)vt >= (int)GribValueType.IntArray)
            {
                return vt.ToString();
            }

            return GribApiProxy.GribGetTypeName((int) vt);
        }
    }
}
