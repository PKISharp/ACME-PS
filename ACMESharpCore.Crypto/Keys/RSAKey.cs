using System;

namespace ACMESharpCore.Crypto
{
    [Serializable]
    public class RSAKey : AlgorithmKey
    {
        public override string TypeName { get => this.GetType().FullName; set {} }

        public int HashSize { get; set; }

        public byte[] Modulus { get; set; }
        public byte[] Exponent { get; set; }
        public byte[] P { get; set; }
        public byte[] Q { get; set; }
        public byte[] DP { get; set; }
        public byte[] DQ { get; set; }
        public byte[] InverseQ { get; set; }
        public byte[] D { get; set; }
    }
}
