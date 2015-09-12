using Grib.Api.Interop.SWIG;
using Grib.Api.Interop;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Grib.Api
{
  class Program
  {
    //[DllImport("msvcrt.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi, SetLastError = true)]
    //public static extern int _open_osfhandle (IntPtr handle, int mode = 0);

    //[DllImport("msvcrt.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi, SetLastError = true)]
    //public static extern IntPtr _fdopen (int fd, String mode = "r");

    //[DllImport("msvcrt.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi, SetLastError = true)]
    //public static extern void rewind (IntPtr file);

    //[DllImport("msvcrt.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Unicode, SetLastError = true)]
    //public static extern IntPtr _wfopen (String filename, String mode);


    //[DllImport("kernel32.dll")]
    //static extern void RtlMoveMemory (IntPtr dest, IntPtr src, uint len);

    //[DllImport("grib_api_wrapper")]
    //public static extern IntPtr CreateFileHandleProxy (String filename, bool useMultifile = true);

    //[DllImport("grib_api_wrapper")]
    //public static extern void DestroyFileHandleProxy (FileHandleProxy filename);

    const string PACIFIC_WIND = "C:/Users/eric/grib_api/GribApi/GribApi/bin/Debug/Pacific.wind.7days.grb";
    const string GRIB = "C:/Users/eric/grib_api/GribApi/GribApi/GRIB.grb";
    const string REG_LATLON = "C:/Users/eric/grib_api/GribApi/GribApi/bin/Debug/regular_latlon_surface.grib1";
    const string REDUCED_LATLON = "C:/Users/eric/grib_api/GribApi/GribApi/bin/Debug/reduced_latlon_surface.grib2";
    const string OUT_INDEX = "C:/Users/eric/grib_api/GribApi/GribApi/bin/Debug/out.index";
    const string DEFINITIONS = "C:/Users/eric/grib_api/grib_api_lib/grib_api-1.14.0-Source/definitions";
    const string GAUSS = "C:/Users/eric/grib_api/GribApi/GribApi/bin/Debug/reduced_gaussian_model_level.grib1";
    const uint MAX_KEY_LEN = 255;

    const uint MAX_VAL_LEN =  1024;


    static void IterateKeys (GribFile file)
    {
      int err = 0;

      foreach(var msg in file)
      {
        foreach(var val in msg)
        {
          Console.WriteLine("{0} = {1}", val.KeyName, val.AsString());
        }

        Console.WriteLine();
      }
    }

      static void IterateLatLong(GribFile file)
    {
          foreach (var msg in file)
          {
              int i = 0;
              foreach (var val in msg.SpatialValues)
              {
                  if (val.IsMissing) { continue; }

                  Console.WriteLine("{0} - Lat: {1} Lon: {2} Value: {3}", i, val.Coordinate.Latitude, val.Coordinate.Longitude, val.Value);
                  i++;
              }
              var vals = msg.Values.SkipWhile(x => x == msg.MissingValue);
              Console.WriteLine("Max: {0} Min: {1} Avg: {2}", vals.Max(), vals.Min(), vals.Average());
          }
    }


      static void Precision(GribFile file)
    {
        var msg = file.First();
        Console.WriteLine("Bit per value: {0}", msg["bitsPerValue"].AsInt());
        Console.WriteLine("Precision: {0}", msg.DecimalPrecision);
        msg.DecimalPrecision = 4;
        Console.WriteLine("Bit per value: {0}", msg["bitsPerValue"].AsInt());
    }


    static void Index()
    {
      int err = 0;
      var c = GribApiProxy.GribContextGetDefault();
      var index = GribApiProxy.GribIndexNew(c, "shortName,level,number,step", out err);
      GribApiProxy.GribIndexAddFile(index, GRIB);
      uint sz = 0;
      GribApiProxy.GribIndexGetSize(index, "step", ref sz);
      int[] values = new int[sz];
      GribApiProxy.GribIndexGetLong(index, "step", values, ref sz);
    }


    static void Get (GribFile file)
    {
      var msg = file.First();

      double latitudeOfFirstGridPointInDegrees = msg["latitudeOfFirstGridPointInDegrees"].AsDouble();
      double longitudeOfFirstGridPointInDegrees = msg["longitudeOfFirstGridPointInDegrees"].AsDouble();
      double latitudeOfLastGridPointInDegrees = msg["latitudeOfLastGridPointInDegrees"].AsDouble();
      double longitudeOfLastGridPointInDegrees = msg["longitudeOfLastGridPointInDegrees"].AsDouble();
      double jDirectionIncrementInDegrees = msg["jDirectionIncrementInDegrees"].AsDouble();
      double iDirectionIncrementInDegrees = msg["iDirectionIncrementInDegrees"].AsDouble();

      int numberOfPointsAlongAParallel = msg["numberOfPointsAlongAParallel"].AsInt();
      int numberOfPointsAlongAMeridian = msg["numberOfPointsAlongAMeridian"].AsInt();

      string packingType = msg["packingType"].AsString();

      double[] values = msg.Values;

    }


    static void Main (string[] args)
    {
        GribEnvironment.DefinitionsPath = DEFINITIONS;
        GribEnvironment.NoAbort = true;

      var file = new GribFile(REDUCED_LATLON);
    //  Precision(file);
      IterateLatLong(file);
     // Get(file);
      // IterateKeys(file);
      new ManualResetEvent(false).WaitOne();
    }
  }
}
