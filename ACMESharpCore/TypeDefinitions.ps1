$interfaces = @"
public interface IAccountKey
{
    string JwsAlgorithmName();
    System.Collections.Hashtable ExportPublicJwk();
    
    byte[] Sign(byte[] inputBytes);
    byte[] Sign(string inputString);
}

public interface ICertificateKey
{
    byte[] ExportPfx(byte[] acmeCertificate, System.Security.SecureString password);
    byte[] GenerateCsr(string[] dnsNames);
}
"@

Add-Type -TypeDefinition $interfaces