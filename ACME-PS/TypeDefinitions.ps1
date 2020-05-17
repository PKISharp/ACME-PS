$interfaces = @"
public interface IKey
{
    object ExportKey();
}

public interface ISigningKey : IKey
{
    string JwsAlgorithmName();
    System.Collections.Specialized.OrderedDictionary ExportPublicJwk();

    byte[] Sign(byte[] inputBytes);
    byte[] Sign(string inputString);
}

public interface IAccountKey : ISigningKey { }

public interface ICertificateKey : ISigningKey
{
    byte[] ExportPfx(byte[] acmeCertificate, System.Security.SecureString password);
    byte[] ExportPfxChain(byte[] acmeCertificate, System.Security.SecureString password);
    byte[] GenerateCsr(string[] dnsNames, string distinguishedName);
}
"@

Add-Type -TypeDefinition $interfaces