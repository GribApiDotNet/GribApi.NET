using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api.Tests
{
    [TestFixture]
    public class Write
    {

		[Test, Timeout(2000)]
		public void TestWrite()
		{
			if (File.Exists(Settings.OUT_GRIB)) {
				File.Delete(Settings.OUT_GRIB);
			}

			int count = 0;
			int valCount = 0;

			using (var readFile = new GribFile(Settings.PACIFIC_WIND)) {
				var msg = readFile.First();
				Assert.AreNotEqual(33, msg["latitudeOfFirstGridPoint"].AsDouble());
				msg["latitudeOfFirstGridPoint"].AsDouble(33);
				valCount = msg.ValuesCount;
				GribFile.Write(Settings.OUT_GRIB, msg);
			}

			using (var readFile = new GribFile(Settings.OUT_GRIB)) {
				var msg = readFile.First();
				count = readFile.MessageCount;
				Assert.AreEqual(valCount, msg.ValuesCount);
				Assert.AreEqual(count, readFile.MessageCount);
				Assert.AreEqual(33, msg["latitudeOfFirstGridPoint"].AsDouble());
			}

			using (var readFile = new GribFile(Settings.PACIFIC_WIND)) {
				GribFile.Write(Settings.OUT_GRIB, readFile as IEnumerable<GribMessage>, FileMode.Append);
				count += readFile.MessageCount;
			}

			using (var readFile = new GribFile(Settings.OUT_GRIB)) {
				Assert.AreEqual(count, readFile.MessageCount);
				Assert.AreEqual(33, readFile.First()["latitudeOfFirstGridPoint"].AsDouble());
			}
		}

		public void TestCompression (string grid)
        {
            if (File.Exists(Settings.OUT_GRIB))
            {
                File.Delete(Settings.OUT_GRIB);
            }

            int count = 0;
            double val = Double.NaN;

            Dictionary<int, GeoSpatialValue> orig = new Dictionary<int, GeoSpatialValue>();

            using (var readFile = new GribFile(Settings.REDUCED_LATLON_GRB2))
            {
				var msg = readFile.First();
                count = msg.ValuesCount;
                val = msg["latitudeOfFirstGridPoint"].AsDouble();
                Assert.AreNotEqual(val, Double.NaN);
                Assert.AreNotEqual(msg["packingType"].AsString(), grid);

                {
                    for (int j = 0; j < 50; j++)
                    {
                        int k = 0;

                        do
                        {
                            // over 200k values, so only pick from a subset
                            k = GetRandomNumber(0, (count) / 20);
                        }
                        while (orig.ContainsKey(k));

                        orig.Add(k, new GeoSpatialValue());
                    }

                    int x = 0;
                    int y = 0;
                    foreach(var gsv in msg.GeoSpatialValues)
                    {
                        if (orig.ContainsKey(x))
                        {
                            orig[x] = gsv;
                            y++;
                            if (y == orig.Count) break;
                        }
                        x++;
                    }

                    Assert.IsTrue(y == orig.Count);
                    Assert.IsTrue(x > 0);
                }

                msg["packingType"].AsString(grid);
                Assert.AreEqual(msg["packingType"].AsString(), grid);
                Assert.AreEqual(count, msg.ValuesCount);
                Assert.AreEqual(val, msg["latitudeOfFirstGridPoint"].AsDouble());
                GribFile.Write(Settings.OUT_GRIB, msg);

                var newGsv = msg.GeoSpatialValues.ToArray();
                Assert.IsTrue(newGsv.Any());

                foreach (var kvp in orig)
                {
                    var nv = newGsv[kvp.Key];
                    Assert.AreEqual(kvp.Value.Value, nv.Value, 0.01);
                }
            }

            using (var readFile = new GribFile(Settings.OUT_GRIB))
            {
				var msg = readFile.First();
                Assert.AreEqual(count, msg.ValuesCount);
                Assert.AreEqual(val, msg["latitudeOfFirstGridPoint"].AsDouble());
                Assert.AreEqual(msg["packingType"].AsString(), grid);

                var newGsv = msg.GeoSpatialValues.ToArray();
                Assert.IsTrue(newGsv.Any());

                foreach (var kvp in orig)
                {
                    var nv = newGsv[kvp.Key];
                    Assert.AreEqual(kvp.Value.Value, nv.Value, 0.01);
                }
            }
        }


		[Test, Timeout(2000)]
		public void TestPng()
		{
			TestCompression("grid_png");
		}

		[Test, Timeout(2000)]
		public void TestJpeg()
		{
			TestCompression("grid_jpeg");
		}

		//Function to get random number
		private static readonly Random getrandom = new Random();

        public static int GetRandomNumber (int min, int max)
        {
            return getrandom.Next(min, max);
        }
    }
}
