# GribApi.NET

## What it is
GribApi.NET is a C# wrapper around the [European Centre for Medium Range Weather Forecasting's](http://www.ecmwf.int/) powerful [grib_api](https://software.ecmwf.int/wiki/display/GRIB/Home), a C library for reading, writing, and converting GRIB1 and GRIB2 files. GribApi.NET and grib_api are licensed under the friendly [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).

In theory, all grib_api_lib's functionality is already be exposed via [P\Invoke](https://msdn.microsoft.com/en-us/library/aa446536.aspx). However, there's more work required to make it "csharpy".

## Usage
Getting grid information in a GRIB message:
```csharp
using (GribFile file = new GribFile("mygrib.grb"))
{
	GribMessage msg = file.First();

	Console.WriteLine("Grid Type: " + msg.GridType)
	double lat = msg["latitudeOfFirstGridPointInDegrees"].AsDouble();
	
	// all values are also accessible as strings
	Console.WriteLine("latitudeOfFirstGridPointInDegrees = " + msg["latitudeOfFirstGridPointInDegrees"].AsString());
}
```

Iterating multiple messages:
```csharp
using (GribFile file = new GribFile("mygrib.grb"))
{
	foreach (GribMessage msg in file)
	{
		// do something
	}
}
```

Iterating Lat/Lon/Value:
```csharp

	GribMessage msg = gribFile.First();
	
	foreach (GeoSpatialValue val in msg.SpatialValues)
	{
		if (val.IsMissing) { continue; }

		Console.WriteLine("Lat: {0} Lon: {1} Val: {2}", val.Coordinate.Latitude, val.Coordinate.Longitude, val.Value);
	}
```

GribApi.NET loads GRIB 1 and 2 messages transparently, but you can determine the GRIB edition at runtime:
```csharp
using (GribFile file = new GribFile("somegribver.grb"))
{
	ver ed = file.First()["GRIBEditionNumber"].AsString();
}
```

For more examples, checkout the tests.

## Documentation
WIP. You'll find [ECMRW's grib_api documentation](https://software.ecmwf.int/wiki/display/GRIB/Documentation) helpful.

## Building
The current build is only designed for Windows and Visual Studio 2013. I am eager to get it converted to CMake and make it cross-platform. Even a consistent build using make under msys2 would be great. I'd love some help doing this. :)

Build the projects in this order:

1. ext/jasper-1.900.1/src/msvc/libjasper.vcxproj
2. ext/grib_api-1.14.0-Source/windows/msvc/grib_api.sln
3. src/GribApi.NET/GribApi.sln

After you build libjasper and grib_api_lib the first time, you should only need to build GribApi.sln thereafter.

## Running Tests
1. Install [NUnit](http://www.nunit.org/) and expose it on PATH.
2. Run `build/run_tests <bitness> <configuration> [optional "1" to break the tests on start]`, eg
```shell
build/run_tests x64 Debug
```

## A note about SWIG
Most of the interop interfaces are generated using SWIG and included in the repository. If you run SWIG yourself, you can use `build/swig_gen.cmd`. You'll need to hand edit a few places in the C# code and change the return signature from `void` to `int`. Just follow the IDE.
