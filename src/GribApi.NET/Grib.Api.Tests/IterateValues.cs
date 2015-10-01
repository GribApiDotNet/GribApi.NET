using Grib.Api.Interop.SWIG;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api.Tests
{
    [TestFixture]
    public class IterateValues
    {
        [Test]
        public void TestIterateKeyValuePairs ()
        {
            Console.WriteLine();

            using(var file = new GribFile(Settings.GAUSS))
            {
                foreach (var val in file.First())
                {
                    // TODO: some sort of actual test here
                    Console.WriteLine("{0} = {1}", val.Key, val.AsString());
                }
            }
        }

        [Test]
        public void TestIterateLatLong ()
        {
            Console.WriteLine();

            using (var file = new GribFile(Settings.REDUCED_LATLON_GRB2))
            {
                int j = 0;

                foreach (var msg in file)
                {
                    Console.WriteLine();

                    msg.Namespace = "geography";

                    foreach (var val in msg)
                    {
                        if (!val.IsDefined || val.IsMissing || val.Key == "bitmap") { continue; }
                        // TODO: some sort of actual test here
                        Console.WriteLine("{0} = {1}", val.Key, val.AsString());
                    }

                    List<double> lats = new List<double>();
                    List<double> lons = new List<double>();
                    List<double> vals = new List<double>();

                    foreach (var val in msg.GeoSpatialValues)
                    {
                        if (val.IsMissing) { continue; }

                        lats.Add(val.Latitude);
                        lons.Add(val.Longitude);
                        vals.Add(val.Value);
                    }

                    Console.WriteLine();
                    Console.WriteLine("Lat -- Max: {0} Min: {1}", lats.Max(), lats.Min());
                    Console.WriteLine("Lon -- Max: {0} Min: {1}", lons.Max(), lons.Min());
                    Console.WriteLine("Val -- Max: {0} Min: {1} Avg: {2} Count: {3}", vals.Max(), vals.Min(), vals.Average(), vals.Count());
                }
            }
        }
    }
}
