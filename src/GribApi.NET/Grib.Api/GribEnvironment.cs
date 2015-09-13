using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api
{

    // see https://software.ecmwf.int/wiki/display/GRIB/Environment+variables
    public static class GribEnvironment
    {

        public static void Init()
        {
            // if GRIB_DEFINITION_PATH is not defined, set it to the same directory as the dll
            if (String.IsNullOrWhiteSpace(DefinitionsPath))
            {
                string basePath = Path.GetDirectoryName(Assembly.GetCallingAssembly().Location);
                DefinitionsPath = Path.Combine(basePath, "definitions");
            }
        }

        // GRIB_API_NO_ABORT
        public static bool NoAbort
        {
            set
            {
                Environment.SetEnvironmentVariable("GRIB_API_NO_ABORT", value ? "1" : "0", EnvironmentVariableTarget.Process);
            }
        }

        // GRIB_DEFINITION_PATH
        public static string DefinitionsPath
        {
            get
            {
                return Environment.GetEnvironmentVariable("GRIB_DEFINITION_PATH");
            }

            set
            {
                string val = value;
                if (!String.IsNullOrWhiteSpace(value))
                {
                    // grib_api_lib assumes POSIX-style paths
                    val = value.Replace("\\", "/");
                }
                
                Environment.SetEnvironmentVariable("GRIB_DEFINITION_PATH", val, EnvironmentVariableTarget.Process);
            }
        }
    }
}
