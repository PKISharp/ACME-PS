    public interface IAccountKey
    {
        string JwsAlgorithmName { get; }
        object ExportPublicJwk();
        
        byte[] Sign(byte[] inputBytes);
        byte[] Sign(string inputString);
    }
