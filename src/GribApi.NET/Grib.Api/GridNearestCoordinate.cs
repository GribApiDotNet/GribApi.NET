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

namespace Grib.Api
{
    /// <summary>
    /// Describes a grid coordinate and its relative distance to another grid coordinate.
    /// </summary>
    public struct GridNearestCoordinate
	{
		public GridCoordinateValue Value;
		public double Distance;
		public int Index;

		public GridNearestCoordinate (double latitude, double longitude, double value, double distance, int index)
		{
			this.Distance = distance;
			this.Index = index;
			this.Value = new GridCoordinateValue(latitude, longitude, value, false);
		}
	}
}
