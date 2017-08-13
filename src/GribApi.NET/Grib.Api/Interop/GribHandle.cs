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

namespace Grib.Api.Interop
{
    /// <summary>
    /// Wraps grib_handle struct.
    /// </summary>
    public class GribHandle : AutoRef
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="GribHandle"/> class.
        /// </summary>
        /// <param name="h">The h.</param>
        public GribHandle (IntPtr h)
            : base(h)
        {
        }

        /// <summary>
        /// Called when [dispose].
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void OnDispose (bool disposing)
        {
            GribApiProxy.GribHandleDelete(this);
        }
    }
}
