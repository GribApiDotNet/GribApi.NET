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
            Console.WriteLine("Bit per value: {0}", msg["bitsPerValue"].AsInt());
            Console.WriteLine("Precision: {0}", msg.DecimalPrecision);
            msg.DecimalPrecision = 4;
            Console.WriteLine("Bit per value: {0}", msg["bitsPerValue"].AsInt());
        }
    }
}
