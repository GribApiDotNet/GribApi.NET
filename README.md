# GribApi.NET

## What it is
GribApi.NET is a C# wrapper around the [European Centre for Medium Range Weather Forecasting's](http://www.ecmwf.int/) powerful [grib_api](https://software.ecmwf.int/wiki/display/GRIB/Home), a C library for reading, writing, and converting GRIB1 and GRIB2 files. 

GRIB is a format commonly used in meteorology to store weather data. GribApi.NET makes it easy to encode and decode these data by providing access to both GRIB editions through a set of [GRIB API keys](https://software.ecmwf.int/wiki/display/GRIB/GRIB%20API%20keys). GribApi.NET and grib_api are licensed under the friendly [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).

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
		// or, more simply:
		// GribFile.Write(outPath, readFile, FileMode.Append);
	}
```

GribApi.NET loads GRIB 1 and 2 messages transparently, but you can determine a message's GRIB edition at runtime:
```csharp
	using (GribFile file = new GribFile("somegrib.grb"))
	{
		string ed = file.First()["GRIBEditionNumber"].AsString();
	}
```

For more examples, checkout the tests.

## Building
The current build is only designed for Windows and Visual Studio 2013. I am eager to get it converted to CMake and make it cross-platform. Even a consistent build using make under msys2 would be great. I'd love some help doing this. :)

Build the projects in this order:

1. ext/jasper-1.900.1/src/msvc/libjasper.vcxproj
2. ext/grib_api-1.14.0-Source/windows/msvc/grib_api.sln
3. src/GribApi.NET/GribApi.sln

After you've built libjasper and grib_api_lib once, you should only need to build GribApi.sln thenceforth.

### Running SWIG
Most of the interop interfaces are generated using SWIG and included in the repository. If you want generate the interfaces yourself, you'll need SWIG installed and available on PATH. Then run `build/swig_gen.cmd`.

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

## Concepts

### GRIB API Keys
GribApi.NET treats GRIB messages as a collection of key-value pairs. 

### Types of Keys
#### Coded and Computed Keys
There are two different types of keys: coded and computed. The coded keys are directly linked to octets of the GRIB message and their value is obtained by only decoding the octets. Coded key names derive from the official WMO documentation on the GRIB 1 and 2 standards by removing the spaces in the key description and "camel casing" the initials. E.g., the caption `identification of originating generating centre` is transformed to `identificationOfOriginatingGeneratingCentre`. Some aliases are also available. You can find the captions for [most data representations on the WMO's site](http://www.wmo.int/pages/prog/www/WMOCodes/WMO306_vI2/LatestVERSION/LatestVERSION.html).

The computed keys are obtained by combining other keys (coded or computed) and when their value is set all the related keys are set in a cascade process. These keys provide a synthesis of the information contained in the GRIB message and are a safe way to set complex attributes such as the type of grid or the type of packing. They are also helpful in the interpretation of some octets such as the scanning mode whose bits are related to the way of scanning the grid. In this case the computed keys:
```
iScansNegatively
jScansPositively
jPointsAreConsecutive
alternativeRowScanning (available only for edition 2)
```
will provide access to single bits of the scanning mode octect hiding its structure from the user.

#### Read-Only Keys
The keys can also have some attributes as read only, which means that the key cannot be set (e.g. 7777 at the end of the message), or edition specific that is the attribute of all the keys having different values in the two editions (e.g. longitudeOfFirstGridPoint) or being present in one edition only (e.g. alternativeRowScanning).

#### Function Keys
There are some computed keys that cannot be "get" and can be considered as functions acting on the grib in some way. These keys are always characterised by a predicate in their name (e.g. setDecimalPrecision).

#### InDegrees
All the angle variables are provided in two versions, a native one with the units coded into the GRIB file and an edition independent one in degrees. It is always better to work with the "in degrees" version that is always provided through the key which has the same name of the native version with the suffix InDegrees
```
longitudeOfFirstGridPoint -> longitudeOfFirstGridPointInDegrees
latitudeOfFirstGridPoint -> latitudeOfFirstGridPointInDegrees
longitudeOfLastGridPoint -> longitudeOfLastGridPointInDegrees
latitudeOfFirstGridPoint -> latitudeOfLastGridPointInDegrees
latitudeOfFirstGridPoint -> latitudeOfFirstGridPointInDegrees
iDirectionIncrement -> iDirectionIncrementInDegrees
jDirectionIncrement -> jDirectionIncrementInDegrees
```

**You do not need to use the suffix "InDegrees" explicitly in GribApi.NET. The library converts key values to degrees by default, though you can disable this functionality.**

You can read more about GRIB API Keys [here](https://software.ecmwf.int/wiki/display/GRIB/GRIB%20API%20keys).