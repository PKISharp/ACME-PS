namespace ACMESharp.Crypto
{
    public interface IAccountKey
    {
        string JwsAlgorithmName { get; }
        object ExportPublicJwk();
        
        byte[] Sign(byte[] inputBytes);

        
    }
}
