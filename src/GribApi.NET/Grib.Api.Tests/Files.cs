using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using Grib.Api.Interop;
using System.Text.RegularExpressions;
using System.Threading;

namespace Grib.Api.Tests
{
	[TestFixture]
	public class Files
	{
		[Test, Timeout(2000)]
		public void TestInvalidFiles()
		{
			try {
				using (GribFile file = new GribFile(Settings.BAD)) {
					file.Context.OnLog += Setup.GribContext_OnLog;

					// shouldn't get here
					Assert.IsTrue(false);
				}
			} catch (FileLoadException) { }

			try {
				using (GribFile file = new GribFile(Settings.EMPTY)) {
					file.Context.OnLog += Setup.GribContext_OnLog;

					// shouldn't get here
					Assert.IsTrue(false);
				}
			} catch (FileLoadException) { }
		}

		[Test, Timeout(2000)]
		public void TestOpenPng()
		{
			using (GribFile file = new GribFile(Settings.PNG_COMPRESSION)) {
				file.Context.OnLog += Setup.GribContext_OnLog;

				Assert.IsTrue(file.MessageCount > 0);

				var msg = file.First();
				Console.WriteLine(msg["packingType"].AsString());
				try {
					Console.WriteLine(msg["packingType"].AsString());
					Assert.IsTrue(msg["packingType"].AsString().ToLower().EndsWith("_png"));
					Assert.IsTrue(msg.ValuesCount > 0);
					Assert.IsTrue(msg.GeoSpatialValues.Any());
					int i = 0;
					foreach (var v in msg.GeoSpatialValues) {
						Assert.AreNotEqual(Double.NaN, v.Value);
						if (i++ > 1000) break;
					}
				} catch (GribApiException e) {
					Console.WriteLine(e.Message);
					Console.WriteLine(msg.ShortName);
					Console.WriteLine(msg.ToString());
					Assert.IsTrue(false);
				}
			}
		}

	//	[Test, Timeout(2000)]
		public void TestOpenComplex()
		{
			using (GribFile file = new GribFile(Settings.COMPLEX_GRID)) {
				file.Context.OnLog += Setup.GribContext_OnLog;

				Assert.IsTrue(file.MessageCount > 0);
				foreach (var msg in file) {
					Console.WriteLine(msg["packingType"].AsString());
					try {
						Assert.IsTrue(msg["packingType"].AsString().ToLower().Contains("complex"));
						Assert.IsTrue(msg.ValuesCount > 0);
						double[] vals;
						msg.Values(out vals);
						Assert.IsTrue(vals.Any());
						foreach (var v in vals) {
							Assert.AreNotEqual(Double.NaN, v);
						}
					} catch (GribApiException e) {
						Console.WriteLine(e.Message);
						Console.WriteLine(msg.ShortName);
						Console.WriteLine(msg.ToString());
						Assert.IsTrue(false);
					}
				}
			}
		}

		[Test, Timeout(2000)]
		public void TestEnumDisposal ()
		{
			using (var file1 = new GribFile(Settings.COMPLEX_GRID))
			using (var file2 = new GribFile(Settings.TIME)) {
				var msg1 = file1.First();
				var msg2 = file2.First();

				var msgEnumerator1 = msg1.GetEnumerator();
				var msgEnumerator2 = msg2.GetEnumerator();
				int i = 0;
				while (msgEnumerator1.MoveNext() && msgEnumerator2.MoveNext()) {
					i++;
					Assert.IsNotEmpty(msgEnumerator1.Current.Key);
					Assert.IsNotEmpty(msgEnumerator2.Current.Key);
				}
				Assert.IsTrue(i > 3);
			}
		}
	}
}
