// Copyright 2017 Eric Millin
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
using System;
using System.Text;

namespace Grib.Api.Interop
{

    /// <summary>
    /// Wraps a grib_keys_iterator struct.
    /// </summary>
    public class GribKeysIterator : AutoRef
    {
        internal GribKeysIterator (IntPtr h)
            : base(h)
        {
        }

        /// <summary>
        /// Gets the next value in a series.
        /// </summary>
        /// <returns>False if there are no more values.</returns>
        public bool Next ()
        {
            return GribApiProxy.GribKeysIteratorNext(this) != 0;
        }

		/// <summary>
		/// Rewinds this instance.
		/// </summary>
		public void Rewind ()
		{
			GribApiProxy.GribKeysIteratorRewind(this);
		}

        /// <summary>
        /// Called when [dispose].
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void OnDispose (bool disposing)
        {
			if (this.pReference != IntPtr.Zero) 
			{
				this.Rewind();
				GribApiProxy.GribKeysIteratorDelete(this);
			}
        }

        public string Name
        {
            get
            {
                StringBuilder sb = new StringBuilder(255);
                Interop.Util.GribApiNative.GetGribKeysIteratorName(sb, this.Reference.Handle);

                return sb.ToString();
            }
        }

        /// <summary>
        /// Creates an instance of GribKeysIterator.
        /// </summary>
        /// <param name="handle">The handle of the message to iterate.</param>
        /// <param name="filters">The key filters.</param>
        /// <param name="nspace">The namespace of the keys to iterate.</param>
        /// <returns></returns>
        public static GribKeysIterator Create (GribHandle handle, uint filters, string nspace)
        {
            return GribApiProxy.GribKeysIteratorNew(handle, filters, nspace);
        }
    }
}
