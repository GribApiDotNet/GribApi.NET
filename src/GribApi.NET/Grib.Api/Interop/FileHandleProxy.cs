using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
namespace Grib.Api.Interop
{
    [StructLayout(LayoutKind.Sequential)]
    public class FileHandleProxy
    {
        public IntPtr Win32Handle;

        /// <summary>
        /// FILE*
        /// </summary>
        public IntPtr File;
    }
}
