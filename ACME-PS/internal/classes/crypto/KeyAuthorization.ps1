class KeyAuthorization {
    static hidden [byte[]] ComputeThumbprint([IAccountKey] $accountKey, [System.Security.Cryptography.HashAlgorithm] $hashAlgorithm)
    {
        $jwkJson = $accountKey.ExportPublicJwk() | ConvertTo-Json -Compress;
        $jwkBytes = [System.Text.Encoding]::UTF8.GetBytes($jwkJson);
        $jwkHash = $hashAlgorithm.ComputeHash($jwkBytes);

        return $jwkHash;
    }


    static [string] Compute([IAccountKey] $accountKey, [string] $token)
    {
        $sha256 = [System.Security.Cryptography.SHA256]::Create();

        try {
            $thumbprintBytes = [KeyAuthorization]::ComputeThumbprint($accountKey, $sha256);
            $thumbprint = ConvertTo-UrlBase64 -InputBytes $thumbprintBytes;
            return "$token.$thumbprint";
        } finally {
            $sha256.Dispose();
        }
    }

    static [string] ComputeDigest([IAccountKey] $accountKey, [string] $token)
    {
        $sha256 = [System.Security.Cryptography.SHA256]::Create();

        try {
            $thumbprintBytes = [KeyAuthorization]::ComputeThumbprint($accountKey, $sha256);
            $thumbprint = ConvertTo-UrlBase64 -InputBytes $thumbprintBytes;
            $keyAuthZBytes = [System.Text.Encoding]::UTF8.GetBytes("$token.$thumbprint");

            $digest = $sha256.ComputeHash($keyAuthZBytes);
            return ConvertTo-UrlBase64 -InputBytes $digest;
        } finally {
            $sha256.Dispose();
        }
    }
}
