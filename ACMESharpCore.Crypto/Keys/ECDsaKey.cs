namespace ACMESharp.Crypto
{
    public class ECDsaKey : AlgorithmKey
    {
        public int HashSize { get; set; }

        public byte[] D { get; set; }
        public byte[] X { get; set; }
        public byte[] Y { get; set; }
    }
}
