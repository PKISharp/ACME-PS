using System.Collections.Generic;

    public interface ICertificateKey
    {
        byte[] ExportPfx(byte[] acmeCertificate, string password);

        byte[] GenerateCsr(string[] dnsNames);
    }
