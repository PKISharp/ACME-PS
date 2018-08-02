using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;

namespace ACMESharp.Crypto
{
    public sealed class RSAAdapter : HashedAlgorithmBase, ICertificateRequest, IJwsSigner
    {
        private static readonly int[] _allowedHashSizes = new[] { 256 };
        private static readonly int[] _allowedKeySizes = new[] { 2048, 2560, 3072, 3584, 4096 };

        internal RSA Algorithm { get; private set; }

        #region .ctors
        public RSAAdapter(int hashSize, int keySize)
            : base(hashSize)
        {
            if (!_allowedKeySizes.Contains(keySize))
                throw new ArgumentOutOfRangeException(nameof(keySize),
                    $"Expected one of {string.Join(", ", _allowedKeySizes)} as KeySize");
            
            Algorithm = RSA.Create(keySize);
            Algorithm.KeySize = keySize;
        }

        public RSAAdapter(int hashSize, RSAParameters parameters)
            : base(hashSize)
        {
            Algorithm = RSA.Create(parameters);
        }
        #endregion

        public override AlgorithmKey ExportKey()
        {
            var rsaParams = Algorithm.ExportParameters(true);
            var keys = new RSAKey
            {
                D = rsaParams.D,
                DP = rsaParams.DP,
                DQ = rsaParams.DQ,
                Exponent = rsaParams.Exponent,
                InverseQ = rsaParams.InverseQ,
                Modulus = rsaParams.Modulus,
                P = rsaParams.P,
                Q = rsaParams.Q,

                HashSize = HashSize
            };

            return keys;
        }

        #region ICertificateRequest
        public byte[] GenerateCsr(IList<string> dnsNames)
        {
            if (!dnsNames?.Any() ?? false)
                throw new ArgumentException("You need to provide at least one DNSName", nameof(dnsNames));

            var sanBuilder = new SubjectAlternativeNameBuilder();
            foreach (var n in dnsNames)
            {
                sanBuilder.AddDnsName(n);
            }
            
            var dn = new X500DistinguishedName($"CN={dnsNames[0]}");

            var csr = new CertificateRequest(dn, Algorithm, HashAlgorithmName, RSASignaturePadding.Pkcs1);
            csr.CertificateExtensions.Add(sanBuilder.Build());

            return csr.CreateSigningRequest();
        }
        #endregion

        #region IJwsSigner
        public string JwsAlgorithmName => $"RS{HashSize}";
        public object ExportPublicJwk()
        {
            var keyParams = Algorithm.ExportParameters(false);
            var jwk = new
            {
                // As per RFC 7638 Section 3, these are the *required* elements of the
                // JWK and are sorted in lexicographic order to produce a canonical form

                e = Base64.UrlEncode(keyParams.Exponent),
                kty = "RSA", // https://tools.ietf.org/html/rfc7518#section-6.3
                n = Base64.UrlEncode(keyParams.Modulus),
            };

            return jwk;
        }

        public byte[] Sign(byte[] inputBytes)
        {
            return Algorithm.SignData(inputBytes, HashAlgorithmName, RSASignaturePadding.Pkcs1);
        }
        #endregion

        #region Factory-Method
        public static RSAAdapter Create(RSAKey keyParameters)
        {
            var parameters = new RSAParameters
            {
                D = keyParameters.D,
                DP = keyParameters.DP,
                DQ = keyParameters.DQ,
                Exponent = keyParameters.Exponent,
                InverseQ = keyParameters.InverseQ,
                Modulus = keyParameters.Modulus,
                P = keyParameters.P,
                Q = keyParameters.Q
            };

            var rsa = new RSAAdapter(keyParameters.HashSize, parameters);
            return rsa;
        }
        #endregion
    }
}
