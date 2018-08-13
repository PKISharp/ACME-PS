<# $interfaces = @"
public class Interfaces {
    public interface IAccountKey
    {
        string JwsAlgorithmName();
        System.Collections.Hashtable ExportPublicJwk();

        byte[] Sign(byte[] inputBytes);
        byte[] Sign(string inputString);
    }

    public interface ICertificateKey
    {
        byte[] ExportPfx(byte[] acmeCertificate, string password);

        byte[] GenerateCsr(string[] dnsNames);
    }
}
"@;

Add-Type -TypeDefinition $interfaces -Language CSharp;
#>