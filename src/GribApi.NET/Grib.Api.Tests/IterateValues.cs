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
            using(var file = new GribFile(Settings.BIN))
            {
                Assert.IsTrue(file.MessageCount > 0);
                Assert.IsTrue(file.First().Any());
            }
        }

        [Test]
        public void TestIterateLatLong ()
        {
            Console.WriteLine();

            using (var file = new GribFile(Settings.REDUCED_LATLON_GRB2))
            {
                Assert.IsTrue(file.MessageCount > 0);
                foreach (var msg in file)
                {
                    int c = msg.Count();

                    msg.Namespace = "geography";

                    Assert.AreNotEqual(c, msg.Count());

                    Assert.IsTrue(msg.GeoSpatialValues.Any());
                }
            }
        }
    }
}
