using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;

namespace ACMESharp.Crypto
{
    public sealed class ECDsaAdapter : HashedAlgorithmBase, ICertificateRequest, IAccountKey
    {
        private static readonly int[] _allowedHashSizes = new [] { 256, 384, 512 };

        internal ECDsa Algorithm { get; private set; }
        private string _curveName;

        #region .ctors
        public ECDsaAdapter(int hashSize)
            :base(hashSize)
        {
            _curveName = $"P-{HashSize}";

            ECCurve? curve = null;
            switch(hashSize)
            {
                case 256:
                    curve = ECCurve.NamedCurves.nistP256;
                    break;
                case 384:
                    curve = ECCurve.NamedCurves.nistP384;
                    break;
                case 512:
                    curve = ECCurve.NamedCurves.nistP521;
                    break;
            }
            
            Algorithm = ECDsa.Create(curve.Value);
        }

        public ECDsaAdapter(int hashSize, ECParameters parameters)
            :base(hashSize)
        {
            _curveName = $"P-{HashSize}";
            Algorithm = ECDsa.Create(parameters);
        }
        #endregion

        public override AlgorithmKey ExportKey()
        {
            var ecParams = Algorithm.ExportParameters(true);
            var keys = new ECDsaKey
            {
                D = ecParams.D,
                X = ecParams.Q.X,
                Y = ecParams.Q.Y,

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

            var csr = new CertificateRequest(dn, Algorithm, HashAlgorithmName);
            csr.CertificateExtensions.Add(sanBuilder.Build());

            return csr.CreateSigningRequest();
        }
        #endregion

        #region IAccountKey
        public string JwsAlgorithmName => $"ES{HashSize}";
        public object ExportPublicJwk()
        {
            var keyParams = Algorithm.ExportParameters(false);
            var jwk = new
            {
                // As per RFC 7638 Section 3, these are the *required* elements of the
                // JWK and are sorted in lexicographic order to produce a canonical form

                crv = _curveName,
                kty = "EC", // https://tools.ietf.org/html/rfc7518#section-6.2
                x = Base64.UrlEncode(keyParams.Q.X),
                y = Base64.UrlEncode(keyParams.Q.Y),
            };

            return jwk;
        }

        public byte[] Sign(byte[] inputBytes)
        {
            return Algorithm.SignData(inputBytes, HashAlgorithmName);
        }
        #endregion

        #region Factory-Method
        public static ECDsaAdapter Create(ECDsaKey keyParameters)
        {
            var parameters = new ECParameters
            {
                D = keyParameters.D,
                Q = new ECPoint
                {
                    X = keyParameters.X,
                    Y = keyParameters.Y
                }
            };
            
            var ecdsa = new ECDsaAdapter(keyParameters.HashSize, parameters);
            return ecdsa;
        }
        #endregion
    }
}
