# GribApi.NET

## What it is
GribApi.NET is a C# wrapper around the [European Centre for Medium Range Weather Forecasting's](http://www.ecmwf.int/) powerful [grib_api](https://software.ecmwf.int/wiki/display/GRIB/Home), a C library for reading, writing, and converting GRIB1 and GRIB2 files. 

GRIB is a format commonly used in meteorology to store weather data. GribApi.NET makes it easy to encode and decode these data by providing access to both GRIB editions through a set of [GRIB API keys](https://software.ecmwf.int/wiki/display/GRIB/GRIB%20API%20keys). GribApi.NET and grib_api are licensed under the friendly [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).

## Docs
The documentation is very much a WIP, but you'll find [grib_api's wiki](https://software.ecmwf.int/wiki/display/GRIB/Home), helpful.

* [Example Key Dump](https://github.com/0x1mason/GribApi.NET/blob/master/docs/TypicalKeyDump.md)
* [Key Concepts](https://github.com/0x1mason/GribApi.NET/blob/master/docs/KeyConcepts.md)

## Usage
Install [GribApi.NET using Nuget](https://www.nuget.org/packages/Grib.Api). From Package Manager Console run
```shell
PM> Install-Package Grib.Api 
```

### Examples
#### Getting grid information from a GRIB message:
```csharp
	using (GribFile file = new GribFile("mygrib.grb"))
	{
		GribMessage msg = file.First();

		Console.WriteLine("Grid Type: " + msg.GridType);
		
		double latInDegrees = msg["latitudeOfFirstGridPoint"].AsDouble();
		// GribApi.NET automatically converts coordinate values to degrees. This follows the best practice
		// advised by ECMWF and normalizes the values returned by the API. You can opt-out of degree
		// conversion by calling `AsDouble(false)`, e.g.:
		//     double rawValue = msg["latitudeOfFirstGridPoint"].AsDouble(false);
		// Only values capable of degree conversion are affected.
		
		// all values are also accessible as strings
		Console.WriteLine("latitudeOfFirstGridPointInDegrees = " + msg["latitudeOfFirstGridPoint"].AsString());
	}
```

#### Iterating multiple messages:
```csharp
	using (GribFile file = new GribFile("mygrib.grb"))
	{
		foreach (GribMessage msg in file)
		{
			// do something
		}
	}
```

#### Iterating Lat/Lon/Value:
```csharp

	GribMessage msg = gribFile.First();
	
	foreach (GeoSpatialValue val in msg.GeoSpatialValues)
	{
		if (val.IsMissing) { continue; }

		Console.WriteLine("Lat: {0} Lon: {1} Val: {2}", val.Latitude, val.Longitude, val.Value);
	}
```

#### Editing a single message and saving to a new file:
```csharp
	string outPath = "out.grb";
	string readPath = "some.grb";
	
	using (GribFile readFile = new GribFile(readPath))
	{
		Console.WriteLine("Writing 1 message from {0} to {1}", readPath, outPath);

		var msg = readFile.First();
		msg["latitudeOfFirstGridPoint"].AsDouble(42);
		GribFile.Write(outPath, msg);
	}
```

#### Appending multiple messages to an existing file:
```csharp
	using (GribFile readFile = new GribFile(readPath))
	{                
		Console.WriteLine("Appending {0} messages from {1} to {2}", readFile.MessageCount, readPath, outPath);

		GribFile.Write(outPath, readFile as IEnumerable<GribMessage>, FileMode.Append);
		// or, more simply:
		//   GribFile.Write(outPath, readFile, FileMode.Append);
	}
```

For more examples, checkout the tests.

## Building
The current build is only designed for Windows and Visual Studio. I am eager to get it converted to CMake and make it cross-platform. Even a consistent build using make under msys2 would be great. I'd love some help doing this. :)

To build, you can use `build/Grib.Api.Master.sln`. The native projects are set to use the v110 (Visual Studio 2012) Cpp build tools. However, you can change these to match your version of VS in the native projects' `Properties > General > Platform Toolset` field.

To run a full release build, you'll need `NUnit` and `Nuget` on PATH. Then run:
```shell
build/build_gribapi.cmd [build|rebuild] [VS version, 11|12|14]
```

E.g., to build with Visual Studio 2012 (VS version 11):
```shell
build/build_gribapi.cmd build 11
```

### Running SWIG
Most of the interop interfaces are generated using `SWIG` and included in the repository. If you want generate the interfaces yourself, you'll need `SWIG` installed and available on PATH. Then run `build/swig_gen.cmd`.

### Running Tests
1. Install [NUnit](http://www.nunit.org/) and expose it on PATH.
2. Run `build/run_tests <architecture> <configuration> [optional "1" to break the tests on start]`, e.g.
```shell
build/run_tests x64 Debug
```
or
```shell
build/run_tests x86 Debug 1
```