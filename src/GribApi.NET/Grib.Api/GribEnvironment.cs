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
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Reflection;

namespace Grib.Api
{
    /// <summary>
    /// Interface for configuring GribApi.NET's runtime environment.
    /// </summary>
    /// <remarks>
    /// See also https://software.ecmwf.int/wiki/display/GRIB/Environment+variables.
    /// </remarks>
    public static class GribEnvironment
    {
        private static AutoRef _libHandle;
        private static object _initLock = new object();
        private static bool _init = false;
        private static string _rootPath = "";

        /// <summary>
        /// Initializes GribApi.NET. In very rare cases, you may need to call this method directly
        /// to ensure the native libraries are bootstrapped and the environment setup correctly.
        /// </summary>
        /// <exception cref="System.ComponentModel.Win32Exception"></exception>
        public static void Init()
        {
            if (Initialized) { return; }

            Initialized = true;
            string definitions = "";

            if (String.IsNullOrWhiteSpace(DefinitionsPath) && TryFindDefinitions(out definitions))
            {
                DefinitionsPath = definitions;
            }

            BootStrapLibrary();
            AssertValidEnvironment();
        }

        private static void BootStrapLibrary()
        {
            string path = "";

            if (!TryFindBootstrapLibrary(out path))
            {
                throw new FileNotFoundException("Could not find Grib.Api.Native. If you're using ASP.NET or NUnit, this is usually caused by shadow copying. Please see GribApi.NET's documentation for help.");
            }

            _libHandle = Win32.LoadWin32Library(path);
        }

        private static bool TryFindBootstrapLibrary (out string path)
        {
            path = "";

            // TODO: make cross platform
            string binaryType = "dll";
            string file = "Grib.Api.Native." + binaryType;

            const string PATH_TEMPLATE = "Grib.Api\\lib\\win";
            string platform = (IntPtr.Size == 8) ? "x64" : "x86";
            string gribNativeLibPath = Path.Combine(PATH_TEMPLATE, platform, file);

            return TryBuildDescriptorPath(gribNativeLibPath, out path);
        }

        private static bool TryFindDefinitions (out string path)
        {
            return TryBuildDescriptorPath("Grib.Api\\definitions", out path);
        }

        private static bool TryBuildDescriptorPath (string target, out string path)
        {
            path = "";
            string varDef = Environment.GetEnvironmentVariable("GRIB_API_DIR_ROOT") + "";

            string envDir = Path.Combine(varDef, target);
            string thisDir = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), target);
            string exeDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, target);

            return TryBuildGriApiPath(envDir, out path)  ||   // try using environment variable
                   TryBuildGriApiPath(target, out path)  ||   // try using relative path
                   TryBuildGriApiPath(thisDir, out path) ||   // try using the directory that contains this binary
                   TryBuildGriApiPath(exeDir, out path);      // try using the directory that contains the exe
        }

        private static bool TryBuildGriApiPath(string root, out string path)
        {
            path = "";

            if (File.Exists(root) || Directory.Exists(root))
            {
                path = Path.GetFullPath(root);
            }

            return !String.IsNullOrWhiteSpace(path);
        }

        private static void AssertValidEnvironment ()
        {
            string[] paths = GribEnvironment.DefinitionsPath.Split(new [] { ';' });
            string existingPath = "";
            bool exists = false;

            foreach(string path in paths)
            {
                existingPath = path;
                exists = Directory.Exists(path);

                if (exists) { break; }
            }

            if (!exists)
            {
                throw new GribApiException("GribEnvironment::DefinitionsPath must be a valid path. If you're using ASP.NET or NUnit, this exception is usually caused by shadow copying. Please see GribApi.NET's documentation for help.");
            }

            if (!File.Exists(Path.Combine(existingPath, "boot.def")))
            {
                throw new GribApiException("Could not locate 'definitions/boot.def'.");
            }
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
            get
            {
                lock (_initLock) { return _init; }
            }
            set
            {
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

            Debug.Assert(Environment.GetEnvironmentVariable(name) == val);
        }
    }
}
