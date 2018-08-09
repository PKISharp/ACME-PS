<# abstract #> 
class RSAKeyBase : KeyBase
{
    hidden [System.Security.Cryptography.RSA] $RSA;

    RSAKeyBase([int] $hashSize, [int] $keySize) : base($hashSize) 
    {
        if ($this.GetType() -eq [KeyBase]) {
            throw [System.InvalidOperationException]::new("Class must be inherited");
        }

        $this.RSA = [System.Security.Cryptography.RSA]::Create($keySize);
    }

    RSAKeyBase([int] $hashSize, [System.Security.Cryptography.RSAParameters] $keyParameters) 
        :base($hashSize)
    {
        if ($this.GetType() -eq [KeyBase]) {
            throw [System.InvalidOperationException]::new("Class must be inherited");
        }

        $this.RSA = [System.Security.Cryptography.RSA]::Create($keyParameters);
    }

    [RSAKeyExport] ExportKey() {
        $rsaParams = $this.RSA.ExportParameters($true);

        $keyExport = [RSAKeyExport]::new();

        $keyExport.D = $rsaParams.D;
        $keyExport.DP = $rsaParams.DP;
        $keyExport.DQ = $rsaParams.DQ;
        $keyExport.Exponent = $rsaParams.Exponent;
        $keyExport.InverseQ = $rsaParams.InverseQ;
        $keyExport.Modulus = $rsaParams.Modulus;
        $keyExport.P = $rsaParams.P;
        $keyExport.Q = $rsaParams.Q;

        $keyExport.HashSize = $this.HashSize;

        return $keyExport;
    }
}

class RSAAccountKey : RSAKeyBase {
    RSAAccountKey([int] $hashSize, [int] $keySize) : base($hashSize, $keySize) { } 
    RSAAccountKey([int] $hashSize, [System.Security.Cryptography.RSAParameters] $keyParameters) : base($hashSize, $keyParameters) { }

    [string] JwsAlgorithmName() { return "RS$($this.HashSize)" }

    [hashtable] ExportPublicJwk() {
        $keyParams = $this.RSA.ExportParameters($false);
        
        <# 
            As per RFC 7638 Section 3, these are the *required* elements of the
            JWK and are sorted in lexicographic order to produce a canonical form 
        #>
        $publicJwk = @{
            "e" = ConvertTo-UrlBase64 -InputBytes $keyParams.Exponent;
            "kty" = "RSA"; # https://tools.ietf.org/html/rfc7518#section-6.3
            "n" = ConvertTo-UrlBase64 -InputBytes $keyParams.Modulus;
        }

        return $publicJwk;
    }

    [byte[]] Sign([byte[]] $inputBytes)
    {
        return $this.RSA.SignData($inputBytes, $this.HashName);
    }

    [byte[]] Sign([string] $inputString)
    {
        return $this.Sign([System.Text.Encoding]::UTF8.GetBytes($inputString));
    }
}

class RSACertificateKey : RSAKeyBase {
    RSACertificateKey([int] $hashSize, [int] $keySize) : base($hashSize, $keySize) { } 
    RSACertificateKey([int] $hashSize, [System.Security.Cryptography.RSAParameters] $keyParameters) : base($hashSize, $keyParameters) { }

    [byte[]] ExportPfx([byte[]] $acmeCertificate, [string] $password) {
        return [Certificate]::ExportPfx($acmeCertificate, $this.RSA, $password);
    }

    [byte[]] GenerateCsr([string[]] $dnsNames) {
        return [Certificate]::GenerateCsr($dnsNames, $this.RSA, $this.HashName);
    }
}