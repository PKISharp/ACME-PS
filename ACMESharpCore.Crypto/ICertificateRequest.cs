using System.Collections.Generic;

namespace ACMESharp.Crypto
{
    public interface ICertificateRequest
    {
        byte[] GenerateCsr(IList<string> dnsNames);
    }
}
