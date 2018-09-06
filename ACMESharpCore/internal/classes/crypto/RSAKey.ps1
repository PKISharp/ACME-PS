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

    [object] ExportKey() {
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

class RSAAccountKey : RSAKeyBase, IAccountKey {
    RSAAccountKey([int] $hashSize, [int] $keySize) : base($hashSize, $keySize) { }
    RSAAccountKey([int] $hashSize, [System.Security.Cryptography.RSAParameters] $keyParameters) : base($hashSize, $keyParameters) { }

    [string] JwsAlgorithmName() { return "RS$($this.HashSize)" }

    [System.Collections.Specialized.OrderedDictionary] ExportPublicJwk() {
        $keyParams = $this.RSA.ExportParameters($false);

        <#
            As per RFC 7638 Section 3, these are the *required* elements of the
            JWK and are sorted in lexicographic order to produce a canonical form
        #>
        $publicJwk = [ordered]@{
            "e" = ConvertTo-UrlBase64 -InputBytes $keyParams.Exponent;
            "kty" = "RSA"; # https://tools.ietf.org/html/rfc7518#section-6.3
            "n" = ConvertTo-UrlBase64 -InputBytes $keyParams.Modulus;
        }

        return $publicJwk;
    }

    [byte[]] Sign([byte[]] $inputBytes)
    {
        return $this.RSA.SignData($inputBytes, $this.HashName, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1);
    }

    [byte[]] Sign([string] $inputString)
    {
        return $this.Sign([System.Text.Encoding]::UTF8.GetBytes($inputString));
    }

    static [IAccountKey] Create([RSAKeyExport] $keyExport) {
       $keyParameters = [System.Security.Cryptography.RSAParameters]::new();

       $keyParameters.D = $keyExport.D;
       $keyParameters.DP = $keyExport.DP;
       $keyParameters.DQ = $keyExport.DQ;
       $keyParameters.Exponent = $keyExport.Exponent;
       $keyParameters.InverseQ = $keyExport.InverseQ;
       $keyParameters.Modulus = $keyExport.Modulus;
       $keyParameters.P = $keyExport.P;
       $keyParameters.Q = $keyExport.Q;

       return [RSAAccountKey]::new($keyExport.HashSize, $keyParameters);
    }
}

class RSACertificateKey : RSAKeyBase, ICertificateKey {
    RSACertificateKey([int] $hashSize, [int] $keySize) : base($hashSize, $keySize) { }
    RSACertificateKey([int] $hashSize, [System.Security.Cryptography.RSAParameters] $keyParameters) : base($hashSize, $keyParameters) { }

    [byte[]] ExportPfx([byte[]] $acmeCertificate, [SecureString] $password) {
        return [Certificate]::ExportPfx($acmeCertificate, $this.RSA, $password);
    }

    [byte[]] GenerateCsr([string[]] $dnsNames) {
        return [Certificate]::GenerateCsr($dnsNames, $this.RSA, $this.HashName);
    }

    static [ICertificateKey] Create([RSAKeyExport] $keyExport) {
        $keyParameters = [System.Security.Cryptography.RSAParameters]::new();

        $keyParameters.D = $keyExport.D;
        $keyParameters.DP = $keyExport.DP;
        $keyParameters.DQ = $keyExport.DQ;
        $keyParameters.Exponent = $keyExport.Exponent;
        $keyParameters.InverseQ = $keyExport.InverseQ;
        $keyParameters.Modulus = $keyExport.Modulus;
        $keyParameters.P = $keyExport.P;
        $keyParameters.Q = $keyExport.Q;

        return [RSACertificateKey]::new($keyExport.HashSize, $keyParameters);
     }
}