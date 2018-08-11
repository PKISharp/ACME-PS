class Certificate {
    static [byte[]] ExportPfx([byte[]] $acmeCertificate, [System.Security.Cryptography.AsymmetricAlgorithm] $algorithm, [string] $password = $null) {
        $certifiate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($acmeCertificate);

        switch($algorithm.GetType())
        {
            [RSA] { $certifiate = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::CopyWithPrivateKey($algorithm); }
            [ECDsa] { $certifiate = [System.Security.Cryptography.X509Certificates.ECDsaCertificateExtensions]::CopyWithPrivateKey($algorithm); }
            default { throw [System.InvalidOperationException]::new("Cannot use $($algorithm.GetType().Name) to export pfx."); }
        }
        
        if($password) {
            return $certifiate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $password);
        } else {
            return $certifiate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx);
        }
    }

    static [byte[]] GenerateCsr([string[]] $dnsNames, 
        [System.Security.Cryptography.AsymmetricAlgorithm] $algorithm, [System.Security.Cryptography.HashAlgorithmName] $hashName)
    {
        if(-not $dnsNames) {
            throw [System.ArgumentException]::new("You need to provide at least one DNSName", "dnsNames");
        }

        $sanBuilder = [System.Security.Cryptography.X509Certificates.SubjectAlternativeNameBuilder]::new();
        foreach ($dnsName in $dnsNames) {
            $sanBuilder.AddDnsName($dnsNames);
        }
        
        $distinguishedName = [X500DistinguishedName]::new("CN=$(dnsNames[0])");
        
        [System.Security.Cryptography.X509Certificates.CertificateRequest]$certRequest = $null;
        switch($algorithm.GetType())
        {
            [RSA] { 
                $certRequest = [System.Security.Cryptography.X509Certificates.CertificateRequest]::new(
                    $distinguishedName, $algorithm, $hashName, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1);
            }
            [ECDsa] { 
                $certRequest = [System.Security.Cryptography.X509Certificates.CertificateRequest]::new($distinguishedName, $algorithm, $hashName);
            }
            default { throw [System.InvalidOperationException]::new("Cannot use $($algorithm.GetType().Name) to create CSR."); }
        }
        
        $certRequest.CertificateExtensions.Add($sanBuilder.Build());
        return $certRequest.CreateSigningRequest();
    }
}