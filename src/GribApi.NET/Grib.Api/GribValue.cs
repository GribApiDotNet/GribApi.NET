using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Grib.Api.Interop.SWIG;

namespace Grib.Api
{
    public class GribValue
    {
        const uint MAX_KEY_LEN = 255;

        const uint MAX_VAL_LEN = 1024;
        private SWIGTYPE_p_grib_handle _handle;
        public string KeyName { get; private set; }
        public bool IsMissing
        {
            get
            {
                int err = 0;

                return GribApiProxy.GribIsMissing(_handle, KeyName, out err) == 1;
            }
        }

        public bool IsDefined
        {
            get
            {
                return GribApiProxy.GribIsDefined(_handle, KeyName) == 1;
            }
        }

        public GribValue(SWIGTYPE_p_grib_handle handle, string keyName, double missing = 9999D)
        {
            _handle = handle;
            KeyName = keyName;
        }

        public string AsString()
        {
            uint len = MAX_VAL_LEN;
            uint ptLen = 0;

            // not sure it's worth checking the length here--could just use MAX_VAL_LEN
            GribApiProxy.GribGetLength(_handle, KeyName, ref ptLen);
            StringBuilder val = new StringBuilder((int) ptLen);

            GribApiProxy.GribGetString(_handle, KeyName, val, ref len);

            return val.ToString();
        }

        public void AsString(string newValue)
        {
            uint len = (uint)newValue.Length;
            GribApiProxy.GribSetString(_handle, KeyName, newValue, ref len);
        }

        public int AsInt()
        {
            int val;

            GribApiProxy.GribGetLong(_handle, KeyName, out val);

            return val;
        }

        public void AsInt(int newValue)
        {
            GribApiProxy.GribSetLong(_handle, KeyName, newValue);
        }

        public int[] AsIntArray ()
        {
            uint sz = 0;
            GribApiProxy.GribGetSize(_handle, KeyName, ref sz);
            int[] values = new int[sz];
            GribApiProxy.GribGetLongArray(_handle, KeyName, values, ref sz);

            return values;
        }

        public void AsIntArray(int[] newValues)
        {
            GribApiProxy.GribSetLongArray(_handle, KeyName, newValues, (uint) newValues.Length);
        }

        public double AsDouble()
        {
            double val;

            GribApiProxy.GribGetDouble(_handle, KeyName, out val);

            return val;
        }

        public void AsDouble(double newValue)
        {
            GribApiProxy.GribSetDouble(_handle, KeyName, newValue);
        }

        public double[] AsDoubleArray ()
        {
            uint sz = 0;
            GribApiProxy.GribGetSize(_handle, KeyName, ref sz);
            double[] values = new double[sz];
            GribApiProxy.GribGetDoubleArray(_handle, KeyName, values, ref sz);

            return values;
        }

        public void AsDoubleArray (double[] newValues, bool force = false)
        {
            if (force)
            {
                GribApiProxy.GribSetForceDoubleArray(_handle, KeyName, newValues, (uint) newValues.Length);
            } else
            {
                GribApiProxy.GribSetDoubleArray(_handle, KeyName, newValues, (uint) newValues.Length);
            }
        }



        //public Type NativeType
        //{
        //    get
        //    {
        //        string typeName = "";
        //        GribApi2.GribGetNativeType()
        //    }
        //}
    }
}
