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
    /// Wraps grib_context struct.
    /// </summary>
    public class GribContext : AutoRef
    {
		public static GribContext Default
        {
            get
            {
                if (_default == null)
                {
                    GribEnvironment.Init();
                    _default = GribApiProxy.GribContextGetDefault();
                }
                return _default;
            }

        }
        private static GribContext _default = null;

        /// <summary>
        /// Initializes a new instance of the <see cref="GribContext"/> class.
        /// </summary>
        /// <param name="h">The h.</param>
        public GribContext (IntPtr h)
            : base(h)
        {
        }

        /// <summary>
        /// Called when [dispose].
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void OnDispose (bool disposing)
        {
            // This causes AccessViolation when disposing
            // GribApiProxy.GribContextDelete(this);
        }

        /// <summary>
        /// Gets or sets a value indicating whether to [enable multiple field messages]. grib_api documentation discourages use of this feature.
        /// </summary>
        /// <value>
        /// <c>true</c> if [enable multiple field messages]; otherwise, <c>false</c>.
        /// </value>
        public bool EnableMultipleFieldMessages
        {
            get { return _enableMultipleFieldMessages; }
            set
            {
                if (value)
                {
                    GribApiProxy.GribMultiSupportOn(this);
                } else
                {
                    GribApiProxy.GribMultiSupportOff(this);
                }

                _enableMultipleFieldMessages = value;
            }
        }
        private bool _enableMultipleFieldMessages = false;
    }
}
