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
                bool breakOnStart = true;
                Console.WriteLine("Breaking on start...");
                var mre = new ManualResetEvent(false);
                while (!mre.WaitOne(250) && breakOnStart) ;
            }
           // GribEnvironment.Init();
          //  GribEnvironment.NoAbort = true;
            string dllPath = Path.GetDirectoryName(Assembly.GetAssembly(typeof(GribFile)).Location);
            //string path = Environment.GetEnvironmentVariable("PATH");
            //Environment.SetEnvironmentVariable("PATH", dllPath + "/Grib.Api/" + ";" + path, EnvironmentVariableTarget.Process);
            //GribEnvironment.putenv("PATH");

            GribEnvironment.DefinitionsPath = dllPath + "/Grib.Api/definitions";
            Assert.IsTrue(Directory.Exists(GribEnvironment.DefinitionsPath));
            Assert.IsTrue(Directory.Exists(".\\Grib.Api\\definitions"));
        }
    }
}
