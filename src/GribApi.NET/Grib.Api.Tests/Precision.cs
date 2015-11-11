using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api.Tests
{
    [TestFixture]
    public class Precision
    {
        [Test]
        public void TestPrecision ()
        {
            var file = new GribFile(Settings.GAUSS);
            var msg = file.First();
            Assert.AreEqual(msg["bitsPerValue"].AsInt(), 13);
            msg.DecimalPrecision = 4;
            Assert.AreEqual(msg["bitsPerValue"].AsInt(), 20);
        }
    }
}
