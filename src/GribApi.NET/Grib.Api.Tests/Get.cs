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
                    // "InDegrees" is a magic token that converts coordinate double values to degrees

                    Assert.IsTrue(msg["latitudeOfFirstGridPointInDegrees"].CanConvertToDegrees);
                    // explicit degree conversion via key name
                    double latitudeOfFirstGridPointInDegrees = msg["latitudeOfFirstGridPointInDegrees"].AsDouble(true /* default value */);
                    Assert.AreEqual(latitudeOfFirstGridPointInDegrees, 90);
                    // accessor override key name degree conversion
                    Assert.AreNotEqual(msg["latitudeOfFirstGridPointInDegrees"].AsDouble(false), latitudeOfFirstGridPointInDegrees);
                    Assert.AreEqual(msg["latitudeOfFirstGridPointInDegrees"].NativeType, GribValueType.Double);

                    Assert.IsTrue(msg["longitudeOfFirstGridPoint"].CanConvertToDegrees);
                    // degree conversion via accessor
                    double longitudeOfFirstGridPointInDegrees = msg["longitudeOfFirstGridPoint"].AsDouble(/* inDegrees == true */);
                    Assert.AreEqual(longitudeOfFirstGridPointInDegrees, 0);

                    Assert.IsTrue(msg["latitudeOfLastGridPoint"].CanConvertToDegrees);
                    // degree conversion via accessor
                    double latitudeOfLastGridPointInDegrees = msg["latitudeOfLastGridPoint"].AsDouble(/* inDegrees == true */);
                    Assert.AreEqual(latitudeOfLastGridPointInDegrees, -90);

                    Assert.IsTrue(msg["latitudeOfLastGridPoint"].CanConvertToDegrees);
                    // degree conversion via accessor
                    double longitudeOfLastGridPointInDegrees = msg["longitudeOfLastGridPoint"].AsDouble(/* inDegrees == true */);
                    Assert.AreEqual(longitudeOfLastGridPointInDegrees, 359.64);
                    // access without degree conversion
                    Assert.AreNotEqual(longitudeOfLastGridPointInDegrees, msg["longitudeOfLastGridPoint"].AsDouble(false));

                    Assert.IsTrue(msg["jDirectionIncrement"].CanConvertToDegrees);
                    // degree conversion via accessor
                    double jDirectionIncrementInDegrees = msg["jDirectionIncrement"].AsDouble(/* inDegrees == true */);
                    Assert.AreEqual(jDirectionIncrementInDegrees, 0.36);

                    Assert.IsTrue(msg["iDirectionIncrement"].CanConvertToDegrees);
                    // degree conversion via accessor
                    double iDirectionIncrementInDegrees = msg["iDirectionIncrement"].AsDouble(/* inDegrees == true */);
                    Assert.AreEqual(iDirectionIncrementInDegrees, -1.0E+100);

                    Assert.IsFalse(msg["numberOfPointsAlongAParallel"].CanConvertToDegrees);
                    int numberOfPointsAlongAParallel = msg["numberOfPointsAlongAParallel"].AsInt();
                    Assert.AreEqual(numberOfPointsAlongAParallel, -1);

                    Assert.IsFalse(msg["numberOfPointsAlongAMeridian"].CanConvertToDegrees);
                    int numberOfPointsAlongAMeridian = msg["numberOfPointsAlongAMeridian"].AsInt();
                    Assert.AreEqual(numberOfPointsAlongAMeridian, 501);

                    Assert.IsFalse(msg["packingType"].CanConvertToDegrees);
                    string packingType = msg["packingType"].AsString();
                    Assert.AreEqual("grid_simple", packingType);
                    Assert.AreEqual(msg["packingType"].NativeType, GribValueType.String);
                }
            }
        }
    }
}
