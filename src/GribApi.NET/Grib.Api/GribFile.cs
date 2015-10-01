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
using System.Diagnostics;
using System.ComponentModel;

namespace Grib.Api
{
    /// <summary>
    /// Encapsulates logic for reading and writing GRIB messages in files.
    /// </summary>
    public class GribFile: GribRef, IEnumerable<GribMessage>
    {

        [DllImport("Grib.Api.Native.dll")]
        internal static extern IntPtr CreateFileHandleProxy ([MarshalAs(UnmanagedType.LPStr)]string filename);

        [DllImport("Grib.Api.Native.dll")]
        internal static extern void DestroyFileHandleProxy (IntPtr fileHandleProxy);

        private IntPtr _pFileHandleProxy;
        private FileHandleProxy _fileHandleProxy;

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
        /// <exception cref="System.IO.IOException">Could not open file. See inner exception for more detail.</exception>
        /// <exception cref="System.IO.FileLoadException">The file is empty.</exception>
        public GribFile (string fileName)
        {
            Contract.Requires(Directory.Exists(GribEnvironment.DefinitionsPath), "GribEnvironment::DefinitionsPath must be a valid path.");
            Contract.Requires(System.IO.File.Exists(Path.Combine(GribEnvironment.DefinitionsPath, "boot.def")), "Could not locate 'definitions/boot.def'.");

            fileName = fileName.Replace("\\", "/");

            FileInfo fi = new FileInfo(fileName);

            // need a better check
            if (fi.Length < 4)
            {
                throw new FileLoadException("This file is empty.");
            }

            _pFileHandleProxy = CreateFileHandleProxy(fileName);

            if (_pFileHandleProxy == IntPtr.Zero)
            {
                throw new IOException("Could not open file. See inner exception for more detail.", new Win32Exception(Marshal.GetLastWin32Error()));
            }

            _fileHandleProxy = (FileHandleProxy) Marshal.PtrToStructure(_pFileHandleProxy, typeof(FileHandleProxy));

            FileName = fileName;
            Reference = new HandleRef(this, _fileHandleProxy.File);
            Context = GribApiProxy.GribContextGetDefault();

            int count = 0;
            GribApiProxy.GribCountInFile(Context, this, out count);
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
        protected bool TryGetMessage(out GribMessage msg, int index)
        {
            msg = null;
            int err = 0;

            GribHandle handle = GribApiProxy.GribHandleNewFromFile(Context, this, out err);

            if (err != 0)
            {
                throw GribApiException.Create(err);
            }

            if(handle != null)
            {
                msg = new GribMessage(handle, Context, index);
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
            int i = 0;

            while (TryGetMessage(out msg, i++))
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
        /// Writes a message to the specified path.
        /// </summary>
        /// <param name="path">The path.</param>
        /// <param name="message">The message.</param>
        /// <param name="mode">The mode.</param>
        public static void Write (string path, GribMessage message, FileMode mode = FileMode.Create)
        {
            Write(path, new [] { message }, mode);
        }

        /// <summary>
        /// Writes all messages in the file to the specified path.
        /// </summary>
        /// <param name="path">The path.</param>
        /// <param name="file">The file.</param>
        /// <param name="mode">The mode.</param>
        public static void Write (string path, GribFile file, FileMode mode = FileMode.Create)
        {
            Write(path, file as IEnumerable<GribMessage>, mode);
        }

        /// <summary>
        /// Writes messages the specified path.
        /// </summary>
        /// <param name="path">The path.</param>
        /// <param name="messages">The messages.</param>
        /// <param name="mode">The mode.</param>
        public static void Write (string path, IEnumerable<GribMessage> messages, FileMode mode = FileMode.Create)
        {
            // TODO: Getting the buffer and writing to file in C++ precludes the need for byte[] copy
            using (FileStream fs = new FileStream(path, mode, FileAccess.Write, FileShare.Read, 8192))
            {
                foreach (var message in messages)
                {
                    fs.Write(message.Buffer, 0, message.Buffer.Length);
                }
            }
        }

        /// <summary>
        /// Gets the name of the file.
        /// </summary>
        /// <value>
        /// The name of the file.
        /// </value>
        public string FileName { get; private set; }

        /// <summary>
        /// Gets or sets the message count.
        /// </summary>
        /// <value>
        /// The message count.
        /// </value>
        public int MessageCount { get; protected set; }

        /// <summary>
        /// Gets or sets the context.
        /// </summary>
        /// <value>
        /// The context.
        /// </value>
        public GribContext Context { get; protected set; }

        /// <summary>
        /// Gets or sets the file.
        /// </summary>
        /// <value>
        /// The file.
        /// </value>
        //internal GribRef File { get; set; }
    }
}
