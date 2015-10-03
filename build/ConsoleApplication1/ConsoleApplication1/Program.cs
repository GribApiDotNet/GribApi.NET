using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Grib.Api;

namespace ConsoleApplication1 {
    class Program {
        static void Main(string[] args) {
            Console.WriteLine();
           // GribEnvironment.DefinitionsPath = Path.Combine(Environment.CurrentDirectory, "Grib.Api", "definitions");
            Console.WriteLine(GribEnvironment.DefinitionsPath);
            using (var file = new GribFile(@"C:\Users\ericmillin\Projects\GribApi.NET\src\GribApi.NET\Grib.Api.Tests\TestData\ds.waveh.bin")) 
            {
                try
                {
                    foreach (var msg in file) 
                    {
                        foreach (var val in msg) 
                        {
                            // TODO: some sort of actual test here
                            Console.WriteLine("{0} = {1}", val.Key, val.AsString());
                        }
                    }
                } catch (Exception e)
                {
                    Console.WriteLine(e.ToString());
                }
            }
            ManualResetEvent mre = new ManualResetEvent(false);
            while (mre.WaitOne()) ;
        }
    }
}
