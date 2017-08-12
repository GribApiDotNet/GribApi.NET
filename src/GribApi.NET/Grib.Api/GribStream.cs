using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Grib.Api.Interop;

namespace Grib.Api
{
    public class GribStream//: IEnumerable<GribMessage>
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

        public void GetNextMessage ()
        {
            var start = this.Stream.Position;
            long offset = 0;
            byte[] buffer32 = new byte[4];
            byte[] buffer24 = new byte[3];
            bool foundStart = false;

            /*
            Octets Content
            1-4    'GRIB' (Coded CCITT-ITA No. 5) (ASCII);
            5-7	    GRIB1: Total length of GRIB message (including Section 0)
            9-16    GRIB2: Total length, in octets, of GRIB message(including Sections 0 & 5);
            */

            while (this.Stream.Position + 1 < this.Stream.Length && !foundStart)
            {
                offset = this.Stream.Position;

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
                        this.Stream.Seek(offset + 1, SeekOrigin.Begin);
                    }
                }
            }

            if (!foundStart) { return; }

            // At this point, the stream should be pointing to the "B" octet in the "GRIB" sequence

            // try to get the message length from GRIB 1
            this.Stream.Read(buffer24, 0, 3);
            buffer32.Initialize();
            Array.Copy(buffer24, 0, buffer32, 1, 3);

            if (BitConverter.IsLittleEndian)
            {
                Array.Reverse(buffer32);
            }
            var msgLen = BitConverter.ToInt32(buffer32, 0);
            var end = msgLen + start;
           
            Console.WriteLine(msgLen);

        }
        //IEnumerator IEnumerable.GetEnumerator ()
        //{
        //    throw new NotImplementedException();
        //}
    }
}
