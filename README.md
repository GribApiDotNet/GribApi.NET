# GribApi.NET

## What it is
GribApi.NET is a C# wrapper around the [European Centre for Medium Range Weather Forecasting's](http://www.ecmwf.int/) powerful [ecCodes](https://software.ecmwf.int/wiki/display/ECC/ecCodes+Home), a C library for reading, writing, and converting GRIB1 and GRIB2 files. `ecCodes` is the successor to `grib_api`.

GRIB is a format commonly used in meteorology to store weather data. GribApi.NET makes it easy to encode and decode these data by providing access to both GRIB editions through a set of [GRIB API keys](https://software.ecmwf.int/wiki/display/GRIB/GRIB%20API%20keys). It can handle all common GRIB formats from centres such as NOAA's NCEP and the ECMWF. GribApi.NET and grib_api are licensed under the friendly [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).

Special thanks to John L'Heureux, for his contributions as scientific advisor.

#### Features
* Read and write GRIB 1 and 2 messages
* Easy to understand API
* Supports x86, x64, and "All CPU"
* Thread safe
* JPEG and PNG compression support
* Multi-field support
* Support for custom GRIB formats

#### GRIB Tools
You can also use grib_api via CLI. Checkout the GRIB tools package on [Chocolatey](https://chocolatey.org/packages/grib-tools). At the very least, you'll find it very helpful for debugging.

--------------------------

## Docs
The documentation is very much a WIP, but you'll find the [ecCodes website](https://software.ecmwf.int/wiki/display/ECC/Documentation) helpful.

* [GRIB Parameter Database](http://apps.ecmwf.int/codes/grib/param-db/)
* [Key Concepts](https://github.com/0x1mason/GribApi.NET/blob/master/docs/KeyConcepts.md)
* [Example Key Dump](https://github.com/0x1mason/GribApi.NET/blob/master/docs/TypicalKeyDump.md)
* [ecCodes API](http://download.ecmwf.int/test-data/eccodes/html/eccodes_8h.html)

--------------------------

## Usage
Make sure you have the [MSVC 2015 redistributables](https://www.microsoft.com/en-us/download/details.aspx?id=48145) installed. If you don't, you can use `chocolatey`, 
```shell
C:\> choco install vcredist2015
```

Install [GribApi.NET using Nuget](https://www.nuget.org/packages/Grib.Api). From Package Manager Console run
```shell
PM> Install-Package Grib.Api 
```

#### Troubleshooting
In general, GribApi.NET should "just work". In rare cases, GribApi.NET may have difficulty locating the `definitions` directory, which contains a number of dependencies.

To solve this problem, you can manually set the path to the definitions:
```csharp
GribEnvironment.Init();
GribEnvironment.DefinitionsPath = "C:\\Some\\Path\\Grib.Api\\definitions";
```

### Examples

#### Getting grid information from a GRIB message:
```csharp
	using (GribFile file = new GribFile("mygrib2.grib"))
	{
		GribMessage msg = file.First();

		Console.WriteLine("Grid Type: " + msg.GridType);
		
      // GribApi.NET normalizes the coordinate values to degrees.
		double latInDegrees = msg["latitudeOfFirstGridPoint"].AsDouble();
		
		// values are also accessible as strings
		Console.WriteLine("latitudeOfFirstGridPoint = " + msg["latitudeOfFirstGridPoint"].AsString());
	}
```

#### Iterating messages in a file:
```csharp
	using (GribFile file = new GribFile("mygrib1.grib"))
	{
		foreach (GribMessage msg in file)
		{
			// do something
		}
	}
```

#### Iterating messages in a stream _Note: iterating streams is currently much slower than iterating a file_:
```csharp
   var gribStream = new GribStream(myStream);
   foreach (GribMessage msg in gribStream)
   {
      // do something
   }
```

#### Iterating lat/lon/value:
```csharp

	GribMessage msg = gribFile.First();
	
	// the values in GridCoordinateValues are calculated by grid type
	foreach (GridCoordinateValue val in msg.GridCoordinateValues)
	{
		if (val.IsMissing) { continue; }

		Console.WriteLine("Lat: {0} Lon: {1} Val: {2}", val.Latitude, val.Longitude, val.Value);
	}
```

#### Finding the four nearest grid values to a coordinate
```csharp

	GribMessage msg = gribFile.First();
   var referencePt = msg.GridCoordinateValues.First();
   
   Console.WriteLine("Getting the four nearest grid points to Lat: {0} Lon: {1}", referencePt.Latitude, referencePt.Longitude);

   var nearest = msg.FindNearestCoordinates(referencePt);
   
	foreach (var near in nearest)
	{
      GridCoordinateValue val = near.Value;
		Console.WriteLine("Lat: {0} Lon: {1} Val: {2} Distance: {3}", var.Latitude, val.Longitude, val.Value, near.Distance);
	}
```

#### Cherry-picking messages by parameter name
```csharp
	using(GribFile file = new GribFile(@".\TestData\Pacific.wind.7days.grb"))
	{
		var vComp = file.Where(m => m.Name.Contains("V-component of wind m s**-1")).First();

		foreach (var val in vComp.GridCoordinateValues)
		{
			Console.WriteLine("Lat: {0} Lon: {1} Val: {2}", val.Latitude, val.Longitude, val.Value);
		}
	}
```

#### Dumping message keys to a pretty-printed string:
```csharp
	using (GribFile file = new GribFile("mygrib.grb"))
	{
		GribMessage msg = file.First();
		
		Console.WriteLine(msg.Dump());
	}
```

#### Dumping grid values to a CSV:
```csharp
	using (GribFile file = new GribFile("mygrib.grb"))
	{
		GribMessage msg = file.First();
		
		msg.WriteValuesToCsv("my\\file.csv");
	}
```

#### Getting raw data:
```csharp

	GribMessage msg = gribFile.First();
	double[] rawValues;
	
	// get a copy of the raw values stored in the message
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
      
      double[] rawValues;
      msg.Values(out rawValues);
      // update the values
      // ...
      msg.SetValues(rawValues);
      
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

Install [NUnit 2.6.4](http://www.nunit.org/). Then run:
```shell
build\build_gribapi.cmd [build|rebuild] [VS version, 11|12|14] [Debug|Release] [nuget package version]
```

E.g., to build with Visual Studio 2015 (VS version 14):
```shell
build\build_gribapi.cmd build 14 Debug
```

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
