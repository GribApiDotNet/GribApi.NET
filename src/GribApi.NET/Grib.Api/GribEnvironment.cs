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

using Grib.Api.Interop;
using Grib.Api.Interop.SWIG;
using Grib.Api.Interop.Util;
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
    /// <summary>
    /// Interface for configuring GribApi.NET's runtime environment.
    /// </summary>
    public static class GribEnvironment
    {
        private static GribRef _libHandle;
        private static object _initLock = new object();
        private static bool _init = false;

        /// <summary>
        /// Initializes GribApi.NET. In very rare cases, you may need to call this method directly
        /// to ensure the native libraries are bootstrapped and the environment setup correctly.
        /// </summary>
        /// <exception cref="System.ComponentModel.Win32Exception"></exception>
        public static void Init()
        {
            if (Initialized) { return; }

            Initialized = true;

            string pathTemplate = ".\\Grib.Api\\lib\\win\\{0}\\Grib.Api.Native.{1}";
            string platform = (IntPtr.Size == 8) ? "x64" : "x86";
            string binaryType = "dll";

            string libPath = String.Format(pathTemplate, platform, binaryType);
            libPath = Path.GetFullPath(libPath);

            Win32.SetDllSearchPath(Path.GetDirectoryName(libPath));

            if (String.IsNullOrWhiteSpace(DefinitionsPath))
            {
                string basePath = Path.GetDirectoryName(AppDomain.CurrentDomain.BaseDirectory);
                DefinitionsPath = Path.Combine(basePath, "Grib.Api", "definitions");
                Debug.Assert(Directory.Exists(DefinitionsPath));
            }

            IntPtr h = Win32.LoadWin32Library(libPath);
            Debug.Assert(h != IntPtr.Zero);

            _libHandle = new GribRef(h);
        }

        /// <summary>
        /// Gets or sets the JPEG dump path. This is primarily useful during debugging
        /// </summary>
        /// <value>
        /// The JPEG dump path.
        /// </value>
        public static string JpegDumpPath
        {
            get
            {
                return Environment.GetEnvironmentVariable("GRIB_DUMP_JPG_FILE");
            }
            set
            {
                PutEnvVar("GRIB_DUMP_JPG_FILE", value);
            }
        }

        /// <summary>
        /// Gets or sets a value indicating whether or not grib_api should abort on an assertion failure or error log.
        /// </summary>
        /// <value>
        ///   <c>true</c> if [no abort]; otherwise, <c>false</c>.
        /// </value>
        public static bool NoAbort
        {
            get
            {
                return Environment.GetEnvironmentVariable("GRIB_API_NO_ABORT") == "1";
            }
            set
            {
                string val = value ? "1" : "0";
                PutEnvVar("GRIB_API_NO_ABORT", val);

                val = value ? "0" : "1";
                PutEnvVar("GRIB_API_FAIL_IF_LOG_MESSAGE", val);
            }
        }

        /// <summary>
        /// Gets or sets the location of grib_api's definitions directory. By default, it is located at Grib.Api/definitions.
        /// </summary>
        /// <value>
        /// The definitions path.
        /// </value>
        public static string DefinitionsPath
        {
            get
            {
                return Environment.GetEnvironmentVariable("GRIB_DEFINITION_PATH");
            }
            set
            {
                PutEnvVar("GRIB_DEFINITION_PATH", value);
            }
        }

        /// <summary>
        /// Gets the grib_api version wrapped by this library.
        /// </summary>
        /// <value>
        /// The grib API version.
        /// </value>
        public static string GribApiVersion
        {
            get
            {
                string version = GribApiProxy.GribGetApiVersion().ToString();
                string major = version[0].ToString();
                string minor = Int32.Parse(version.Substring(1, 2)).ToString();
                string patch = Int32.Parse(version.Substring(3, 2)).ToString();

                return String.Join(".", major, minor, patch);
            }
        }

        private static bool Initialized
        {
            get {
                lock (_initLock) { return _init; }
            }
            set {
                lock (_initLock) { _init = value; }
            }
        }

        /// <summary>
        /// Sets an env variable and notifies the C runtime to update its values.
        /// </summary>
        /// <param name="name">The name.</param>
        /// <param name="val">The value.</param>
        private static void PutEnvVar(string name, string val)
        {
            Environment.SetEnvironmentVariable(name, val, EnvironmentVariableTarget.Process);
            Win32._putenv_s(name, val);
        }
    }
}
