using System;

namespace ACMESharpCore.Crypto
{
    [Serializable]
    public class ECDsaKey : AlgorithmKey
    {
        public override string TypeName { get => this.GetType().FullName; set {} }

        public int HashSize { get; set; }

        public byte[] D { get; set; }
        public byte[] X { get; set; }
        public byte[] Y { get; set; }
    }
}
