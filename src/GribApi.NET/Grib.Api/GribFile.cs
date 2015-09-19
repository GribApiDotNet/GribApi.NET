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
        internal static extern IntPtr CreateFileHandleProxy ([MarshalAs(UnmanagedType.LPStr)]string filename, int access, int mode);

        [DllImport("Grib.Api.Native.dll")]
        internal static extern void DestroyFileHandleProxy (IntPtr fileHandleProxy);

        private IntPtr _pFileHandleProxy;
        protected FileHandleProxy _fileHandleProxy;

        /// <summary>
        /// Gets or sets the file.
        /// </summary>
        /// <value>
        /// The file.
        /// </value>
        internal SWIGTYPE_p_FILE File { get; set; }

        /// <summary>
        /// Initializes the <see cref="GribFile"/> class.
        /// </summary>
        static GribFile()
        {
            GribEnvironment.Init();
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="GribFile" /> class. File read rights are shared between processes.
        /// </summary>
        /// <param name="fileName">Name of the file.</param>
        /// <param name="mode">The file mode.</param>
        /// <exception cref="System.IO.IOException"></exception>
        public GribFile (string fileName, FileAccess access = FileAccess.Read, FileMode mode = FileMode.Open)
            : base()
        {
            Contract.Requires(Directory.Exists(GribEnvironment.DefinitionsPath), "GribEnvironment::DefinitionsPath must be a valid path.");
            Contract.Requires(System.IO.File.Exists(Path.Combine(GribEnvironment.DefinitionsPath, "boot.def")), "Could not locate 'definitions/boot.def'.");

            FileName = fileName;
            _pFileHandleProxy = CreateFileHandleProxy(FileName, (int)access, (int)mode);

            if (_pFileHandleProxy == IntPtr.Zero)
            {
                // need to get error msg
                throw new IOException(Marshal.GetLastWin32Error().ToString());
            }

            _fileHandleProxy = (FileHandleProxy) Marshal.PtrToStructure(_pFileHandleProxy, typeof(FileHandleProxy));
            File = new SWIGTYPE_p_FILE(_fileHandleProxy.File, false);

            Context = GribApiProxy.GribContextGetDefault();

            int count = 0;
            GribApiProxy.GribCountInFile(Context, File, out count);
            MessageCount = count;
        }

        /// <summary>
        /// Called when [dispose].
        /// </summary>
        protected override void OnDispose ()
        {
            DestroyFileHandleProxy(_pFileHandleProxy);
        }

        /// <summary>
        /// Tries the get message.
        /// </summary>
        /// <param name="msg">The MSG.</param>
        /// <returns></returns>
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

        /// <summary>
        /// Returns an enumerator that iterates through the collection.
        /// </summary>
        /// <returns>
        /// A <see cref="T:System.Collections.Generic.IEnumerator`1" /> that can be used to iterate through the collection.
        /// </returns>
        public IEnumerator<GribMessage> GetEnumerator ()
        {
            GribMessage msg;

            while (TryGetMessage(out msg))
            {
                yield return msg;
            }
        }

        /// <summary>
        /// NOT IMPLEMENTED.
        /// </summary>
        /// <returns>
        /// An <see cref="T:System.Collections.IEnumerator" /> object that can be used to iterate through the collection.
        /// </returns>
        /// <exception cref="System.NotImplementedException"></exception>
        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator ()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Gets the name of the file.
        /// </summary>
        /// <value>
        /// The name of the file.
        /// </value>
        public string FileName { get; private set; }

        /// <summary>
        /// Gets or sets the context.
        /// </summary>
        /// <value>
        /// The context.
        /// </value>
        internal SWIGTYPE_p_grib_context Context { get; set; }

        /// <summary>
        /// Gets or sets the message count.
        /// </summary>
        /// <value>
        /// The message count.
        /// </value>
        public int MessageCount { get; protected set; }
    }
}
