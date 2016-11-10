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
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api.Interop
{
    /// <summary>
    /// Bitwise OR-able bitflags used to filter message keys when iterating.
    /// </summary>
    [Flags]
    public enum KeyFilters : uint
    {
        All = 0,
        SkipReadOnly = 1<<0,
        SkipOptional = 1<<1,
        SkipEditionSpecific = 1<<2,
        SkipCoded = 1<<3,
        SkipComputed = 1<<4,
        SkipDuplicates = 1<<5,
        SkipFunction = 1<<6
    }
}
