using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Grib.Api.Interop;
using System.Runtime.InteropServices;

namespace Grib.Api
{
    public class GribStream: IEnumerable<GribMessage>, IDisposable
    {
        static readonly byte[] GRIB_MSG_START = { 0x47, 0x52, 0x49, 0x42 };
        static readonly byte[] GRIB_MSG_END_GTS = { 0x0D, 0x0D, 0x0A, 0x03 };
        static readonly byte[] GRIB_MSG_END = { 0x37, 0x37, 0x37, 0x37 };

        protected byte[] Buffer;
        protected Stream Stream;

        public GribStream (Stream stream)
        {
            this.Stream = stream;
            //var len = (int)stream.Length;
            //this.Buffer = new byte[len];
            //stream.Read(this.Buffer, 0, len);

            //var msg = GribMessage.Create(buff, GribContext.Default);
            //foreach (var k in msg)
            //{
            //    Console.WriteLine(k.Key);
            //}
        }

        //public IEnumerator<GribMessage> GetEnumerator ()
        //{
        //    GribMessage msg;
        //    int i = 0;

        //}

        public GribMessage GetNextMessage (int index)
        {
            // the starting position of the stream
            var streamStartPos = this.Stream.Position;
            // if there are headers in the file, the message may not align with the beginning of the stream
            // or the end of the previous message.
            long msgOffset = 0;

            byte[] buffer64 = new byte[8];
            byte[] buffer32 = new byte[4];
            byte[] buffer24 = new byte[3];

            /*
            GRIB Message Octets Content (0 indexed)
            0-3    'GRIB' (Coded CCITT-ITA No. 5) (ASCII);
            4-6	    GRIB1: Total length of GRIB message (including Section 0)
            7       Edition number
            8-15    GRIB2: Total length of GRIB message(including Sections 0 & 5);
            */

            bool foundStart = false;

            while (this.Stream.Position + 1 < this.Stream.Length && !foundStart)
            {
                msgOffset = this.Stream.Position;

                if (this.Stream.ReadByte() == GRIB_MSG_START[0])
                {
                    this.Stream.Seek(-1, SeekOrigin.Current);
                    this.Stream.Read(buffer32, 0, 4);

                    if (buffer32.SequenceEqual(GRIB_MSG_START))
                    {
                        foundStart = true;
                    }
                    else
                    {
                        this.Stream.Seek(msgOffset + 1, SeekOrigin.Begin);
                    }
                }
            }

            if (!foundStart) { return null; }

            // at this point, the stream should be pointing to the "B" octet in the "GRIB" sequence
            // if this is an edition 1, the next 3 bytes are the length of the message
            this.Stream.Read(buffer24, 0, 3);

            // get the edition number and read the message length per ed spec
            var ed = this.Stream.ReadByte();

            if (ed == 0)
            {
                throw GribApiException.Create(-12);
            }
            else if (ed == 1)
            {
                buffer32.Initialize();
                Array.Copy(buffer24, 0, buffer64, 5, 3);
            }
            else if (ed == 2)
            {
                this.Stream.Read(buffer64, 0, 8);
            }

            if (BitConverter.IsLittleEndian)
            {
                Array.Reverse(buffer64);
            }

            long msgLen = BitConverter.ToInt64(buffer64, 0);
            long end = msgLen + streamStartPos;
            // get the length of the message, including any headers
            long totalLen = (msgOffset - streamStartPos) + msgLen;

            this.Stream.Seek(streamStartPos, SeekOrigin.Begin);
            byte[] msgBytes = new byte[totalLen];
            this.Stream.Read(msgBytes, 0, (int)totalLen);

            return GribMessage.Create(msgBytes, index, GribContext.Default);

        }

        /// <summary>
        /// Resets the underlying file pointer to the beginning of the file.
        /// </summary>
        public void Rewind ()
        {
            this.Stream.Seek(0, SeekOrigin.Begin);
            //foreach (var b in buffers)
            //{
            //    Console.WriteLine("oi");
            //    Marshal.FreeCoTaskMem(b);
            //}
            //buffers.Clear();
        }

        /// <summary>
        /// NOT IMPLEMENTED.
        /// </summary>
        /// <returns>
        /// An <see cref="T:System.Collections.IEnumerator" /> object that can be used to iterate through the collection.
        /// </returns>
        /// <exception cref="System.NotImplementedException"></exception>
        IEnumerator IEnumerable.GetEnumerator ()
        {
            throw new NotImplementedException();
        }

        private List<IntPtr> buffers = new List<IntPtr>();

        public IEnumerator<GribMessage> GetEnumerator ()
        {
            GribMessage msg;
            int i = 0;

            while ((msg = this.GetNextMessage(i++)) != null)
            {
                buffers.Add(msg.NativeBuffer);
                yield return msg;
            }

            this.Rewind();
        }

        #region IDisposable Support
        private bool disposedValue = false; // To detect redundant calls

        public Action OnDispose;

        protected virtual void Dispose (bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    // TODO: dispose managed state (managed objects).
                }

                //foreach(var b in buffers)
                //{
                //    Console.WriteLine("oi");
                //    Marshal.FreeHGlobal(b);
                //}
               // buffers.Clear();                // TODO: free unmanaged resources (unmanaged objects) and override a finalizer below.
                // TODO: set large fields to null.

                disposedValue = true;
            }
        }

        // TODO: override a finalizer only if Dispose(bool disposing) above has code to free unmanaged resources.
        // ~GribStream() {
        //   // Do not change this code. Put cleanup code in Dispose(bool disposing) above.
        //   Dispose(false);
        // }

        // This code added to correctly implement the disposable pattern.
        public void Dispose ()
        {
            // Do not change this code. Put cleanup code in Dispose(bool disposing) above.
            Dispose(true);
            // TODO: uncomment the following line if the finalizer is overridden above.
            // GC.SuppressFinalize(this);
        }
        #endregion
    }
}
