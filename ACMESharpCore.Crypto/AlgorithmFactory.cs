using System;
using System.Collections.Generic;
using System.Linq;

namespace ACMESharpCore.Crypto
{
    public static class AlgorithmFactory
    {
        public class Creator
        {
            public Type KeyType { get; }
            public Func<AlgorithmKey, AlgorithmBase> Create { get; }

            public Creator(Type keyType, Func<AlgorithmKey, AlgorithmBase> creatorFunction)
            {
                KeyType = keyType;
                Create = creatorFunction;
            }
        }

        public static List<Creator> Factories { get; } = new List<Creator>
        {
            new Creator(typeof(RSAKey), (k) => RSAAdapter.Create((RSAKey)k)),
            new Creator(typeof(ECDsaKey), (k) => ECDsaAdapter.Create((ECDsaKey)k)),
        };

        private static AlgorithmBase Create() => new RSAAdapter(256, 2048);
        private static AlgorithmBase Create(AlgorithmKey keyParameters)
        {
            var keyType = keyParameters.GetType();
            var factory = Factories.FirstOrDefault(f => f.KeyType == keyType);

            if (factory == null)
                throw new InvalidOperationException("Unknown KeyParameters-Type.");

            return factory.Create(keyParameters);
        }


        public static IAccountKey CreateAccountKey(AlgorithmKey keyParameters) => (IAccountKey)Create(keyParameters);
        public static ICertificateKey CreateCertificateKey(AlgorithmKey keyParameters) => (ICertificateKey)Create(keyParameters);
    }
}
