using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace Grib.Api.Interop.Util
{
    internal static class GribApiNative
    {
        [DllImport("Grib.Api.Native.dll", CharSet = CharSet.Ansi)]
        internal static extern void GetGribKeysIteratorName (StringBuilder name, IntPtr iter);

        [DllImport("Grib.Api.Native.dll")]
        internal static extern IntPtr CreateFileHandleProxy ([MarshalAs(UnmanagedType.LPStr)]string filename);

        [DllImport("Grib.Api.Native.dll")]
        internal static extern void DestroyFileHandleProxy (IntPtr fileHandleProxy);

        [DllImport("Grib.Api.Native.dll")]
        internal static extern bool GribKeyIsReadOnly(HandleRef gribHandle, [MarshalAs(UnmanagedType.LPStr)]string keyName);

        [DllImport("Grib.Api.Native.dll", EntryPoint="DeleteGribBox")]
        private static extern int _DeleteGribBox(HandleRef box);

        internal static void DeleteGribBox(HandleRef box) 
        {
            int ret = _DeleteGribBox(box);

            if (ret != 0) 
            {
                throw Grib.Api.GribApiException.Create(ret);
            }
        }
    }
}
