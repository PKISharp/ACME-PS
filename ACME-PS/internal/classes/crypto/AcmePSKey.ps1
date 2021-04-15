class AcmePSKey {
    hidden [string] $_AlgorithmType;
    hidden [Security.Cryptography.AsymmetricAlgorithm] $_Algorithm;
    
    hidden [int] $_HashSize;
    hidden [System.Security.Cryptography.HashAlgorithmName] $_HashName;

    AcmePSKey([Security.Cryptography.AsymmetricAlgorithm] $algorithm)
    {
        Initialize($algorithm, 256);
    }

    AcmePSKey([Security.Cryptography.AsymmetricAlgorithm] $algorithm, [int] $hashSize) 
    {
        Initialize($algorithm, $hashSize);
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

            $keyParameters.Curve = GetECDsaCurve($hashSize);
            $keyParameters.D = $keySource.D;
            $keyParameters.Q.X = $keySource.X;
            $keyParameters.Q.Y = $keySource.Y;

            $algo = [Security.Cryptography.ECDsa]::Create($keyParameters);
        }
        else {
            throw "Unkown Key Export type '$($keySource.TypeName)'";
        }

        Initialize($algo, $hashSize);
    }

    hidden Initialize([Security.Cryptography.AsymmetricAlgorithm] $algorithm, [int] $hashSize) {
        $this._HashSize = $hashSize;
        $this._HashName = $this.GetHashName($hashSize);

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

    hidden static [Security.Cryptography.ECCurve] GetECDsaCurve($hashSize) {
        switch ($hashSize) {
            256 { return [System.Security.Cryptography.ECCurve+NamedCurves]::nistP256; }
            384 { return [System.Security.Cryptography.ECCurve+NamedCurves]::nistP384; }
            512 { return [System.Security.Cryptography.ECCurve+NamedCurves]::nistP521; }
        }

        throw "Cannot use hash size to create curve. Allowed sizes: 256, 348, 512";
    }

    [object] ExportKey() {
        $keyExport = @{
            TypeName = $this._AlgorithmType;
            HashSize = $this._HashSize;
        };

        if($this._AlgorithmType -eq "ECDsa") {
            $ecParams = $this.ECDsa.ExportParameters($true);
            
            $keyExport.D = $ecParams.D;
            $keyExport.X = $ecParams.Q.X;
            $keyExport.Y = $ecParams.Q.Y;
        }
        elseif($this._AlgorithmType -eq "RSA") {
            $rsaParams = $this.RSA.ExportParameters($true);
            
            $keyExport.D = $rsaParams.D;
            $keyExport.DP = $rsaParams.DP;
            $keyExport.DQ = $rsaParams.DQ;
            $keyExport.Exponent = $rsaParams.Exponent;
            $keyExport.InverseQ = $rsaParams.InverseQ;
            $keyExport.Modulus = $rsaParams.Modulus;
            $keyExport.P = $rsaParams.P;
            $keyExport.Q = $rsaParams.Q;
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
        
        if($this._AlgorithmType -eq "ECDsa") {
            $keyParams = $this.ECDsa.ExportParameters($false);

            $result = [ordered]@{
                "crv" = "P-$($this._HashSize)";
                "kty" = "EC"; # https://tools.ietf.org/html/rfc7518#section-6.2
                "x" = ConvertTo-UrlBase64 -InputBytes $keyParams.Q.X;
                "y" = ConvertTo-UrlBase64 -InputBytes $keyParams.Q.Y;
            }
        }
        elseif ($this._AlgorithmType -eq "RSA") {
            $keyParams = $this.RSA.ExportParameters($false);

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
        Certificate creation
    #>

    [byte[]] ExportPfx([byte[]] $acmeCertificate, [SecureString] $password) {
        return [Certificate]::ExportPfx($acmeCertificate, $this._Algorithm, $password);
    }

    [byte[]] ExportPfxChain([byte[][]] $acmeCertificates, [SecureString] $password) {
        return [Certificate]::ExportPfxChain($acmeCertificates, $this._Algorithm, $password);
    }

    [byte[]] GenerateCsr([string[]] $dnsNames, [string] $distinguishedName) {
        return [Certificate]::GenerateCsr($dnsNames, $distinguishedName, $this._Algorithm, $this._HashName);
    }


    <#
        Key authorization
    #>

    [string] GetKeyAuthorization([string] $token)
    {
        $sha256 = [System.Security.Cryptography.SHA256]::Create();

        try {
            return GetKeyAuthorizationThumbprint($token, $sha256);
        } finally {
            $sha256.Dispose();
        }
    }

    hidden [byte[]] GetKeyAuthorizationThumbprint([string] $token, [System.Security.Cryptography.HashAlgorithm] $hashAlgorithm)
    {
        $jwkJson = $this.ExportPublicJwk() | ConvertTo-Json -Compress;
        $jwkBytes = [System.Text.Encoding]::UTF8.GetBytes($jwkJson);
        $jwkHash = $hashAlgorithm.ComputeHash($jwkBytes);

        $thumbprint =  = ConvertTo-UrlBase64 -InputBytes $jwkHash;
        return "$token.$thumbprint";
    }

    [string] GetKeyAuthorizationDigest([string] $token)
    {
        $sha256 = [System.Security.Cryptography.SHA256]::Create();

        try {
            $keyAuthorization = GetKeyAuthorizationThumbprint($token, $sha256);
            $keyAuthZBytes = [System.Text.Encoding]::UTF8.GetBytes($keyAuthorization);

            $digest = $sha256.ComputeHash($keyAuthZBytes);
            return ConvertTo-UrlBase64 -InputBytes $digest;
        } finally {
            $sha256.Dispose();
        }
    }
}