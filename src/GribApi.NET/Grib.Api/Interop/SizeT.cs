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

namespace Grib.Api.Interop
{
    /// <summary>
    /// Provides C-like size_t semantics. Implicitly convertable to UInt.
    /// </summary>
    public struct SizeT
    {
        public UIntPtr Value;

        public SizeT (UIntPtr val) : this()
        {
            Value = val;
        }

        public SizeT (uint val = 0)
            : this((UIntPtr)val)
        {
        }

        public SizeT (int val)
            : this((UIntPtr)val)
        {
        }

        public static implicit operator SizeT (UIntPtr s)
        {
            return new SizeT(s);
        }

        public static implicit operator SizeT (UInt32 s)
        {
            return new SizeT((UIntPtr)s);
        }

        public static explicit operator SizeT (UInt64 s)
        {
            return new SizeT((UIntPtr)s);
        }

        public static implicit operator UIntPtr (SizeT s)
        {
            return s.Value;
        }

        public static implicit operator UInt32 (SizeT s)
        {
            return s.Value.ToUInt32();
        }

        public static implicit operator UInt64 (SizeT s)
        {
            return s.Value.ToUInt64();
        }

        public static explicit operator Int32 (SizeT s)
        {
            return (Int32) s.Value.ToUInt32();
        }

        public static explicit operator Int64 (SizeT s)
        {
            return (Int64) s.Value.ToUInt64();
        }

    }
}
