# Key Concepts
(shameless pun is absolutely intended)

## GRIB API Keys
GribApi.NET treats GRIB messages as a collection of key-value pairs. 

### Types of Keys
#### Coded and Computed Keys
There are two different types of keys: coded and computed. The coded keys are obtained by directly decoding the GRIB file octets. The key names derive from the official WMO documentation on the GRIB 1 and 2 standards. Spaces are removed from the the key description and the words are "camel cased". E.g., the caption `identification of originating generating centre` is transformed to `identificationOfOriginatingGeneratingCentre`. Some aliases are also available. You can find the captions for [most data representations on the WMO's site](http://www.wmo.int/pages/prog/www/WMOCodes/WMO306_vI2/LatestVERSION/LatestVERSION.html).

The computed keys are obtained by combining other keys (coded or computed). When their value is set all related keys are updated in a cascade process. These keys synthesize information contained in the GRIB message and are a safe way to set complex attributes such as the type of grid or the type of packing. They also help interpret octets such as the scanning mode whose bits are related to the way of scanning the grid. In this case the computed keys:
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