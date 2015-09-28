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
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api
{
    public class GribApiException: Exception
    {
        protected GribApiException (string msg) : base(msg) { }

        /// <summary>
        /// Initializes a new instance of the <see cref="GribApiException"/> class.
        /// </summary>
        /// <param name="msg">The MSG.</param>
        /// <param name="innerException">The inner exception.</param>
        public GribApiException (string msg, Exception innerException = null) : base(msg, innerException)
        {
        }

        /// <summary>
        /// Creates a GribApiException instance using an error code returned by grib_api.
        /// </summary>
        /// <param name="errCode">The error code.</param>
        /// <returns></returns>
        public static GribApiException Create(int errCode)
        {
            string msg = GribApiProxy.GribGetErrorMessage(errCode);
            return new Grib.Api.GribApiException(msg);
        }
    }
}
