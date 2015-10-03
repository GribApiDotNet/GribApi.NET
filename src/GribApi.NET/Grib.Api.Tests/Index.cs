using Grib.Api.Interop;
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
    public class Index
    {
        [Test]
        public void IndexTest ()
        {
            //int err = 0;
            //var c = GribApiProxy.GribContextGetDefault();
            //var index = GribApiProxy.GribIndexNew(c, "shortName,level,number,step", out err);
            //GribApiProxy.GribIndexAddFile(index, Settings.GRIB);
            //SizeT sz = new SizeT();
            //GribApiProxy.GribIndexGetSize(index, "step", ref sz);
            //int[] values = new int[sz];
            //GribApiProxy.GribIndexGetLong(index, "step", values, ref sz);
        }
    }
}
