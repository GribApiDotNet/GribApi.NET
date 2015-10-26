using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace Grib.Api.Interop.Util
{
    internal static class Win32
    {
        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Ansi)]
        private static extern bool SetDllDirectory ([MarshalAs(UnmanagedType.LPStr)]string lpPathName);

        [DllImport("msvcrt.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        internal static extern int _putenv_s (string e, string v);

        [DllImport("kernel32", SetLastError = true, CharSet = CharSet.Ansi)]
        internal static extern IntPtr LoadLibrary ([MarshalAs(UnmanagedType.LPStr)]string lpFileName);

        internal static AutoRef LoadWin32Library (string libPath)
        {
            if (String.IsNullOrEmpty(libPath))
            {
                throw new ArgumentNullException("libPath");
            }

            IntPtr moduleHandle = Win32.LoadLibrary(libPath);

            if (moduleHandle == IntPtr.Zero)
            {
                var lasterror = Marshal.GetLastWin32Error();
                var innerEx = new Win32Exception(lasterror);
                innerEx.Data.Add("Last Win32 Error", lasterror);

                throw new Exception("Can't load DLL " + libPath, innerEx);
            }

            return new AutoRef(moduleHandle);
        }

        internal static void SetDllSearchPath (string pathName)
        {
            if (!Win32.SetDllDirectory(pathName))
            {
                int lastError = Marshal.GetLastWin32Error();
                throw new Win32Exception(lastError, "SetDllDirectory invocation failed for " + pathName);
            }
        }
    }
}
