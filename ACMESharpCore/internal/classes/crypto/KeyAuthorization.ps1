class KeyAuthorization {
    static [byte[]] ComputeThumbprint([hashtable] $jwkPublicKey, [System.Security.Cryptography.HashAlgorithm] $hashAlgorithm)
    {
        $jwkJson = $jwkPublicKey | ConvertTo-Json -Compress;
        $jwkBytes = [System.Text.Encoding]::UTF8.GetBytes($jwkJson);
        $jwkHash = $hashAlgorithm.ComputeHash($jwkBytes);;

        return $jwkHash;
    }

    
    static [string] Compute([hashtable] $jwkPublicKey, [string] $token)
    {
        $sha256 = [System.Security.Cryptography.SHA256]::Create();

        try {
            $thumbprint = ConvertTo-UrlBase64 -InputBytes [KeyAuthorization]::ComputeThumbprint($jwkPublicKey)
            return "$token.$thumbprint";
        } finally {
            $sha256.Dispose();
        }
    }

    static [string] ComputeKeyAuthorizationDigest([hashtable] $jwkPublicKey, [string] $token)
    {
        $sha256 = [System.Security.Cryptography.SHA256]::Create();

        try {
            $thumbprint = ConvertTo-UrlBase64 -InputBytes [KeyAuthorization]::ComputeThumbprint($jwkPublicKey)
            $keyAuthZBytes = [System.Text.Encoding]::UTF8.GetBytes("$token.$thumbprint");

            $digest = $sha256.ComputeHash($keyAuthZBytes);
            return ConvertTo-UrlBase64 -InputBytes $digest;
        } finally {
            $sha256.Dispose();
        }
    }
}