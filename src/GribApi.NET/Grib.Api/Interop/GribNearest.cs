// Copyright 2017 Eric Millin
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
using System;

namespace Grib.Api.Interop
{
    [Flags]
    public enum GribNearestToSame : uint
    {
        GRID = 1 << 0,
        DATA = 1 << 1,
        POINT = 1 << 2
    }

    public class GribNearest : AutoRef
    {
        public SWIGTYPE_p_grib_nearest Nearest = null;
        public GribHandle Handle = null;

        internal GribNearest (SWIGTYPE_p_grib_nearest nearest, GribHandle handle) : base()
        {
            this.Reference = SWIGTYPE_p_grib_nearest.getCPtr(nearest);
            this.Nearest = nearest;
            this.Handle = handle;
        }

        protected override void OnDispose (bool disposing)
        {
            if (this.pReference != IntPtr.Zero)
            {
                GribApiProxy.GribNearestDelete(Nearest);
                this.Nearest = null;
                this.Handle = null;
            }
        }

        /// <summary>
        /// Find the nearest four points to a coordinate.
        /// </summary>
        /// <param name="latitude">The reference latitude.</param>
        /// <param name="longitude">The reference longitude.</param>
        /// <param name="searchType"> If you are sure that the point you are asking for is not changing from
        /// a call to another you can use POINT. The same is valid for the grid. Flags can be used together
        /// doing a bitwise OR. The distances are given in kilometres.</param>
        /// <returns>An array of the nearest four coordinates sorted by distance.</returns>
        public GridNearestCoordinate[] FindNearestCoordinates (double latitude, double longitude, GribNearestToSame searchType = GribNearestToSame.POINT)
        {
            var latitudes = new double[] { 0, 0, 0, 0 };
            var longitudes = new double[] { 0, 0, 0, 0 };
            var distances = new double[] { 0, 0, 0, 0 };
            var values = new double[] { 0, 0, 0, 0 };
            var indexes = new int[] { 0, 0, 0, 0 };

            Interop.SizeT len = 4;
            Interop.SWIG.GribApiProxy.GribNearestFind(this.Nearest, this.Handle, latitude, longitude, (uint)searchType,
                                                    latitudes, longitudes, values, distances,
                                                    indexes, ref len);

            var vals = new GridNearestCoordinate[len];

            for (var i = 0; i < len; i++)
            {
                vals[i] = new GridNearestCoordinate(latitudes[i], longitudes[i], values[i], distances[i], indexes[i]);
            }

            Array.Sort(vals, (v1, v2) => v1.Distance.CompareTo(v2.Distance));

            return vals;
        }

        ///// <summary>
        ///// Find the nearest point of a set of points whose latitudes and longitudes.
        ///// </summary>
        ///// <param name="coordinates">The reference coordinates.</param>
        ///// <param name="useLandSeaMask">If true, the nearest land point is returned and the grib passed as the handle is considered a land sea mask.
        ///// land nearest point is the nearest point with land sea mask value>=0.5. If no nearest land points are found the nearest value is returned.
        ///// If the flag false, the nearest points, along with values, distances, and indexes are returned.
        ///// </param>
        ///// <returns></returns>
        //public GribNearestCoordinate[] FindNearestCoordinates(IGeoCoordinate[] coordinates, bool useLandSeaMask = false)
        //{
        //	var len = coordinates.Length;
        //	var latitudes = new double[len];
        //	var longitudes = new double[len];
        //	var outLatitudes = new double[len];
        //	var outLongitudes = new double[len];
        //	var distances = new double[len];
        //	var values = new double[len];
        //	var indexes = new int[len];

        //	for (var i = 0; i < len; i++) 
        //	{
        //		latitudes[i] = coordinates[i].Latitude;
        //		longitudes[i] = coordinates[i].Longitude;
        //	}

        //	Interop.SizeT sz = (SizeT)len;
        //	Interop.SWIG.GribApiProxy.GribNearestFindMultiple(this.Handle, useLandSeaMask ? 1 : 0, latitudes, longitudes, len,
        //											          outLatitudes, outLongitudes, values, distances, indexes);

        //	var vals = new GribNearestCoordinate[len];

        //	for (var i = 0; i < len; i++)
        //	{
        //		vals[i] = new GribNearestCoordinate(latitudes[i], longitudes[i], values[i], distances[i], indexes[i]);
        //	}

        //	Array.Sort(vals, (v1, v2) => v1.Distance.CompareTo(v2.Distance));

        //	return vals;
        //}

        public static GribNearest Create (GribHandle handle)
        {
            int err = 0;

            var nearest = GribApiProxy.GribNearestNew(handle, out err);

            if (err != 0)
            {
                throw GribApiException.Create(err);
            }

            return new GribNearest(nearest, handle);
        }
    }
}
