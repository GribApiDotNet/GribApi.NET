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
    public struct GeoCoordinate : IGeoCoordinate
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
    }
}
