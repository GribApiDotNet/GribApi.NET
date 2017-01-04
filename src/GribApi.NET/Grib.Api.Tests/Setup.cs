using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using System.IO;
using System.Reflection;
using System.Threading;
using Grib.Api.Interop;

namespace Grib.Api.Tests
{
    [SetUpFixture]
    public class Setup
    {
        [SetUp]
        public void OnSetup()
		{
			Console.WriteLine("Testing with grib_api v{0}", GribEnvironment.GribApiVersion);
			if (Environment.GetEnvironmentVariable("_GRIB_BREAK") == "1")
            {
                Console.WriteLine("Breaking on start...");
                var mre = new ManualResetEvent(false);

                // after attaching nunit-agent, put a breakpoint here
                while (!mre.WaitOne(250)) ;
            }
        }

		public static void GribContext_OnLog(int lvl, string msg)
		{
			Console.WriteLine(String.Format("Lvl {0}: {1}", lvl, msg));
		}
    }
}
