using Grib.Api.Interop.SWIG;
using Grib.Api.Interop;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics.Contracts;
using System.IO;

namespace Grib.Api
{
    public class GribFile: AutoCleanup, IEnumerable<GribMessage>
    {

        [DllImport("Grib.Api.Native.dll")]
        internal static extern IntPtr CreateFileHandleProxy ([MarshalAs(UnmanagedType.LPStr)]string filename);

        [DllImport("Grib.Api.Native.dll")]
        internal static extern void DestroyFileHandleProxy (IntPtr fileHandleProxy);

        private IntPtr _pFileHandleProxy;
        protected string _fileName;
        protected FileHandleProxy _fileHandleProxy;
        public SWIGTYPE_p_FILE File { get; protected set; }

        static GribFile()
        {
            GribEnvironment.Init();
        }

        public GribFile(string fileName): base()
        {
            Contract.Requires(Directory.Exists(GribEnvironment.DefinitionsPath), "GribEnvironment::DefinitionsPath must be a valid path.");
            Contract.Requires(System.IO.File.Exists(Path.Combine(GribEnvironment.DefinitionsPath, "boot.def")), "Could not locate 'definitions/boot.def'.");

            _fileName = fileName;
            _pFileHandleProxy = CreateFileHandleProxy(_fileName);
            _fileHandleProxy = (FileHandleProxy) Marshal.PtrToStructure(_pFileHandleProxy, typeof(FileHandleProxy));
            File = new SWIGTYPE_p_FILE(_fileHandleProxy.File, false);

            Context = GribApiProxy.GribContextGetDefault();

            int count = 0;
            GribApiProxy.GribCountInFile(Context, File, out count);
            MessageCount = count;
        }

        protected override void OnDispose ()
        {
            DestroyFileHandleProxy(_pFileHandleProxy);
        }

        protected bool TryGetMessage(out GribMessage msg)
        {
            msg = null;
            int err = 0;
            var handle = GribApiProxy.GribHandleNewFromFile(Context, this.File, out err);

            if((err == 0) && (SWIGTYPE_p_grib_handle.getCPtr(handle).Handle != IntPtr.Zero))
            {
                msg = new GribMessage(handle, File, Context);
            }

            return msg != null;
        }

        public IEnumerator<GribMessage> GetEnumerator ()
        {
            GribMessage msg;

            while (TryGetMessage(out msg))
            {
                yield return msg;
            }
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator ()
        {
            throw new NotImplementedException();
        }

        public string FileName { get { return _fileName; } }

        public SWIGTYPE_p_grib_context Context { get; set; }

        public int MessageCount { get; protected set; }
    }
}
