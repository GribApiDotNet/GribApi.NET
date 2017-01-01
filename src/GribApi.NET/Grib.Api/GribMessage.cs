// Copyright 2015 Eric Millin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

using Grib.Api.Interop.SWIG;
using Grib.Api.Interop;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Diagnostics;

namespace Grib.Api
{
    /// <summary>
    /// Grib message object. Each grib message has attributes corresponding to grib message keys for GRIB1 and GRIB2.
    /// Parameter names are are given by the name, shortName and paramID keys. When iterated, returns instances of the
    /// <seealso cref="Grib.Api.GribValue"/> class.
    /// </summary>
    public class GribMessage: IEnumerable<GribValue>
    {
        private static readonly string[] _ignoreKeys = { "zero","one","eight","eleven","false","thousand","file",
                       "localDir","7777","oneThousand" };

        /// <summary>
        /// The key namespaces. Set the <see cref="Namespace"/> property with these values to
        /// filter the keys return when iterating this message. Default value is [all].
        /// </summary>
        public static readonly string[] Namespaces = { "all", "ls", "parameter", "statistics", "time", "geography", "vertical", "mars" };

        /// <summary>
        /// Initializes a new instance of the <see cref="GribMessage" /> class.
        /// </summary>
        /// <param name="handle">The handle.</param>
        /// <param name="context">The context.</param>
        /// <param name="index">The index.</param>
        protected GribMessage (GribHandle handle, GribContext context = null, int index = 0)
            : base()
        {
            Handle = handle;
            Namespace = Namespaces[0];
            KeyFilters = Interop.KeyFilters.All;
            Index = index;
        }

        /// <summary>
        /// Returns an enumerator that iterates through the collection.
        /// </summary>
        /// <returns>
        /// A <see cref="T:System.Collections.Generic.IEnumerator`1" /> that can be used to iterate through the collection.
        /// </returns>
        public IEnumerator<GribValue> GetEnumerator ()
        {
            // null returns keys from all namespaces
            string nspace = Namespace == "all" ? null : Namespace;

            using (var keyIter = GribKeysIterator.Create(Handle, (uint) KeyFilters, nspace))
            {
                while (keyIter.Next())
                {
                    string key = keyIter.Name;

                    if (_ignoreKeys.Contains(key)) { continue; }

                    yield return this[key];
                }
            }
        }

        /// <summary>
        /// NOT IMPLEMENTED.
        /// </summary>
        /// <returns>
        /// An <see cref="T:System.Collections.IEnumerator" /> object that can be used to iterate through the collection.
        /// </returns>
        /// <exception cref="System.NotImplementedException"></exception>
        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator ()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Clones this instance.
        /// </summary>
        /// <returns></returns>
        public GribMessage Clone()
        {
            var newHandle = GribApiProxy.GribHandleClone(this.Handle);

            return new GribMessage(newHandle);
        }

        /// <summary>
        /// Creates a GribMessage instance from a <seealso cref="Grib.Api.GribFile"/>.
        /// </summary>
        /// <param name="file">The file.</param>
        /// <param name="index">The index.</param>
        /// <returns></returns>
        public static GribMessage Create(GribFile file, int index) 
        {
            GribMessage msg = null;
            int err = 0;
            // grib_api moves to the next message in a stream for each new handle
            GribHandle handle = GribApiProxy.GribHandleNewFromFile(file.Context, file, out err);

            if (err != 0)
            {
                throw GribApiException.Create(err);
            }

            if (handle != null)
            {
                msg = new GribMessage(handle, file.Context, index);
            }

            return msg;
        }

        /// <summary>
        /// Returns a <see cref="System.String" /> containing metadata about this instance.
        /// </summary>
        /// <returns>
        /// A <see cref="System.String" /> containing metadata about this instance.
        /// </returns>
        public override string ToString ()
        {
            //{Index}:{parameterName} ({stepType }):{grid_type}:{typeOfLevel} {level}:fcst time {stepRange} hrs {if ({stepType == 'avg'})}:from {dataDate}{dataTime}
            string stepType = this["stepType"].AsString();
            string timeQaulifier = stepType == "avg" ? String.Format("({0})", stepType) : "";

            return String.Format("{0}:[{10}] \"{1}\" ({2}):{3}:{4} {5}:fcst time {6} {7}s {8}:from {9}", Index, Name, StepType, GridType, TypeOfLevel, Level, StepRange, "hr", timeQaulifier, Time.ToString("yyyy-MM-dd HHmm"), ShortName);
        }

        /// <summary>
        /// Gets a *copy* of the raw data associated with this message. This data is static,
        /// regardless of the projection used.
        /// </summary>
        /// <remarks>
        /// This is an explicit function rather than a property because C# property semantics tempt devs
        /// to iterate directly on the values array. For each call to the indexer, however, (eg msg.Values[i])
        /// the *entire* array gets copied, leading to terrible performance. At some point we can handle
        /// this on the native side.
        /// </remarks>
        /// <param name="values">The values.</param>
        public void Values(out double[] values)
        {
            values = this["values"].AsDoubleArray();
        }

        /// <summary>
        /// Sets the raw data associated with this message. The array is *copied*.
        /// </summary>
        /// <param name="values">The values.</param>
        public void SetValues(double[] values)
        {
            this["values"].AsDoubleArray(values);
        }

        #region Properties

        /// <summary>
        /// Gets the parameter name.
        /// </summary>
        /// <value>
        /// The name.
        /// </value>
        public string Name
        {
            get { return this["parameterName"].AsString(); }
        }

        /// <summary>
        /// Gets the parameter's short name.
        /// </summary>
        /// <value>
        /// The short name.
        /// </value>
        public string ShortName
        {
            get { return this["shortName"].AsString(); }
        }

		/// <summary>
		/// Gets the GRIB specification edition. grib_api does not always correctly identify the edition, in which case this property return 0.
		/// </summary>
		public int Edition
		{
			get
			{
				if (this._ed == -1)
				{
					string gen = this["GRIBEditionNumber"].AsString();

					if (!Int32.TryParse(gen, out this._ed))
					{
						gen = this["editionNumber"].AsString();

						if (!Int32.TryParse(gen, out this._ed))
						{
							this._ed = 0;
						}
					}
				}

				// allow for GRIB N?
				if (this._ed < 0)
				{
					throw new GribApiException("Bad GRIB edition.");
				}

				Debug.Assert(this._ed < 3);

				return this._ed;
			}
		}
		private int _ed = -1;

        /// <summary>
        /// Gets or sets the parameter number.
        /// </summary>
        /// <value>
        /// The parameter number.
        /// </value>
        public int ParameterNumber
        {
            get { return this["parameterNumber"].AsInt(); }
            set { this["parameterNumber"].AsInt(value); }
        }

        /// <summary>
        /// Gets or sets the parameter units.
        /// </summary>
        /// <value>
        /// The units.
        /// </value>
        public string Units
        {
            get { return this["parameterUnits"].AsString(); }
        }

		/// <summary>
		/// Gets or sets the unit of the step. This will be the short name from the following table:
		/// 
		/// 0 m  Minute
		/// 1 h  Hour
		/// 2 D  Day
		/// 3 M  Month
		/// 4 Y  Year
		/// 5 10Y  Decade (10 years)
		/// 6 30Y  Normal (30 years)
		/// 7 C  Century (100 years)
		/// 10 3h  3 hours
		/// 11 6h  6 hours
		/// 12 12h  12 hours
		/// 13 s  Second
		/// 14 15m  15 minutes
		/// 15 30m  30 minutes
		/// 255 255  Missing
		/// 
		/// </summary>
		/// <value>
		/// The type of the step.
		/// </value>
		public string StepUnit
		{
			get { return this["stepUnits"].AsString(); }
			set { this["stepUnits"].AsString(value); }
		}

        /// <summary>
        /// Gets or sets the type of the step.
        /// </summary>
        /// <value>
        /// The type of the step.
        /// </value>
        public string StepType
        {
            get { return this["stepType"].AsString(); }
            set { this["stepType"].AsString(value); }
        }

        /// <summary>
        /// Gets or sets the step range.
        /// </summary>
        /// <value>
        /// The step range.
        /// </value>
        public string StepRange
        {
            get { return this["stepRange"].AsString(); }
            set { this["stepRange"].AsString(value); }
        }

        /// <summary>
        /// Gets or sets the start step.
        /// </summary>
        /// <value>
        /// The start step.
        /// </value>
        public string StartStep
        {
            get { return this["startStep"].AsString(); }
            set { this["startStep"].AsString(value); }
        }

        /// <summary>
        /// Gets or sets the end step.
        /// </summary>
        /// <value>
        /// The end step.
        /// </value>
        public string EndStep
        {
            get { return this["endStep"].AsString(); }
            set { this["endStep"].AsString(value); }
        }

        /// <summary>
        /// Gets or sets the type of level.
        /// </summary>
        /// <value>
        /// The type of level.
        /// </value>
        public string TypeOfLevel
        {
            get { return this["typeOfLevel"].AsString(); }
            set { this["typeOfLevel"].AsString(value); }
        }

        /// <summary>
        /// Gets or sets the level.
        /// </summary>
        /// <value>
        /// The level.
        /// </value>
        public int Level
        {
            get { return this["level"].AsInt(); }
            set { this["level"].AsInt(value); }
        }

        /// <summary>
        /// Gets or sets the time range unit.
        /// </summary>
        /// <value>
        /// The time range unit.
        /// </value>
        public string TimeRangeUnit
        {
            get { return this["unitOfTimeRange"].AsString(); }
            set { this["unitOfTimeRange"].AsString(value); }
        }

		/// <summary>
		/// Gets or set the *reference* time of the data - date and time of start of averaging or accumulation period. Time is UTC.
		/// </summary>
		/// <value>
		/// The reference time.
		/// </value>
		public DateTime ReferenceTime
		{
			get
			{
				return new DateTime(this["year"].AsInt(), this["month"].AsInt(), this["day"].AsInt(),
									this["hour"].AsInt(), this["minute"].AsInt(), this["second"].AsInt(),
									DateTimeKind.Utc);
			}
			set
			{
				this["year"].AsInt(value.Year);
				this["month"].AsInt(value.Month);
				this["day"].AsInt(value.Day);
				this["hour"].AsInt(value.Hour);
				this["minute"].AsInt(value.Minute);
				this["second"].AsInt(value.Second);
			}
		}

        /// <summary>
		/// Gets the beginning of the time interval, i.e., ReferenceTime + forecastTime or ReferenceTime + P2. Time is UTC.
		/// If the time range indicator is greater than 5, ReferenceTime is returned.
        /// </summary>
        /// <value>
        /// The time.
        /// </value>
        public DateTime Time
        {
            get
            {
				string key = this["forecastTime"].IsDefined ? "forecastTime" : "P2";

				return this.GetOffsetTime(key);
            }
        }

		private static readonly string[] _legalTimeArgs = new[] { "P1", "P2", "forecastTime" };

		private DateTime GetOffsetTime (string p)
		{

			if (!_legalTimeArgs.Contains(p))
			{
				throw new ArgumentException("Argument must be in " + _legalTimeArgs.ToString());
			}

			DateTime time = this.ReferenceTime;
			string units = this.TimeRangeUnit;

			if (String.IsNullOrWhiteSpace(units))
			{
				units = this.StepUnit;
			}

			int offset = this[p].AsInt();
			int indicator = this["timeRangeIndicator"].AsInt();

			if (units != "255" && offset != 0)
			{
				offset *= GetTimeMultiplier(units);

				if (units.EndsWith("s"))
				{
					time = time.AddSeconds(offset);
				} else if (units.EndsWith("m"))
				{
					time = time.AddMinutes(offset);
				} else if (units.EndsWith("h"))
				{
					time = time.AddHours(offset);
				} else if (units.EndsWith("D"))
				{
					time = time.AddDays(offset);
				} else if (units.EndsWith("M"))
				{
					time = time.AddMonths(offset);
				} else if (units.EndsWith("Y"))
				{
					time = time.AddYears(offset);
				} else if (units.EndsWith("C")) 
				{
					time = time.AddYears(100 * offset);
				}
			}

			return time;
		}

		private static int GetTimeMultiplier (string units)
		{
			int multiplier = 1;

			if (units.Length > 1)
			{
				string val = units.Substring(0, units.Length - 2);
				Int32.TryParse(val, out multiplier);
			}

			return multiplier;
		}

        /// <summary>
        /// The total number of points on the grid and includes missing as well as 'real' values. DataPointsCount = <see cref="ValuesCount"/> + <see cref="MissingCount"/>.
        /// </summary>
        /// <value>
        /// The data points count.
        /// </value>
        public int DataPointsCount
        {
            get
            {
                return this["numberOfDataPoints"].AsInt();
            }
        }

        /// <summary>
        /// This is the number of 'real' values in the field and excludes the number of missing ones. Identical to 'numberOfCodedValues'
        /// </summary>
        /// <value>
        /// The values count.
        /// </value>
        public int ValuesCount
        {
            get
            {
                return this["numberOfCodedValues"].AsInt();
            }
        }

        /// <summary>
        /// The number of missing values in the field.
        /// </summary>
        /// <value>
        /// The missing count.
        /// </value>
        public int MissingCount
        {
            get
            {
                return this["numberOfMissing"].AsInt();
            }
        }

        /// <summary>
        /// Gets the index of the message within the file.
        /// </summary>
        /// <value>
        /// The index.
        /// </value>
        public int Index { get; protected set; }

        /// <summary>
        /// Gets or sets the grib_handle.
        /// </summary>
        /// <value>
        /// The handle.
        /// </value>
        protected GribHandle Handle { get; set; }

        /// <summary>
        /// Gets or sets the value used to represent a missing value. This value is used by grib_api,
        /// does not exist in the message itself.
        /// </summary>
        /// <value>
        /// The missing value.
        /// </value>
        public int MissingValue 
        { 
            get
            {
                return this["missingValue"].AsInt(); 
            }
            set
            {
                this["missingValue"].AsInt(value);
            }
        }

        /// <summary>
        /// Gets or sets a value indicating whether this instance has a bitmap.
        /// </summary>
        /// <value>
        /// <c>true</c> if this instance has bitmap; otherwise, <c>false</c>.
        /// </value>
        public bool HasBitmap
        {
            get
            {
                return this["bitmapPresent"].AsInt() == 1;
            }
            set
            {
                this["bitmapPresent"].AsInt(value ? 1 : 0);
            }
        }

        /// <summary>
        /// Set this property with a value in <see cref="Namespaces"/> to
        /// filter the keys return when iterating this message.
        /// </summary>
        /// <value>
        /// The namespace.
        /// </value>
        public string Namespace { get; set; }

        /// <summary>
        /// Gets or sets the key filters. The default is KeyFilters::All.
        /// </summary>
        /// <value>
        /// The key filter flags. They are OR-able bitflags.
        /// </value>
        public KeyFilters KeyFilters { get; set; }

        /// <summary>
        /// Gets the type of the grid.
        /// </summary>
        /// <value>
        /// The type of the grid.
        /// </value>
        public string GridType { get { return this["gridType"].AsString(); } }

        /// <summary>
        /// Gets or sets the decimal precision. Setting this value currently
        /// updates all packed values to the new precision. This key is only
        /// valid for simple packing.
        /// </summary>
        /// <value>
        /// The decimal precision.
        /// </value>
        /// <exception cref="GribApiException">You may only change decimal precision on messages that use simple packing.</exception>
        public int DecimalPrecision
        {
            get
            {
                return this["decimalPrecision"].AsInt();
            }
            set
            {
                if (this["packingType"].AsString() != "grid_simple")
                {
                    throw new GribApiException("You may only change decimal precision on messages that use simple packing.");
                }

                // 'changeDecimalPrecision' updates all packed values to the new precision;
                // 'decimalPrecision' does not -- should offer way to toggle
                this["changeDecimalPrecision"].AsInt(value);
            }
        }

        /// <summary>
        /// Gets the messages values with coordinates.
        /// </summary>
        /// <value>
        /// The geo spatial values.
        /// </value>
        public IEnumerable<GeoSpatialValue> GeoSpatialValues
        {
            get
            {
                GeoSpatialValue gsVal;

                using (GribValuesIterator iter = GribValuesIterator.Create(Handle, (uint) KeyFilters))
                {
                    int mVal = this.MissingValue;

                    while (iter.Next(mVal, out gsVal))
                    {
                        yield return gsVal;
                    }
                }
            }
        }

        /// <summary>
        /// Gets the message size.
        /// </summary>
        /// <value>
        /// The size.
        /// </value>
        public ulong Size
        {
            get
            {
                SizeT sz = 0;

                GribApiProxy.GribGetMessageSize(Handle, ref sz);

                return sz;
            }
        }

        /// <summary>
        /// Gets a copy of the message's buffer.
        /// </summary>
        /// <value>
        /// The buffer.
        /// </value>
        public byte[] Buffer
        {
            get
            {
                SizeT sz = 0;
                GribApiProxy.GribGetMessageSize(this.Handle, ref sz);
                // grib_api returns the data buffer pointer, but continues to own the memory, so no de/allocation is necessary 
                IntPtr p = IntPtr.Zero;
                GribApiProxy.GribGetMessage(this.Handle, out p, ref sz);

                byte[] bytes = new byte[sz];
                Marshal.Copy(p, bytes, 0, (int)sz);

                return bytes;
            }
        }

        #endregion Properties

        /// <summary>
        /// Gets the <see cref="GribValue"/> with the specified key name.
        /// </summary>
        /// <value>
        /// The <see cref="GribValue"/>.
        /// </value>
        /// <param name="keyName">Name of the key.</param>
        /// <returns></returns>
        public GribValue this[string keyName]
        {
            get { return new GribValue(Handle, keyName); }
        }
    }
}
