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


namespace Grib.Api
{
    /// <summary>
    /// A GRIB grid value with coordinates.
    /// </summary>
    public struct GeoSpatialValue : IGeoCoordinate
    {
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public double Value { get; set; }
        public bool IsMissing { get; private set; }

        public GeoSpatialValue(double lat, double lon, double val, bool isMissing) :this()
        {
            this.Latitude = lat;
            this.Longitude = lon;
            this.Value = val;
            this.IsMissing = isMissing;
        }

        /// <summary>
        /// Equals the specified value.
        /// </summary>
        /// <param name="that">The that.</param>
        /// <returns></returns>
        public bool Equals (GeoSpatialValue that)
        {
            return (this.Latitude == that.Latitude) &&
                (this.Longitude == that.Longitude) && 
                (this.Value == that.Value);
        }

        /// <summary>
        /// Implements the operator ==.
        /// </summary>
        /// <param name="a">a.</param>
        /// <param name="b">The b.</param>
        /// <returns>
        /// The result of the operator.
        /// </returns>
        public static bool operator ==(GeoSpatialValue a, GeoSpatialValue b)
        {
            if (System.Object.ReferenceEquals(a, b))
            {
                return true;
            }

            return a.Equals(b);
        }

        /// <summary>
        /// Implements the operator !=.
        /// </summary>
        /// <param name="a">a.</param>
        /// <param name="b">The b.</param>
        /// <returns>
        /// The result of the operator.
        /// </returns>
        public static bool operator !=(GeoSpatialValue a, GeoSpatialValue b)
        {
            return !(a.Equals(b));
        }
    }
}
