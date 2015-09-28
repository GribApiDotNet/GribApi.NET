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
    public abstract class AutoRef : IDisposable
    {
        // to detect redundant calls
        private bool _disposed = false; 

        public AutoRef ()
        {
        }

        ~AutoRef ()
        {
            Dispose(false);
        }

        protected void Dispose (bool disposing)
        {
            if (!_disposed)
            {
                if (disposing)
                {
                    OnDispose();
                }

                // shared cleanup logic
                _disposed = true;
            }
        }

        protected virtual void OnDispose ()
        {
        }

        public void Dispose ()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
    }
}
