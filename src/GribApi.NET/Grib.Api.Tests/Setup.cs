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
                while (!mre.WaitOne(250)) ;
            }

            string dllPath = Path.GetDirectoryName(Assembly.GetAssembly(typeof(GribFile)).Location);
            string path = Environment.GetEnvironmentVariable("PATH");
            Environment.SetEnvironmentVariable("PATH", dllPath + ";" + path, EnvironmentVariableTarget.Process);
           // GribEnvironment.DefinitionsPath = dllPath;
            Assert.IsTrue(File.Exists("Grib.Api.Native.dll"));
            Assert.IsTrue(Directory.Exists("TestData"));
            Assert.IsTrue(Directory.Exists("definitions"));
        }
    }
}
