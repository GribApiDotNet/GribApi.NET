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
            if (String.IsNullOrWhiteSpace(DefinitionsPath))
            {
                // grib_api_lib assumes POSIX-style paths
                string basePath = Path.GetDirectoryName(Assembly.GetCallingAssembly().Location);
                DefinitionsPath = Path.Combine(basePath, "definitions").Replace("\\", "/");
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
                Environment.SetEnvironmentVariable("GRIB_DEFINITION_PATH", value, EnvironmentVariableTarget.Process);
            }
        }
    }
}
