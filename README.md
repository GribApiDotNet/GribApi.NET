# GribApi.NET

## What it is
GribApi.NET is a C# wrapper around the [European Centre for Medium Range Weather Forecasting's](http://www.ecmwf.int/) powerful [grib_api](https://software.ecmwf.int/wiki/display/GRIB/Home), a C library for reading, writing, and converting GRIB1 and GRIB2 files. GribApi.NET and grib_api are licensed under the friendly [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).

In theory, all grib_api_lib's functionality is already be exposed via [P\Invoke](https://msdn.microsoft.com/en-us/library/aa446536.aspx). However, there's more work required to make it "csharpy".

## Usage
Add **Grib.Api.dll**, **Grib.Api.Native.dll**, and the **ext/grib_api/definitions** directory to your project. By default, GribApi.NET assumes the definitions are in the same directory as the library, but you can change the location by setting `Grib::Api::GribEnvironment::DefinitionsPath` or setting the `GRIB_DEFINITION_PATH` environment variable.

You're ready to go!

### Examples
Getting grid information from a GRIB message:
```csharp
	using (GribFile file = new GribFile("mygrib.grb"))
	{
		GribMessage msg = file.First();

		Console.WriteLine("Grid Type: " + msg.GridType);
		double lat = msg["latitudeOfFirstGridPoint"].AsDouble();
		
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
	
	foreach (GeoSpatialValue val in msg.GeoSpatialValues)
	{
		if (val.IsMissing) { continue; }

		Console.WriteLine("Lat: {0} Lon: {1} Val: {2}", val.Latitude, val.Longitude, val.Value);
	}
```

Editing a single message and saving to a new file:
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

Appending multiple messages to an existing file:
```csharp
	using (GribFile readFile = new GribFile(readPath))
	{                
		Console.WriteLine("Appending {0} messages from {1} to {2}", readFile.MessageCount, readPath, outPath);

		GribFile.Write(outPath, readFile as IEnumerable<GribMessage>, FileMode.Append);
	}
```

GribApi.NET loads GRIB 1 and 2 messages transparently, but you can determine a message's GRIB edition at runtime:
```csharp
	using (GribFile file = new GribFile("somegribver.grb"))
	{
		string ed = file.First()["GRIBEditionNumber"].AsString();
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

After you've built libjasper and grib_api_lib once, you should only need to build GribApi.sln thenceforth.

### Running SWIG
Most of the interop interfaces are generated using SWIG and included in the repository. If you want generate the interfaces yourself, you'll need SWIG installed and available on PATH. Then run `build/swig_gen.cmd`.

## Running Tests
1. Install [NUnit](http://www.nunit.org/) and expose it on PATH.
2. Run `build/run_tests <architecture> <configuration> [optional "1" to break the tests on start]`, e.g.
```shell
build/run_tests x64 Debug
```
or
```shell
build/run_tests x86 Debug 1
```
