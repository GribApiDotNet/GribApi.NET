// Copyright 2015 Eric Millin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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

        // GRIB_API_LOG_STREAM=stderr

        // GRIB_DUMP_JPG_FILE
        public static string JpegDumpPath
        {
            get
            {
                return Environment.GetEnvironmentVariable("GRIB_DUMP_JPG_FILE");
            }
            set
            {
                string val = value;
                if (!String.IsNullOrWhiteSpace(value))
                {
                    // grib_api_lib assumes POSIX-style paths
                    val = value.Replace("\\", "/");
                }
                Environment.SetEnvironmentVariable("GRIB_DUMP_JPG_FILE", val,
                    EnvironmentVariableTarget.Process);
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
