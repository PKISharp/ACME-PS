<# abstract #> 
class ECDsaKeyBase : KeyBase
{
    hidden [System.Security.Cryptography.ECDsa] $ECDsa;
    hidden [string] $CurveName

    ECDsaKeyBase([int] $hashSize) : base($hashSize)
    {
        if ($this.GetType() -eq [KeyBase]) {
            throw [System.InvalidOperationException]::new("Class must be inherited");
        }

        $this.CurveName = "P-$hashSize";

        [System.Security.Cryptography.ECCurve] $curve = $null;
        switch ($hashSize) {
            256 { $curve = [System.Security.Cryptography.ECCurve+NamedCurves]::nistP256; }
            384 { $curve = [System.Security.Cryptography.ECCurve+NamedCurves]::nistP384; }
            512 { $curve = [System.Security.Cryptography.ECCurve+NamedCurves]::nistP521; }
            Default { throw [System.ArgumentOutOfRangeException]::new("Cannot use hash size to create curve."); }
        }

        $this.ECDsa = [System.Security.Cryptography.ECDsa]::Create($curve);
    }

    ECDsaKeyBase([int] $hashSize,[System.Security.Cryptography.ECParameters] $keyParameters) 
        :base($hashSize)
    {
        if ($this.GetType() -eq [KeyBase]) {
            throw [System.InvalidOperationException]::new("Class must be inherited");
        }
        
        $this.CurveName = "P-$hashSize";
        $this.ECDsa = [System.Security.Cryptography.ECDsa]::Create($keyParameters);
    }

    [ECDsaKeyExport] ExportKey() {
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

    [hashtable] ExportPublicJwk() {
        $keyParams = $this.ECDsa.ExportParameters($false);
        
        <# 
            As per RFC 7638 Section 3, these are the *required* elements of the
            JWK and are sorted in lexicographic order to produce a canonical form 
        #>
        $publicJwk = @{
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
}

class ECDsaCertificateKey : ECDsaKeyBase, ICertificateKey {
    ECDsaCertificateKey([int] $hashSize) : base($hashSize) { }
    ECDsaCertificateKey([int] $hashSize, [System.Security.Cryptography.ECParameters] $keyParameters) : base($hashSize, $keyParameters) { }

    [byte[]] ExportPfx([byte[]] $acmeCertificate, [string] $password) {
        return [Certificate]::ExportPfx($acmeCertificate, $this.ECDsa, $password);
    }

    [byte[]] GenerateCsr([string[]] $dnsNames) {
        return [Certificate]::GenerateCsr($dnsNames, $this.ECDsa, $this.HashName);
    }
}