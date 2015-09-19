using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api.Interop
{
    /// <summary>
    /// Values returned by grib_api to indicate the type associated with a key.
    /// </summary>
    public enum GribValueType
    {
        //        /* Types */
        //  /*  undefined */
        //  #define GRIB_TYPE_UNDEFINED 0
        //  /*  long integer */
        //  #define GRIB_TYPE_LONG 1
        //  /*  double */
        //  #define GRIB_TYPE_DOUBLE 2
        //  /*  char*    */
        //  #define GRIB_TYPE_STRING 3
        //  /*  bytes */
        //  #define GRIB_TYPE_BYTES 4
        //  /*  section */
        //  #define GRIB_TYPE_SECTION 5
        //  /*  label */
        //  #define GRIB_TYPE_LABEL 6
        //  /*  missing */
        //  #define GRIB_TYPE_MISSING 7
        Undefined = 0,
        Int = 1,
        Double = 2,
        String = 3,
        Bytes = 4,
        Section = 5,
        Label = 6,
        Missing = 7
    }
}
