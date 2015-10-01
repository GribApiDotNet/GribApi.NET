﻿// Copyright 2015 Eric Millin
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

using Grib.Api.Interop;
using Grib.Api.Interop.SWIG;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api
{

    // see https://software.ecmwf.int/wiki/display/GRIB/Environment+variables
    public static class GribEnvironment
    {
        static GribRef _libHandle;


        [System.Runtime.InteropServices.DllImport("msvcrt.dll", EntryPoint="_putenv", CharSet=CharSet.Ansi)]
        public static extern int putenv (string env);

        //class Posix
        //{
        //    [System.Runtime.InteropServices.DllImport("libc.so")]
        //    public static extern int putenv (string env);
        //}

        [DllImport("kernel32", SetLastError = true, CharSet = CharSet.Ansi)]
        internal static extern IntPtr LoadLibrary ([MarshalAs(UnmanagedType.LPStr)]string lpFileName);

        internal static IntPtr LoadWin32Library (string libPath)
        {
            if (String.IsNullOrEmpty(libPath))
            {
                throw new ArgumentNullException("libPath");
            }

            IntPtr moduleHandle = LoadLibrary(libPath);

            if (moduleHandle == IntPtr.Zero)
            {
                var lasterror = Marshal.GetLastWin32Error();
                var innerEx = new Win32Exception(lasterror);
                innerEx.Data.Add("LastWin32Error", lasterror);

                throw new Exception("Can't load DLL " + libPath, innerEx);
            }

            return moduleHandle;
        }

        private static volatile bool _init = false;

        public static void Init()
        {
            if (_init) { return; }
            _init = true;
            // if GRIB_DEFINITION_PATH is not defined, set it
            if (String.IsNullOrWhiteSpace(DefinitionsPath))
            {
                string basePath = Path.GetDirectoryName(Assembly.GetCallingAssembly().Location);
                DefinitionsPath = Path.Combine(basePath, "Grib.Api/definitions");
            }

            const string PATH_TEMPLATE = ".\\Grib.Api\\lib\\win\\{0}\\Grib.Api.Native.{1}";
            string platform = (Marshal.SizeOf(typeof(IntPtr)) == 8) ? "x64" : "x86";
            string binaryType = "dll";

            string libPath = String.Format(PATH_TEMPLATE, platform, binaryType);

            IntPtr h = LoadWin32Library(libPath);
            _libHandle = new GribRef(h);

            Debug.Assert(Directory.Exists(DefinitionsPath));
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
                putenv("GRIB_DUMP_JPG_FILE");
            }
        }

        // GRIB_API_NO_ABORT
        public static bool NoAbort
        {
            set
            {
                Environment.SetEnvironmentVariable("GRIB_API_NO_ABORT", value ? "1" : "0", EnvironmentVariableTarget.Process);
                putenv("GRIB_API_NO_ABORT");
                Environment.SetEnvironmentVariable("GRIB_API_FAIL_IF_LOG_MESSAGE", value ? "0" : "1", EnvironmentVariableTarget.Process);
                putenv("GRIB_API_FAIL_IF_LOG_MESSAGE");
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
                putenv("GRIB_DEFINITION_PATH");
            }
        }
    }
}
