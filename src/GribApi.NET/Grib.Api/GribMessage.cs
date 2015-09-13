using Grib.Api.Interop.SWIG;
using Grib.Api.Interop;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api
{
    public class GribMessage: AutoCleanup, IEnumerable<GribValue>
    {
        private SWIGTYPE_p_FILE _file;
        public static readonly string[] Namespaces = { "all", "ls", "parameter", "statistics", "time", "geography", "vertical", "mars" };
        
        internal GribMessage () { }

        internal GribMessage(SWIGTYPE_p_grib_handle handle, SWIGTYPE_p_FILE file, SWIGTYPE_p_grib_context context = null):base()
        {
            _file = file;
            Handle = handle;
            Context = context ?? GribApiProxy.GribContextGetDefault();
            Namespace = Namespaces[0];
            KeyFilters |= (uint) GribApiProxy.GRIB_KEYS_ITERATOR_ALL_KEYS;
            MissingValue = this["missingValue"].AsDouble();
        }

        protected override void OnDispose ()
        {
            GribApiProxy.GribHandleDelete(Handle);
        }

        public SWIGTYPE_p_grib_handle Handle { get; protected set; }

        public SWIGTYPE_p_grib_context Context { get; protected set; }

        public double MissingValue { get; private set; }

        public string Namespace { get; set; }

        public uint KeyFilters { get; set; }

        public string GridType { get { return this["gridType"].AsString(); } }

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

        public IEnumerable<GeoSpatialValue> SpatialValues 
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

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator ()
        {
            throw new NotImplementedException();
        }

        public void SaveAs(string path)
        {
           // GribApiProxy.GribGetMessage(this.Handle,)
        }

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
