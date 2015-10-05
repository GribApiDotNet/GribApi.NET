using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Grib.Api.Tests
{
    [TestFixture]
    public class SetBitmap
    {
        [Test]
        public void TestSetBitmapMissing ()
        {
            using (GribFile file = new GribFile(Settings.REG_LATLON_GRB1))
            {
                var msg = file.First();
                int missing = 3333;
                // set the value used to represent missing data
                msg.MissingValue = missing;
                Assert.AreEqual(msg.MissingValue, missing);

                int numVals = 10;
                double[] vals = msg.Values;

                for (int i = 0; i < numVals; i++)
                {
                    vals[i] = missing;
                }

                msg.HasBitmap = true;
                msg.Values = vals;

                for (int i = 0; i < numVals; i++)
                {
                    Assert.AreEqual(vals[i], msg.Values[i]);
                    Assert.AreEqual(missing, msg.Values[i]);
                }

                missing = 9898;
                msg.MissingValue = missing;

                for (int i = 0; i < numVals; i++)
                {
                    Assert.AreEqual(missing, msg.Values[i]);
                }
            }
        }

        [Test]
        public void TestSetBitmap()
        {
            using (GribFile file = new GribFile(Settings.REG_LATLON_GRB1))
            {
                var msg = file.First();

                int numVals = 10;
                double[] vals = msg.Values;
                double val = 42;

                for(int i =0; i < numVals; i++)
                {
                    vals[i] = val;
                }

                msg.HasBitmap = true;
                msg.Values = vals;

                for (int i = 0; i < numVals; i++)
                {
                    Assert.AreEqual(vals[i], msg.Values[i]);
                    Assert.AreEqual(val, msg.Values[i]);
                }                
            }
        }

    }
}
