    public interface IAccountKey
    {
        string JwsAlgorithmName();
        System.Collections.Hashtable ExportPublicJwk();
        
        byte[] Sign(byte[] inputBytes);
        byte[] Sign(string inputString);
    }
