using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using System.IO;
using System.Reflection;
using System.Threading;

namespace Grib.Api.Tests
{
    [SetUpFixture]
    public class Setup
    {
        [SetUp]
        public void OnSetup()
        {
            if (Environment.GetEnvironmentVariable("_GRIB_BREAK") == "1")
            {
                Console.WriteLine("Breaking on start...");
                var mre = new ManualResetEvent(false);

                // after attaching, put a breakpoint here
                while (!mre.WaitOne(250)) ;
            }

            GribEnvironment.NoAbort = true;
        }
    }
}
