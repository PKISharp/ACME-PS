using System.Collections.Generic;

namespace ACMESharpCore.Crypto
{
    public interface ICertificateKey
    {
        

        byte[] GenerateCsr(IList<string> dnsNames);
    }
}
