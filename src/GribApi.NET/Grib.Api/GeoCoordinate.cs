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

namespace Grib.Api
{
    /// <summary>
    /// A geospatial coordinate.
    /// </summary>
    public struct GeoCoordinate : IGeoCoordinate, IEquatable<GeoCoordinate>
    {
        /// <summary>
        /// Gets or sets the latitude for this coordinate.
        /// </summary>
        /// <value>
        /// The latitude.
        /// </value>
        public double Latitude { get; set; }
        /// <summary>
        /// Gets or sets the longitude for this coordinate.
        /// </summary>
        /// <value>
        /// The longitude.
        /// </value>
        public double Longitude { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="GeoCoordinate"/> struct.
        /// </summary>
        /// <param name="lat">The lat.</param>
        /// <param name="lon">The lon.</param>
        public GeoCoordinate(double lat, double lon) : this()
        {
            this.Latitude = lat;
            this.Longitude = lon;
        }

        /// <summary>
        /// Equals the specified value.
        /// </summary>
        /// <param name="that">The that.</param>
        /// <returns></returns>
        public bool Equals (GeoCoordinate that)
        {
            return (this.Latitude == that.Latitude) &&
                   (this.Longitude == that.Longitude);
        }

        /// <summary>
        /// Determines whether the specified <see cref="System.Object" />, is equal to this instance.
        /// </summary>
        /// <param name="obj">The <see cref="System.Object" /> to compare with this instance.</param>
        /// <returns>
        ///   <c>true</c> if the specified <see cref="System.Object" /> is equal to this instance; otherwise, <c>false</c>.
        /// </returns>
        public override bool Equals (object obj)
        {
            return (obj is GeoCoordinate) && this.Equals((GeoCoordinate)obj);
        }

        /// <summary>
        /// Returns a hash code for this instance.
        /// </summary>
        /// <returns>
        /// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table. 
        /// </returns>
        public override int GetHashCode()
        {
            return this.Latitude.GetHashCode() ^ this.Longitude.GetHashCode();
        }

        /// <summary>
        /// Implements the operator ==.
        /// </summary>
        /// <param name="a">a.</param>
        /// <param name="b">The b.</param>
        /// <returns>
        /// The result of the operator.
        /// </returns>
        public static bool operator == (GeoCoordinate a, GeoCoordinate b)
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
        public static bool operator != (GeoCoordinate a, GeoCoordinate b)
        {
            return !(a.Equals(b));
        }
    }
}
