class AcmePSKey {
    hidden [string] $_AlgorithmType;
    hidden [Security.Cryptography.AsymmetricAlgorithm] $_Algorithm;

    hidden [int] $_HashSize;
    hidden [Security.Cryptography.HashAlgorithmName] $_HashName;

    [string] $KeyId;

    AcmePSKey([Security.Cryptography.AsymmetricAlgorithm] $algorithm)
    {
        $this.Initialize($algorithm, 256);
    }

    AcmePSKey([Security.Cryptography.AsymmetricAlgorithm] $algorithm, [int] $hashSize)
    {
        $this.Initialize($algorithm, $hashSize);
    }

    AcmePSKey([PSCustomObject]$keySource) {
        $algo = $null;
        $hashSize = $keySource.HashSize;

        if($keySource.TypeName -iin @("RSA","RSAKeyExport")) {
            $keyParameters = [System.Security.Cryptography.RSAParameters]::new();

            $keyParameters.D = $keySource.D;
            $keyParameters.DP = $keySource.DP;
            $keyParameters.DQ = $keySource.DQ;
            $keyParameters.Exponent = $keySource.Exponent;
            $keyParameters.InverseQ = $keySource.InverseQ;
            $keyParameters.Modulus = $keySource.Modulus;
            $keyParameters.P = $keySource.P;
            $keyParameters.Q = $keySource.Q;

            $algo = [Security.Cryptography.RSA]::Create($keyParameters);
        }
        elseif($keySource.TypeName -iin @("ECDsa","ECDsaKeyExport")) {
            $keyParameters = [System.Security.Cryptography.ECParameters]::new();

            $keyParameters.Curve = [AcmePSKey]::GetECDsaCurve($hashSize);
            $keyParameters.D = $keySource.D;
            $keyParameters.Q.X = $keySource.X;
            $keyParameters.Q.Y = $keySource.Y;

            $algo = [Security.Cryptography.ECDsa]::Create($keyParameters);
        }
        else {
            throw "Unkown Key Export type '$($keySource.TypeName)'";
        }

        $this.Initialize($algo, $hashSize);
    }

    hidden Initialize([Security.Cryptography.AsymmetricAlgorithm] $algorithm, [int] $hashSize) {
        $this._HashSize = $hashSize;
        $this._HashName = [AcmePSKey]::GetHashName($hashSize);

        $this._Algorithm = $algorithm;

        if($this._Algorithm -is [Security.Cryptography.ECDsa]) {
            $this._AlgorithmType = "ECDsa";
        }
        elseif($this._Algorithm -is [Security.Cryptography.RSA]) {
            $this._AlgorithmType = "RSA";
        }
        else {
            throw "Unsupported Algorithm Type";
        }
    }

    hidden ThrowBadType() {
        throw "Algorithm Type was not in (RSA, ECDsa) but was $($this._AlgorithmType)";
    }

    hidden static [Security.Cryptography.HashAlgorithmName] GetHashName($hashSize) {
        switch ($hashSize) {
            256 { return "SHA256";  }
            384 { return "SHA384";  }
            512 { return "SHA512";  }
        }

        throw "Cannot use hash size to get hash name. Allowed sizes: 256, 348, 512";
    }

    static [Security.Cryptography.ECCurve] GetECDsaCurve($hashSize) {
        switch ($hashSize) {
            256 { return [System.Security.Cryptography.ECCurve+NamedCurves]::nistP256; }
            384 { return [System.Security.Cryptography.ECCurve+NamedCurves]::nistP384; }
            512 { return [System.Security.Cryptography.ECCurve+NamedCurves]::nistP521; }
        }

        throw "Cannot use hash size to create curve. Allowed sizes: 256, 348, 512";
    }

    [Security.Cryptography.AsymmetricAlgorithm] GetAlgorithm() {
        return $this._Algorithm;
    }

    [Security.Cryptography.HashAlgorithmName] GetHashName() {
        return $this._HashName;
    }

    [PSCustomObject] ExportKey() {
        $keyExport = @{
            TypeName = $this._AlgorithmType;
            HashSize = $this._HashSize;
        };

        $keyParameters = $this._Algorithm.ExportParameters($true);
        if($this._AlgorithmType -eq "ECDsa")
        {
            $keyExport.D = $keyParameters.D;
            $keyExport.X = $keyParameters.Q.X;
            $keyExport.Y = $keyParameters.Q.Y;
        }
        elseif($this._AlgorithmType -eq "RSA")
        {
            $keyExport.D = $keyParameters.D;
            $keyExport.DP = $keyParameters.DP;
            $keyExport.DQ = $keyParameters.DQ;
            $keyExport.Exponent = $keyParameters.Exponent;
            $keyExport.InverseQ = $keyParameters.InverseQ;
            $keyExport.Modulus = $keyParameters.Modulus;
            $keyExport.P = $keyParameters.P;
            $keyExport.Q = $keyParameters.Q;
        }

        return [PSCustomObject]$keyExport;
    }

    <#
        JWS and JWK
    #>

    [string] JwsAlgorithmName() {
        if($this._AlgorithmType -eq "RSA") { return "RS$($this._HashSize)"; }
        if($this._AlgorithmType -eq "ECDsa") { return "ES$($this._HashSize)"; }

        return $this.ThrowBadType();
    }

    [System.Collections.Specialized.OrderedDictionary] ExportPublicJwk() {
        <#
            As per RFC 7638 Section 3, these are the *required* elements of the
            JWK and are sorted in lexicographic order to produce a canonical form
        #>

        $keyParams = $this._Algorithm.ExportParameters($false);

        if($this._AlgorithmType -eq "ECDsa") {
            $result = [ordered]@{
                "crv" = "P-$($this._HashSize)";
                "kty" = "EC"; # https://tools.ietf.org/html/rfc7518#section-6.2
                "x" = ConvertTo-UrlBase64 -InputBytes $keyParams.Q.X;
                "y" = ConvertTo-UrlBase64 -InputBytes $keyParams.Q.Y;
            }
        }
        elseif ($this._AlgorithmType -eq "RSA") {
            $result = [ordered]@{
                "e" = ConvertTo-UrlBase64 -InputBytes $keyParams.Exponent;
                "kty" = "RSA"; # https://tools.ietf.org/html/rfc7518#section-6.3
                "n" = ConvertTo-UrlBase64 -InputBytes $keyParams.Modulus;
            }
        }
        else {
            $result = $null;
            $this.ThrowBadType();
        }

        return $result;
    }

    <#
        Signing
    #>

    [byte[]] Sign([byte[]] $inputBytes)
    {
        if($this._AlgorithmType -eq "ECDsa") {
            $result = $this._Algorithm.SignData($inputBytes, $this._HashName);
        }
        elseif ($this._AlgorithmType -eq "RSA") {
            $result = $this._Algorithm.SignData($inputBytes, $this._HashName, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1);
        }
        else {
            $result = $null;
            $this.ThrowBadType();
        }

        return $result;
    }

    [byte[]] Sign([string] $inputString)
    {
        return $this.Sign([System.Text.Encoding]::UTF8.GetBytes($inputString));
    }


    <#
        Key authorization
    #>
    hidden [string] GetKeyAuthorizationThumbprint([string] $token, [System.Security.Cryptography.HashAlgorithm] $hashAlgorithm)
    {
        $jwkJson = $this.ExportPublicJwk() | ConvertTo-Json -Compress;
        $jwkBytes = [System.Text.Encoding]::UTF8.GetBytes($jwkJson);
        $jwkHash = $hashAlgorithm.ComputeHash($jwkBytes);

        $thumbprint = ConvertTo-UrlBase64 -InputBytes $jwkHash;
        return "$token.$thumbprint";
    }

    [string] GetKeyAuthorization([string] $token)
    {
        $sha256 = [System.Security.Cryptography.SHA256]::Create();

        try {
            return $this.GetKeyAuthorizationThumbprint($token, $sha256);
        } finally {
            $sha256.Dispose();
        }
    }

    [string] GetKeyAuthorizationDigest([string] $token)
    {
        $sha256 = [System.Security.Cryptography.SHA256]::Create();

        try {
            $keyAuthorization = $this.GetKeyAuthorizationThumbprint($token, $sha256);
            $keyAuthZBytes = [System.Text.Encoding]::UTF8.GetBytes($keyAuthorization);

            $digest = $sha256.ComputeHash($keyAuthZBytes);
            return ConvertTo-UrlBase64 -InputBytes $digest;
        } finally {
            $sha256.Dispose();
        }
    }
}