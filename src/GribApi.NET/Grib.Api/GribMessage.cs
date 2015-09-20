using Grib.Api.Interop.SWIG;
using Grib.Api.Interop;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Runtime.InteropServices;
using System.Diagnostics;

namespace Grib.Api
{
    public class GribMessage: AutoCleanup, IEnumerable<GribValue>
    {
        private SWIGTYPE_p_FILE _file;

        /// <summary>
        /// The key namespaces. Set the <see cref="Namespace"/> property with these values to
        /// filter the keys return when iterating this message. Default value is [all].
        /// </summary>
        public static readonly string[] Namespaces = { "all", "ls", "parameter", "statistics", "time", "geography", "vertical", "mars" };

        /// <summary>
        /// Initializes a new instance of the <see cref="GribMessage"/> class.
        /// </summary>
        internal GribMessage () { }

        /// <summary>
        /// Initializes a new instance of the <see cref="GribMessage"/> class.
        /// </summary>
        /// <param name="handle">The handle.</param>
        /// <param name="file">The file.</param>
        /// <param name="context">The context.</param>
        internal GribMessage(SWIGTYPE_p_grib_handle handle, SWIGTYPE_p_FILE file, SWIGTYPE_p_grib_context context = null):base()
        {
            _file = file;
            Handle = handle;
            Context = context ?? GribApiProxy.GribContextGetDefault();
            Namespace = Namespaces[0];
            KeyFilters |= (uint) GribApiProxy.GRIB_KEYS_ITERATOR_ALL_KEYS;
            MissingValue = this["missingValue"].AsDouble();
        }

        /// <summary>
        /// Called when [dispose].
        /// </summary>
        protected override void OnDispose ()
        {
            GribApiProxy.GribHandleDelete(Handle);
        }

        /// <summary>
        /// Gets or sets the grib_handle.
        /// </summary>
        /// <value>
        /// The handle.
        /// </value>
        internal SWIGTYPE_p_grib_handle Handle { get; set; }

        /// <summary>
        /// Gets or sets the grib_context.
        /// </summary>
        /// <value>
        /// The context.
        /// </value>
        internal SWIGTYPE_p_grib_context Context { get; set; }

        /// <summary>
        /// Gets the value used to represent a missing value. This value is provided by grib_api,
        /// not the file itself.
        /// </summary>
        /// <value>
        /// The missing value.
        /// </value>
        public double MissingValue { get; private set; }

        /// <summary>
        /// Set this property with a value in <see cref="Namespaces"/> to
        /// filter the keys return when iterating this message.
        /// </summary>
        /// <value>
        /// The namespace.
        /// </value>
        public string Namespace { get; set; }

        public uint KeyFilters { get; set; }

        /// <summary>
        /// Gets the type of the grid.
        /// </summary>
        /// <value>
        /// The type of the grid.
        /// </value>
        public string GridType { get { return this["gridType"].AsString(); } }

        /// <summary>
        /// Gets or sets the decimal precision. Setting this value currently
        /// updates all packed values to the new precision.
        /// </summary>
        /// <value>
        /// The decimal precision.
        /// </value>
        public int DecimalPrecision
        {
            get
            {
                return this["decimalPrecision"].AsInt();
            }
            set
            {
                // 'changeDecimalPrecision' updates all packed values to the new precision;
                // 'decimalPrecision' does not -- should offer way to toggle
                this["changeDecimalPrecision"].AsInt(value);
            }
        }

        /// <summary>
        /// Gets the messages values with coordinates.
        /// </summary>
        /// <value>
        /// The geo spatial values.
        /// </value>
        public IEnumerable<GeoSpatialValue> GeoSpatialValues 
        { 
            get
            {
                int err = 0;
                double lat, lon, val;

                var iter = GribApiProxy.GribIteratorNew(Handle, 0, out err);

                while (GribApiProxy.GribIteratorNext(iter, out lat, out lon, out val) != 0)
                {
                    yield return new GeoSpatialValue(lat, lon, val, val == this.MissingValue);
                }

                GribApiProxy.GribIteratorDelete(iter);
            }
        }

        /// <summary>
        /// Gets or sets the mesage values.
        /// </summary>
        /// <value>
        /// The values.
        /// </value>
        public double[] Values
        {
            get
            {
                return this["values"].AsDoubleArray();
            }
            set
            {
                this["values"].AsDoubleArray(value);
            }
        }

        /// <summary>
        /// Gets the message size.
        /// </summary>
        /// <value>
        /// The size.
        /// </value>
        public uint Size
        {
            get
            {
                uint sz = 0;
                GribApiProxy.GribGetMessageSize(Handle, ref sz);

                return sz;
            }
        }

        public byte[] Buffer
        {
            get
            {
                uint s = 0;
                GribApiProxy.GribGetMessageSize(this.Handle, ref s);
                // grib_api returns the data buffer pointer, but continues to own the memory, so no de/allocation is necessary 
                IntPtr p = IntPtr.Zero;
                GribApiProxy.GribGetMessage(this.Handle, ref p, out s);

                int tl = (int) s;
                byte[] bytes = new byte[tl];
                Marshal.Copy(p, bytes, 0, tl);

                return bytes;
            }
        }

        /// <summary>
        /// Returns an enumerator that iterates through the collection.
        /// </summary>
        /// <returns>
        /// A <see cref="T:System.Collections.Generic.IEnumerator`1" /> that can be used to iterate through the collection.
        /// </returns>
        public IEnumerator<GribValue> GetEnumerator ()
        {
            // null returns keys from all namespaces
            string nspace = Namespace == "all" ? null : Namespace;
            string name = "";

            var keyIter = GribApiProxy.GribKeysIteratorNew(Handle, KeyFilters, nspace);

            while (GribApiProxy.GribKeysIteratorNext(keyIter) != 0)
            {
                name = GribApiProxy.GribKeysIteratorGetName(keyIter);
                yield return this[name];
            }

            GribApiProxy.GribKeysIteratorDelete(keyIter);
        }

        /// <summary>
        /// NOT IMPLEMENTED.
        /// </summary>
        /// <returns>
        /// An <see cref="T:System.Collections.IEnumerator" /> object that can be used to iterate through the collection.
        /// </returns>
        /// <exception cref="System.NotImplementedException"></exception>
        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator ()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Gets the <see cref="GribValue"/> with the specified key name.
        /// </summary>
        /// <value>
        /// The <see cref="GribValue"/>.
        /// </value>
        /// <param name="keyName">Name of the key.</param>
        /// <returns></returns>
        public GribValue this[string keyName]
        {
            get { return new GribValue(Handle, keyName); }
        }


        //public void gridType
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_gridType_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        int ret = GribApiProxyPINVOKE.GribUtilGridSpec_gridType_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public int ni
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_ni_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        int ret = GribApiProxyPINVOKE.GribUtilGridSpec_ni_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public int nj
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_nj_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        int ret = GribApiProxyPINVOKE.GribUtilGridSpec_nj_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public double iDirectionIncrementInDegrees
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_iDirectionIncrementInDegrees_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        double ret = GribApiProxyPINVOKE.GribUtilGridSpec_iDirectionIncrementInDegrees_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public double jDirectionIncrementInDegrees
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_jDirectionIncrementInDegrees_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        double ret = GribApiProxyPINVOKE.GribUtilGridSpec_jDirectionIncrementInDegrees_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public double longitudeOfFirstGridPointInDegrees
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_longitudeOfFirstGridPointInDegrees_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        double ret = GribApiProxyPINVOKE.GribUtilGridSpec_longitudeOfFirstGridPointInDegrees_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public double longitudeOfLastGridPointInDegrees
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_longitudeOfLastGridPointInDegrees_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        double ret = GribApiProxyPINVOKE.GribUtilGridSpec_longitudeOfLastGridPointInDegrees_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public double latitudeOfFirstGridPointInDegrees
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_latitudeOfFirstGridPointInDegrees_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        double ret = GribApiProxyPINVOKE.GribUtilGridSpec_latitudeOfFirstGridPointInDegrees_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public double latitudeOfLastGridPointInDegrees
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_latitudeOfLastGridPointInDegrees_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        double ret = GribApiProxyPINVOKE.GribUtilGridSpec_latitudeOfLastGridPointInDegrees_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public int uvRelativeToGrid
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_uvRelativeToGrid_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        int ret = GribApiProxyPINVOKE.GribUtilGridSpec_uvRelativeToGrid_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public double latitudeOfSouthernPoleInDegrees
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_latitudeOfSouthernPoleInDegrees_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        double ret = GribApiProxyPINVOKE.GribUtilGridSpec_latitudeOfSouthernPoleInDegrees_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public double longitudeOfSouthernPoleInDegrees
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_longitudeOfSouthernPoleInDegrees_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        double ret = GribApiProxyPINVOKE.GribUtilGridSpec_longitudeOfSouthernPoleInDegrees_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public int iScansNegatively
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_iScansNegatively_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        int ret = GribApiProxyPINVOKE.GribUtilGridSpec_iScansNegatively_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public int jScansPositively
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_jScansPositively_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        int ret = GribApiProxyPINVOKE.GribUtilGridSpec_jScansPositively_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public int n
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_n_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        int ret = GribApiProxyPINVOKE.GribUtilGridSpec_n_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public int bitmapPresent
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_bitmapPresent_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        int ret = GribApiProxyPINVOKE.GribUtilGridSpec_bitmapPresent_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public double missingValue
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_missingValue_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        double ret = GribApiProxyPINVOKE.GribUtilGridSpec_missingValue_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public SWIGTYPE_p_long pl
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_pl_set(swigCPtr, SWIGTYPE_p_long.getCPtr(value));
        //    }
        //    get
        //    {
        //        global::System.IntPtr cPtr = GribApiProxyPINVOKE.GribUtilGridSpec_pl_get(swigCPtr);
        //        SWIGTYPE_p_long ret = (cPtr == global::System.IntPtr.Zero) ? null : new SWIGTYPE_p_long(cPtr, false);
        //        return ret;
        //    }
        //}

        //public int plSize
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_plSize_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        int ret = GribApiProxyPINVOKE.GribUtilGridSpec_plSize_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public int truncation
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_truncation_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        int ret = GribApiProxyPINVOKE.GribUtilGridSpec_truncation_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public double orientationOfTheGridInDegrees
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_orientationOfTheGridInDegrees_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        double ret = GribApiProxyPINVOKE.GribUtilGridSpec_orientationOfTheGridInDegrees_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public int dyInMetres
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_dyInMetres_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        int ret = GribApiProxyPINVOKE.GribUtilGridSpec_dyInMetres_get(swigCPtr);
        //        return ret;
        //    }
        //}

        //public int dxInMetres
        //{
        //    set
        //    {
        //        GribApiProxyPINVOKE.GribUtilGridSpec_dxInMetres_set(swigCPtr, value);
        //    }
        //    get
        //    {
        //        int ret = GribApiProxyPINVOKE.GribUtilGridSpec_dxInMetres_get(swigCPtr);
        //        return ret;
        //    }
        //}
    }
}
