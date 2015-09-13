using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api.Tests
{
    [TestFixture]
    public class IterateKeys
    {
        [Test]
        public void TestIterateKeys ()
        {
            var file = new GribFile(Settings.GRIB);

            foreach (var msg in file)
            {
                foreach (var val in msg)
                {
                    Console.WriteLine("{0} = {1}", val.KeyName, val.AsString());
                }

                Console.WriteLine();
            }
        }

        [Test]
        public void IterateLatLong ()
        {
            var file = new GribFile(Settings.PACIFIC_WIND);
            foreach (var msg in file)
            {
                int i = 0;
                foreach (var val in msg.SpatialValues)
                {
                    if (val.IsMissing) { continue; }

                    Console.WriteLine("{0} - Lat: {1} Lon: {2} Value: {3}", i, val.Coordinate.Latitude, val.Coordinate.Longitude, val.Value);
                    i++;
                }
                var vals = msg.Values.Where(x => x != msg.MissingValue);
                Console.WriteLine("Max: {0} Min: {1} Avg: {2}", vals.Max(), vals.Min(), vals.Average());
            }
        }
    }
}
