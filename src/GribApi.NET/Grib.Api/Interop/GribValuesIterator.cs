using Grib.Api.Interop.SWIG;
using System;

namespace Grib.Api.Interop
{

    /// <summary>
    /// Wraps a grib_iterator struct.
    /// </summary>
    public class GribValuesIterator : AutoRef
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="GribValuesIterator"/> class.
        /// </summary>
        /// <param name="h">The h.</param>
        internal GribValuesIterator (IntPtr h)
            : base(h)
        {
        }

        /// <summary>
        /// Gets the next value in a series.
        /// </summary>
        /// <param name="isMissingFlag">The is missing flag.</param>
        /// <param name="gsVal">The gs value.</param>
        /// <returns>False if there are no more values.</returns>
        public bool Next (double isMissingFlag, out GeoSpatialValue gsVal)
        {
            double lat, lon, val;
            bool success = GribApiProxy.GribIteratorNext(this, out lat, out lon, out val) != 0;

            gsVal = new GeoSpatialValue(lat, lon, val, val == isMissingFlag);

            return success;
        }

		/// <summary>
		/// Rewinds this instance.
		/// </summary>
		public void Rewind ()
		{
			GribApiProxy.GribIteratorReset(this);
		}

        /// <summary>
        /// Called when [dispose].
        /// </summary>
        /// <param name="disposing"><c>true</c> to release both managed and unmanaged resources; <c>false</c> to release only unmanaged resources.</param>
        protected override void OnDispose (bool disposing)
        {
			if (this.pReference != IntPtr.Zero)
			{
				this.Rewind();
				GribApiProxy.GribIteratorDelete(this);
			}

        }

        /// <summary>
        /// Creates an instance of GribValuesIterator.
        /// </summary>
        /// <param name="h">The handle of the message to iterate.</param>
        /// <param name="filters">The filters.</param>
        /// <returns></returns>
        public static GribValuesIterator Create (GribHandle h, uint filters)
        {
            int err = 0;

            GribValuesIterator iter = GribApiProxy.GribIteratorNew(h, filters, out err);

            if (err != 0)
            {
                throw GribApiException.Create(err);
            }

            return iter;
        }
    }
}
