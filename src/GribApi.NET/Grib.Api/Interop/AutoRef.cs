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

using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api.Interop
{
    /// <summary>
    /// RAII-patterned wrapper for unmanaged references.
    /// </summary>
    public class AutoRef : IDisposable
    {
        // to detect redundant calls
        private bool _disposed = false;

        /// <summary>
        /// Initializes a new instance of the <see cref="AutoRef"/> class.
        /// </summary>
        public AutoRef () : this(IntPtr.Zero) { }

        /// <summary>
        /// Initializes a new instance of the <see cref="AutoRef"/> class.
        /// </summary>
        /// <param name="handle">The handle.</param>
        public AutoRef (IntPtr handle)
        {
            Reference = new HandleRef(this, handle);
        }

        /// <summary>
        /// Finalizes an instance of the <see cref="AutoRef"/> class.
        /// </summary>
        ~AutoRef ()
        {
            Dispose(false);
        }

        /// <summary>
        /// Releases unmanaged and - optionally - managed resources.
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected void Dispose (bool disposing)
        {
            if (!_disposed)
            {
                _disposed = true;
                OnDispose(disposing);
            }
        }

        /// <summary>
        /// Called when [dispose].
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected virtual void OnDispose (bool disposing)
        {
        }

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose ()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        public HandleRef Reference { get; protected set; }
        public IntPtr pReference { get { return Reference.Handle; } }
    }
}
