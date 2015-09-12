using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace Grib.Api.Interop
{
    public abstract class AutoCleanup
    {
           // some fields that require cleanup
    private bool disposed = false; // to detect redundant calls

    public AutoCleanup()
    {
       // SafeHandle.
    }

    ~AutoCleanup ()
    {
        Dispose(false);
    }

    protected virtual void Dispose(bool disposing)
    {
        if (!disposed)
        {
            if (disposing)
            {
                OnDispose();
            }

            // shared cleanup logic
            disposed = true;
        }
    }

        protected virtual void OnDispose ()
        {

        }

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }
    }
}
