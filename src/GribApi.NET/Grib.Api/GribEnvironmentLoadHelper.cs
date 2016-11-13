using Grib.Api.Interop;
using Grib.Api.Interop.Util;
using System;
using System.IO;
using System.Reflection;

namespace Grib.Api
{
    internal static class GribEnvironmentLoadHelper
    {
        internal static AutoRef BootStrapLibrary ()
        {
            string path = "";

            if (!TryFindBootstrapLibrary(out path))
            {
                throw new FileNotFoundException("Could not find Grib.Api.Native. If you're using ASP.NET or NUnit, this is usually caused by shadow copying. Please see GribApi.NET's documentation for help.");
            }

            return Win32.LoadWin32Library(path);
        }

        internal static bool TryFindBootstrapLibrary (out string path)
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

        internal static bool TryFindDefinitions (out string path)
        {
            return TryBuildDescriptorPath("Grib.Api\\definitions", out path);
        }

        internal static bool TryBuildDescriptorPath (string target, out string path)
        {
            path = "";
			target += "";
            string varDef = Environment.GetEnvironmentVariable("GRIB_API_DIR_ROOT") + "";

            string envDir = Path.Combine(varDef, target);
            string thisDir = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)+"", target);
            string baseDomainDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory+"", target);
			string relDomainDir = Path.Combine(AppDomain.CurrentDomain.RelativeSearchPath+"", target);

			return TryBuildGriApiPath(thisDir, out path) ||
				   TryBuildGriApiPath(relDomainDir, out path) ||      // try using the directory that contains this binary
				   TryBuildGriApiPath(baseDomainDir, out path) ||	  // try using the directory that contains the exe
				   TryBuildGriApiPath(envDir, out path) ||            // try using environment variable
				   TryBuildGriApiPath(target, out path);              // try using relative path;      
        }

        internal static bool TryBuildGriApiPath (string root, out string path)
        {
            path = "";

            if (File.Exists(root) || Directory.Exists(root))
            {
                path = Path.GetFullPath(root);
            }

            return !String.IsNullOrWhiteSpace(path);
        }
    }
}
