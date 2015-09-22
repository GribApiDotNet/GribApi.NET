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
