<# abstract #>
class ECDsaKeyBase : KeyBase
{
    hidden [System.Security.Cryptography.ECDsa] $ECDsa;
    hidden [string] $CurveName

    ECDsaKeyBase([int] $hashSize) : base($hashSize)
    {
        if ($this.GetType() -eq [ECDsaKeyBase]) {
            throw [System.InvalidOperationException]::new("Class must be inherited");
        }

        $this.CurveName = "P-$hashSize";
        $curve = [ECDsaKeyBase]::GetCurve($hashSize);

        $this.ECDsa = [System.Security.Cryptography.ECDsa]::Create($curve);
    }

    ECDsaKeyBase([int] $hashSize,[System.Security.Cryptography.ECParameters] $keyParameters)
        :base($hashSize)
    {
        if ($this.GetType() -eq [ECDsaKeyBase]) {
            throw [System.InvalidOperationException]::new("Class must be inherited");
        }

        $this.CurveName = "P-$hashSize";
        $this.ECDsa = [System.Security.Cryptography.ECDsa]::Create($keyParameters);
    }

    static [System.Security.Cryptography.ECCurve] GetCurve($hashSize) {
        switch ($hashSize) {
            256 { return [System.Security.Cryptography.ECCurve+NamedCurves]::nistP256; }
            384 { return [System.Security.Cryptography.ECCurve+NamedCurves]::nistP384; }
            512 { return [System.Security.Cryptography.ECCurve+NamedCurves]::nistP521; }
            Default { throw [System.ArgumentOutOfRangeException]::new("Cannot use hash size to create curve."); }
        }

        return $null;
    }

    [object] ExportKey() {
        $ecParams = $this.ECDsa.ExportParameters($true);
        $keyExport = [ECDsaKeyExport]::new();

        $keyExport.D = $ecParams.D;
        $keyExport.X = $ecParams.Q.X;
        $keyExport.Y = $ecParams.Q.Y;

        $keyExport.HashSize = $this.HashSize;

        return $keyExport;
    }
}

class ECDsaAccountKey : ECDsaKeyBase, IAccountKey {
    ECDsaAccountKey([int] $hashSize) : base($hashSize) { }
    ECDsaAccountKey([int] $hashSize, [System.Security.Cryptography.ECParameters] $keyParameters) : base($hashSize, $keyParameters) { }

    [string] JwsAlgorithmName() { return "ES$($this.HashSize)" }

    [System.Collections.Specialized.OrderedDictionary] ExportPublicJwk() {
        $keyParams = $this.ECDsa.ExportParameters($false);

        <#
            As per RFC 7638 Section 3, these are the *required* elements of the
            JWK and are sorted in lexicographic order to produce a canonical form
        #>
        $publicJwk = [ordered]@{
            "crv" = $this.CurveName;
            "kty" = "EC"; # https://tools.ietf.org/html/rfc7518#section-6.2
            "x" = ConvertTo-UrlBase64 -InputBytes $keyParams.Q.X;
            "y" = ConvertTo-UrlBase64 -InputBytes $keyParams.Q.Y;
        }

        return $publicJwk;
    }

    [byte[]] Sign([byte[]] $inputBytes)
    {
        return $this.ECDsa.SignData($inputBytes, $this.HashName);
    }

    [byte[]] Sign([string] $inputString)
    {
        return $this.Sign([System.Text.Encoding]::UTF8.GetBytes($inputString));
    }

    static [IAccountKey] Create([ECDsaKeyExport] $keyExport) {
        $keyParameters = [System.Security.Cryptography.ECParameters]::new();

        $keyParameters.Curve = [ECDsaKeyBase]::GetCurve($keyExport.HashSize);
        $keyParameters.D = $keyExport.D;
        
        $q = [System.Security.Cryptography.ECPoint]::new();
        $q.X = $keyExport.X;
        $q.Y = $keyExport.Y;
        $keyParameters.Q = $q;

        return [ECDsaAccountKey]::new($keyExport.HashSize, $keyParameters);
     }
}

class ECDsaCertificateKey : ECDsaAccountKey, ICertificateKey {
    ECDsaCertificateKey([int] $hashSize) : base($hashSize) { }
    ECDsaCertificateKey([int] $hashSize, [System.Security.Cryptography.ECParameters] $keyParameters) : base($hashSize, $keyParameters) { }

    [byte[]] ExportPfx([byte[]] $acmeCertificate, [SecureString] $password) {
        return [Certificate]::ExportPfx($acmeCertificate, $this.ECDsa, $password);
    }

    [byte[]] GenerateCsr([string[]] $dnsNames, [string] $distinguishedName) {
        return [Certificate]::GenerateCsr($dnsNames, $distinguishedName, $this.ECDsa, $this.HashName);
    }

    static [ICertificateKey] Create([ECDsaKeyExport] $keyExport) {
        $keyParameters = [System.Security.Cryptography.ECParameters]::new();

        $keyParameters.Curve = [ECDsaKeyBase]::GetCurve($keyExport.HashSize);
        $keyParameters.D = $keyExport.D;
        
        $q = [System.Security.Cryptography.ECPoint]::new();
        $q.X = $keyExport.X;
        $q.Y = $keyExport.Y;
        $keyParameters.Q = $q;

        return [ECDsaCertificateKey]::new($keyExport.HashSize, $keyParameters);
     }
}
