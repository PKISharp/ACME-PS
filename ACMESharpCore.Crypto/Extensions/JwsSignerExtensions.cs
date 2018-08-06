using Newtonsoft.Json;
using System.Security.Cryptography;
using System.Text;

namespace ACMESharp.Crypto.Extensions
{
    public static class JwsSignerExtensions
    {
        /// <summary>
        /// Computes a thumbprint of the JWK using the argument Hash Algorithm
        /// as per <see href="https://tools.ietf.org/html/rfc7638">RFC 7638</see>,
        /// JSON Web Key (JWK) Thumbprint.
        /// </summary>
        public static byte[] ComputeThumbprint(this IAccountKey jwsSigner, HashAlgorithm hashAlgorithm)
        {
            // As per RFC 7638 Section 3, we export the JWK in a canonical form
            // and then produce a JSON object with no whitespace or line breaks

            var publicJwk = jwsSigner.ExportPublicJwk();
            var jwkJson = JsonConvert.SerializeObject(publicJwk, Formatting.None);
            var jwkBytes = Encoding.UTF8.GetBytes(jwkJson);
            var jwkHash = hashAlgorithm.ComputeHash(jwkBytes);

            return jwkHash;
        }

        /// <summary>
        /// Computes the ACME Key Authorization of the JSON Web Key (JWK) of an argument
        /// Signer as prescribed in the
        /// <see href="https://tools.ietf.org/html/draft-ietf-acme-acme-01#section-7.1"
        /// >ACME specification, section 7.1</see>.
        /// </summary>
        public static string ComputeKeyAuthorization(this IAccountKey signer, string token)
        {
            using (var sha = SHA256.Create())
            {
                var jwkThumb = Base64.UrlEncode(ComputeThumbprint(signer, sha));
                return $"{token}.{jwkThumb}";
            }
        }

        /// <summary>
        /// Computes a SHA256 digest over the <see cref="ComputeKeyAuthorization">
        /// ACME Key Authorization</see> as required by some of the ACME Challenge
        /// responses.
        /// </summary>
        public static string ComputeKeyAuthorizationDigest(this IAccountKey signer, string token)
        {
            using (var sha = SHA256.Create())
            {
                var jwkThumb = Base64.UrlEncode(ComputeThumbprint(signer, sha));
                var keyAuthz = $"{token}.{jwkThumb}";
                var keyAuthzDig = sha.ComputeHash(Encoding.UTF8.GetBytes(keyAuthz));
                return Base64.UrlEncode(keyAuthzDig);
            }
        }
    }
}
