$interfaces = @"
public interface IKey 
{
    object ExportKey();
}

public interface IAccountKey : IKey
{
    string JwsAlgorithmName();
    System.Collections.Specialized.OrderedDictionary ExportPublicJwk();

    byte[] Sign(byte[] inputBytes);
    byte[] Sign(string inputString);
}

public interface ICertificateKey : IKey
{
    byte[] ExportPfx(byte[] acmeCertificate, System.Security.SecureString password);
    byte[] GenerateCsr(string[] dnsNames);
}
"@

Add-Type -TypeDefinition $interfaces