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

namespace Grib.Api.Interop
{
    /// <summary>
    /// SizeT is a variable-size, platform-dependent unsigned integer. 
    /// It can store the maximum size of a theoretically possible object
    /// of any type (including array). Implicitly convertable to UInt.
    /// <para>&#160;</para>
    /// Example:
    /// <code>
    /// <para>&#160;&#160;SizeT size = 1;</para>
    /// <para>&#160;&#160;int[] myArray = new int[size];</para>
    /// <para>&#160;&#160;size = (SizeT) getSomeInt();</para>
    /// <para>&#160;&#160;Int64 big = (Int64) size;</para>
    /// </code>
    /// </summary>
    public struct SizeT
    {
        /// <summary>
        /// The value.
        /// </summary>
        public UIntPtr Value;

        /// <summary>
        /// Initializes a new instance of the <see cref="SizeT"/> struct.
        /// </summary>
        /// <param name="val">The value.</param>
        private SizeT (UIntPtr val) : this()
        {
            Value = val;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="SizeT"/> struct.
        /// </summary>
        /// <param name="val">The value.</param>
        private SizeT (uint val = 0)
            : this((UIntPtr)val)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="SizeT"/> struct.
        /// </summary>
        /// <param name="val">The value.</param>
        private SizeT (int val)
            : this((UIntPtr)val)
        {
        }

        /// <summary>
        /// Gets the size of the value's container. 4 on x86, 8 on x64.
        /// </summary>
        /// <value>
        /// The size.
        /// </value>
        public static int Size
        {
            get
            {
                return Marshal.SizeOf(UIntPtr.Zero);
            }
        }

        /// <summary>
        /// Performs an implicit conversion from <see cref="UIntPtr"/> to <see cref="SizeT"/>.
        /// </summary>
        /// <param name="s">The s.</param>
        /// <returns>
        /// The result of the conversion.
        /// </returns>
        public static implicit operator SizeT (UIntPtr s)
        {
            return new SizeT(s);
        }

        /// <summary>
        /// Performs an implicit conversion from <see cref="UInt32"/> to <see cref="SizeT"/>.
        /// </summary>
        /// <param name="s">The s.</param>
        /// <returns>
        /// The result of the conversion.
        /// </returns>
        public static implicit operator SizeT (UInt32 s)
        {
            return new SizeT((UIntPtr)s);
        }

        /// <summary>
        /// Performs an explicit conversion from <see cref="UInt64"/> to <see cref="SizeT"/>.
        /// </summary>
        /// <param name="s">The s.</param>
        /// <returns>
        /// The result of the conversion.
        /// </returns>
        public static explicit operator SizeT (UInt64 s)
        {
            return new SizeT((UIntPtr)s);
        }

        /// <summary>
        /// Performs an explicit conversion from <see cref="Int32"/> to <see cref="SizeT"/>.
        /// </summary>
        /// <param name="s">The s.</param>
        /// <returns>
        /// The result of the conversion.
        /// </returns>
        public static explicit operator SizeT (Int32 s)
        {
            return new SizeT((UIntPtr) s);
        }

        /// <summary>
        /// Performs an explicit conversion from <see cref="Int64"/> to <see cref="SizeT"/>.
        /// </summary>
        /// <param name="s">The s.</param>
        /// <returns>
        /// The result of the conversion.
        /// </returns>
        public static explicit operator SizeT (Int64 s)
        {
            return new SizeT((UIntPtr) s);
        }

        /// <summary>
        /// Performs an implicit conversion from <see cref="SizeT"/> to <see cref="UIntPtr"/>.
        /// </summary>
        /// <param name="s">The s.</param>
        /// <returns>
        /// The result of the conversion.
        /// </returns>
        public static implicit operator UIntPtr (SizeT s)
        {
            return s.Value;
        }

        /// <summary>
        /// Performs an implicit conversion from <see cref="SizeT"/> to <see cref="UInt32"/>.
        /// </summary>
        /// <param name="s">The s.</param>
        /// <returns>
        /// The result of the conversion.
        /// </returns>
        public static implicit operator UInt32 (SizeT s)
        {
            return s.Value.ToUInt32();
        }

        /// <summary>
        /// Performs an implicit conversion from <see cref="SizeT"/> to <see cref="UInt64"/>.
        /// </summary>
        /// <param name="s">The s.</param>
        /// <returns>
        /// The result of the conversion.
        /// </returns>
        public static implicit operator UInt64 (SizeT s)
        {
            return s.Value.ToUInt64();
        }

        /// <summary>
        /// Performs an explicit conversion from <see cref="SizeT"/> to <see cref="Int32"/>.
        /// </summary>
        /// <param name="s">The s.</param>
        /// <returns>
        /// The result of the conversion.
        /// </returns>
        public static explicit operator Int32 (SizeT s)
        {
            return (Int32) s.Value.ToUInt32();
        }

        /// <summary>
        /// Performs an explicit conversion from <see cref="SizeT"/> to <see cref="Int64"/>.
        /// </summary>
        /// <param name="s">The s.</param>
        /// <returns>
        /// The result of the conversion.
        /// </returns>
        public static explicit operator Int64 (SizeT s)
        {
            return (Int64) s.Value.ToUInt64();
        }

        /// <summary>
        /// Returns a hash code for this instance.
        /// </summary>
        /// <returns>
        /// A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table. 
        /// </returns>
        public override int GetHashCode()
        {
            return this.Value.GetHashCode();
        }

        /// <summary>
        /// Implements the operator ==.
        /// </summary>
        /// <param name="a">a.</param>
        /// <param name="b">The b.</param>
        /// <returns>
        /// The result of the operator.
        /// </returns>
        public static bool operator ==(SizeT a, SizeT b)
        {
            return a.Value == b.Value;
        }

        /// <summary>
        /// Implements the operator !=.
        /// </summary>
        /// <param name="a">a.</param>
        /// <param name="b">The b.</param>
        /// <returns>
        /// The result of the operator.
        /// </returns>
        public static bool operator !=(SizeT a, SizeT b)
        {
            return a.Value != b.Value;
        }

        /// <summary>
        /// Determines whether the specified <see cref="System.Object" />, is equal to this instance.
        /// </summary>
        /// <param name="obj">The <see cref="System.Object" /> to compare with this instance.</param>
        /// <returns>
        ///   <c>true</c> if the specified <see cref="System.Object" /> is equal to this instance; otherwise, <c>false</c>.
        /// </returns>
        public override bool Equals(object obj)
        {
            bool isEqual = false;

            if (obj != null && typeof(SizeT).IsAssignableFrom(obj.GetType()))
            {
                isEqual = this == (SizeT) obj;
            }

            return isEqual;
        }
    }
}
