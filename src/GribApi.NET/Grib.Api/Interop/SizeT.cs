using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Grib.Api.Interop
{
    /// <summary>
    /// Proxy for size_t semantics. Implicitly convertable to UInt.
    /// </summary>
    public class SizeT
    {
        public UIntPtr Value;

        public SizeT (UIntPtr val)
        {
            Value = val;
        }

        public SizeT (uint val = 0)
        {
            Value = (UIntPtr)val;
        }

        public SizeT (int val)
        {
            Value = (UIntPtr) val;
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
