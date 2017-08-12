namespace Grib.Api.Interop
{
    public struct GribNearestCoordinate
	{
		public GeoCoordinateValue Value;
		public double Distance;
		public int Index;

		public GribNearestCoordinate (double latitude, double longitude, double value, double distance, int index)
		{
			this.Distance = distance;
			this.Index = index;
			this.Value = new GeoCoordinateValue(latitude, longitude, value, false);
		}
	}
}
