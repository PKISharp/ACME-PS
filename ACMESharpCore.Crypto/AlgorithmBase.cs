using System;
using System.Security.Cryptography;

namespace ACMESharpCore.Crypto
{
    public abstract class AlgorithmBase
    {
        public abstract AlgorithmKey ExportKey();
    }

    public abstract class HashedAlgorithmBase : AlgorithmBase
    {
        protected HashedAlgorithmBase(int hashSize)
        {
            HashSize = hashSize;

            switch (hashSize)
            {
                case 256:
                    HashAlgorithmName = HashAlgorithmName.SHA256;
                    break;

                case 384:
                    HashAlgorithmName = HashAlgorithmName.SHA384;
                    break;

                case 512:
                    HashAlgorithmName = HashAlgorithmName.SHA512;
                    break;

                default:
                    throw new ArgumentOutOfRangeException("Cannot set hash size");
            }
        }

        protected HashAlgorithmName HashAlgorithmName { get; private set; }
        internal int HashSize { get; private set; }
    }
}
