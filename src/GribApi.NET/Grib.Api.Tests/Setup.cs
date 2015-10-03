﻿using System;
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
                bool breakOnStart = true;
                Console.WriteLine("Breaking on start...");
                var mre = new ManualResetEvent(false);

                // after attaching, put a breakpoint here and set breakOnStart=false to continue
                while (!mre.WaitOne(250) && breakOnStart) ;
            }

            GribEnvironment.NoAbort = true;
        }
    }
}
