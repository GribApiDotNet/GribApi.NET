using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using Grib.Api.Interop;

namespace Grib.Api.Tests
{
    [TestFixture]
    public class Get
    {
        [Test]
        public void TestGetGrib2 ()
        {
            using (GribFile file = new GribFile(Settings.REDUCED_LATLON_GRB2))
            {
                using (var msg = file.First())
                {

                    double latitudeOfFirstGridPointInDegrees = msg["latitudeOfFirstGridPointInDegrees"].AsDouble();
                    Assert.AreEqual(latitudeOfFirstGridPointInDegrees, 90);
                    Assert.AreEqual(msg["latitudeOfFirstGridPointInDegrees"].NativeType, GribValueType.Double);

                    double longitudeOfFirstGridPointInDegrees = msg["longitudeOfFirstGridPointInDegrees"].AsDouble();
                    Assert.AreEqual(longitudeOfFirstGridPointInDegrees, 0);
                    double latitudeOfLastGridPointInDegrees = msg["latitudeOfLastGridPointInDegrees"].AsDouble();
                    Assert.AreEqual(latitudeOfLastGridPointInDegrees, -90);
                    double longitudeOfLastGridPointInDegrees = msg["longitudeOfLastGridPointInDegrees"].AsDouble();
                    Assert.AreEqual(longitudeOfLastGridPointInDegrees, 359.64);

                    double jDirectionIncrementInDegrees = msg["jDirectionIncrementInDegrees"].AsDouble();
                    Assert.AreEqual(jDirectionIncrementInDegrees, 0.36);
                    double iDirectionIncrementInDegrees = msg["iDirectionIncrementInDegrees"].AsDouble();
                    Assert.AreEqual(iDirectionIncrementInDegrees, -1.0E+100);

                    int numberOfPointsAlongAParallel = msg["numberOfPointsAlongAParallel"].AsInt();
                    Assert.AreEqual(numberOfPointsAlongAParallel, -1);
                    int numberOfPointsAlongAMeridian = msg["numberOfPointsAlongAMeridian"].AsInt();
                    Assert.AreEqual(numberOfPointsAlongAMeridian, 501);

                    string packingType = msg["packingType"].AsString();
                    Assert.AreEqual("grid_simple", packingType);
                    Assert.AreEqual(msg["packingType"].NativeType, GribValueType.String);
                }
            }
        }
    }
}
