using System.Collections.Generic;

namespace ACMESharpCore.Crypto
{
    public interface ICertificateKey
    {
        byte[] ExportPfx(byte[] acmeCertificate, string password);

        byte[] GenerateCsr(string[] dnsNames);
    }
}
