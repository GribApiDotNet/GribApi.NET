# GribApi.NET

## What it is
GribApi.NET is a C# wrapper around the [European Centre for Medium Range Weather Forecasting's](http://www.ecmwf.int/) powerful [grib_api](https://software.ecmwf.int/wiki/display/GRIB/Home), a C library for reading, writing, and converting GRIB1 and GRIB2 files. 

GRIB is a format commonly used in meteorology to store weather data. GribApi.NET makes it easy to encode and decode these data by providing access to both GRIB editions through a set of [GRIB API keys](https://software.ecmwf.int/wiki/display/GRIB/GRIB%20API%20keys). GribApi.NET and grib_api are licensed under the friendly [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).

Special thanks to John L'Heureux, Meteorological Data Analyst at aWhere, Inc., for his contributions as scientific advisor.

#### Features
* Read and write GRIB 1 and 2 messages
* Easy to understand API
* Thread safe
* JPEG and PNG compression support
* Multi-field support

--------------------------

## Docs
The documentation is very much a WIP, but you'll find [grib_api's wiki](https://software.ecmwf.int/wiki/display/GRIB/Home), helpful.

* [Key Concepts](https://github.com/0x1mason/GribApi.NET/blob/master/docs/KeyConcepts.md)
* [Example Key Dump](https://github.com/0x1mason/GribApi.NET/blob/master/docs/TypicalKeyDump.md)

--------------------------

## Usage
Make sure you have the [MSVC 2013 redistributables](https://www.microsoft.com/en-us/download/details.aspx?id=40784) installed.

Install [GribApi.NET using Nuget](https://www.nuget.org/packages/Grib.Api). From Package Manager Console run
```shell
PM> Install-Package Grib.Api 
```

#### Shadow Copying
**ASP.NET**, **NUnit**, and other frameworks employ a technique called "shadow copying". When Grib.Api.dll is shadow copied, GribApi.NET may have difficulty locating the `Grib.Api` directory, which is required for proper operation.

There are several ways to deal with this issue. The simplest is to set the`GRIB_API_DIR_ROOT` before calling GribApi.NET for the first time. The value should be the directory *containing* the `Grib.Api` directory. E.g., for `C:\Some\Path\Grib.Api`, set:
```csharp
Environment.SetEnvironmentVariable("GRIB_API_DIR_ROOT", "C:\\Some\\Path", EnvironmentVariableTarget.Process);
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

#### Iterating lat/lon/value:
```csharp

	GribMessage msg = gribFile.First();
	
	// the values in GeoSpatialValues are calculated by grid type
	foreach (GeoSpatialValue val in msg.GeoSpatialValues)
	{
		if (val.IsMissing) { continue; }

		Console.WriteLine("Lat: {0} Lon: {1} Val: {2}", val.Latitude, val.Longitude, val.Value);
	}
```

#### Cherry-picking messages by parameter name
```csharp
	using(GribFile file = new GribFile(@".\TestData\Pacific.wind.7days.grb"))
	{
		var vComp = file.Where(m => m.Name.Contains("V-component of wind m s**-1")).First();

		foreach (var val in vComp.GeoSpatialValues)
		{
			Console.WriteLine("Lat: {0} Lon: {1} Val: {2}", val.Latitude, val.Longitude, val.Value);
		}
	}
```

#### Getting raw data:
```csharp

	GribMessage msg = gribFile.First();
	double[] rawValues;
	
	// a copy of the raw values stored in the message
	msg.Values(out rawValues);
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

--------------------------

## Building
The current build is only designed for Windows and Visual Studio. I am eager to get it converted to CMake and make it cross-platform. Even a consistent build using make under msys2 would be great. I'd love some help doing this. :)

First, install the Nuget packages (this assumes you have nuget on PATH):
```shell
nuget install NUnit -Version 2.6.4 -O src\GribApi.NET\packages\
```

Make `NUnit 2.6.4` available on PATH. Then run:
```shell
build\build_gribapi.cmd [build|rebuild] [VS version, 11|12|14] [Debug|Release] [nuget package version]
```

E.g., to build with Visual Studio 2013 (VS version 12):
```shell
build\build_gribapi.cmd build 12 Debug
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
