using System.Collections.Generic;

namespace ACMESharpCore.Crypto
{
    public interface ICertificateRequest
    {
        byte[] GenerateCsr(IList<string> dnsNames);
    }
}
