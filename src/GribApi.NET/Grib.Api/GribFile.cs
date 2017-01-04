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
using System.IO;
using System.Runtime.InteropServices;
using System.Linq;
using System.Diagnostics;

namespace Grib.Api
{
    /// <summary>
    /// GRIB file iterator object that provides methods for reading and writing messages. When iterated, returns
    /// instances of the <see cref="Grib.Api.GribMessage"/> class.
    /// </summary>
    public class GribFile: AutoRef, IEnumerable<GribMessage>
    {
		static readonly byte[] GRIB_FILE_END_GTS = { 0x0D, 0x0D, 0x0A, 0x03 };
		static readonly byte[] GRIB_FILE_END = { 0x37, 0x37, 0x37, 0x37 };

        private IntPtr _pFileHandleProxy = IntPtr.Zero;
        private FileHandleProxy _fileHandleProxy = null;

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
            FileInfo fi = new FileInfo(fileName);

            // need a better check
            if (!GribFile.FileIsValid(fileName))
            {
                throw new FileLoadException("This file is empty or invalid.");
            }

            _pFileHandleProxy = GribApiNative.CreateFileHandleProxy(fileName);

            if (_pFileHandleProxy == IntPtr.Zero)
            {
				throw new FileLoadException("Could not open file. See inner exception for more detail.", new Win32Exception(Marshal.GetLastWin32Error()));
            }

            _fileHandleProxy = (FileHandleProxy) Marshal.PtrToStructure(_pFileHandleProxy, typeof(FileHandleProxy));

            FileName = fileName;
            Reference = new HandleRef(this, _fileHandleProxy.File);
            Context = GribApiProxy.GribContextGetDefault();

			if (Context == null)
			{
				throw new GribApiException("Failed to get context!");
			}

            // set the message count here; the result seems to be connected to the message iterator so
            // that after you begin iterating messages, the count decreases until it reaches 1.
            int count = 0;
            GribApiProxy.GribCountInFile(Context, this, out count);
            MessageCount = count;
        }

        /// <summary>
        /// Called when [dispose].
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void OnDispose (bool disposing)
        {
            if (_pFileHandleProxy != IntPtr.Zero)
            {
                GribApiNative.DestroyFileHandleProxy(_pFileHandleProxy);
            }
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

            while ((msg = GribMessage.Create(this, i++)) != null)
            {
                yield return msg;
            }

			this.Rewind();
        }

		/// <summary>
		/// Resets the underlying file pointer to the beginning of the file.
		/// </summary>
		public void Rewind ()
		{
			GribApiNative.RewindFileHandleProxy(this._pFileHandleProxy);
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
        /// Performs a basic test to determine if the file is in valid GRIB format.
        /// </summary>
        /// <param name="fileName">Name of the file.</param>
        /// <returns></returns>
		private static bool FileIsValid(string fileName)
		{
			bool isValid = false;

			try
			{
				using (FileStream fs = new FileStream(fileName, FileMode.Open, FileAccess.Read))
				{
					if (fs.Length < 8) { return isValid; }

					Debug.Assert(fs.CanRead && fs.CanSeek);

					long offset = -1;
					fs.Seek(offset, SeekOrigin.End);

					// ignore any empty bytes at the end of the file
					while (fs.Position > 0 && fs.ReadByte() == 0x00) {
						fs.Seek(--offset, SeekOrigin.End);
					}

					byte[] buffer = new byte[4];

					fs.Seek(offset - 3, SeekOrigin.End);
					fs.Read(buffer, 0, 4);

					isValid = buffer.SequenceEqual(GRIB_FILE_END) || buffer.SequenceEqual(GRIB_FILE_END_GTS);
				}
			} catch (Exception)
			{
				isValid = false;
			}

			return isValid;
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
    }
}
