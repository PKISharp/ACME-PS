namespace ACMESharp.Crypto
{
    public interface IJwsSigner
    {
        string JwsAlgorithmName { get; }
        object ExportPublicJwk();
        
        byte[] Sign(byte[] inputBytes);

        
    }
}
