class Certificate {
    static [Security.Cryptography.X509Certificates.X509Certificate2] CreateX509WithKey([byte[]] $acmeCertificate, [Security.Cryptography.AsymmetricAlgorithm] $algorithm) {
        $certificate = [Security.Cryptography.X509Certificates.X509Certificate2]::new($acmeCertificate);

        if($algorithm -is [Security.Cryptography.RSA]) {
            $certificate = [Security.Cryptography.X509Certificates.RSACertificateExtensions]::CopyWithPrivateKey($certificate, $algorithm);
        }
        elseif($algorithm -is [Security.Cryptography.ECDsa]) {
            $certificate = [Security.Cryptography.X509Certificates.ECDsaCertificateExtensions]::CopyWithPrivateKey($certificate, $algorithm);
        }
        else {
            throw [InvalidOperationException]::new("Cannot use $($algorithm.GetType().Name) to export pfx.");
        }

        return $certificate
    }

    static [byte[]] ExportPfxCertificate([byte[]] $acmeCertificate, [AcmePSKey] $key, [SecureString] $password) {
        return [Certificate]::ExportPfxCertificate($acmeCertificate, $key.GetAlgorithm(), $password);
    }

    static [byte[]] ExportPfxCertificate([byte[]] $acmeCertificate, [Security.Cryptography.AsymmetricAlgorithm] $algorithm, [securestring] $password) {
        $certificate = [Certificate]::CreateX509WithKey($acmeCertificate, $algorithm);

        if($password) {
            return $certificate.Export([Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $password);
        } else {
            return $certificate.Export([Security.Cryptography.X509Certificates.X509ContentType]::Pfx);
        }
    }

    static [byte[]] ExportPfxCertificateChain([byte[][]] $acmeCertificates, [AcmePSKey] $key, [SecureString] $password) {
        return [Certificate]::ExportPfxCertificateChain($acmeCertificates, $key.GetAlgorithm(), $password);
    }

    static [byte[]] ExportPfxCertificateChain([byte[][]] $acmeCertificates, [Security.Cryptography.AsymmetricAlgorithm] $algorithm, [securestring] $password) {
        $leafCertificate = [Certificate]::CreateX509WithKey($acmeCertificates[0], $algorithm);
        $certificateCollection = [Security.Cryptography.X509Certificates.X509Certificate2Collection]::new($leafCertificate);

        for($i = 1; $i -lt $acmeCertificates.Length; $i++) {
            $chainCert = [Security.Cryptography.X509Certificates.X509Certificate2]::new($acmeCertificates[$i]);
            $certificateCollection.Add($chainCert);
        }

        if($password) {
            $unprotectedPassword = [PSCredential]::new("ACME-PS", $password).GetNetworkCredential().Password;

            return $certificateCollection.Export([Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $unprotectedPassword);
        } else {
            return $certificateCollection.Export([Security.Cryptography.X509Certificates.X509ContentType]::Pfx);
        }
    }

    static [byte[]] GenerateCsr([string[]] $dnsNames, [string]$distinguishedName, [AcmePSKey] $key) {
        return [Certificate]::GenerateCsr($dnsNames, $distinguishedName, $key.GetAlgorithm(), $key.GetHashName());
    }

    static [byte[]] GenerateCsr([string[]] $dnsNames, [string]$distinguishedName,
        [Security.Cryptography.AsymmetricAlgorithm] $algorithm,
        [Security.Cryptography.HashAlgorithmName] $hashName)
    {
        if(-not $dnsNames) {
            throw [ArgumentException]::new("You need to provide at least one DNSName", "dnsNames");
        }
        if(-not $distinguishedName) {
            thtow [ArgumentException]::new("Provide a distinguishedName for the Certificate")
        }

        $sanBuilder = [Security.Cryptography.X509Certificates.SubjectAlternativeNameBuilder]::new();
        foreach ($dnsName in $dnsNames) {
            $sanBuilder.AddDnsName($dnsName);
        }

        $certDN = [X500DistinguishedName]::new($distinguishedName);

        [Security.Cryptography.X509Certificates.CertificateRequest]$certRequest = $null;

        if($algorithm -is [Security.Cryptography.RSA]) {
            $certRequest = [Security.Cryptography.X509Certificates.CertificateRequest]::new(
                    $certDN, $algorithm, $hashName, [Security.Cryptography.RSASignaturePadding]::Pkcs1);
        }
        elseif($algorithm -is [Security.Cryptography.ECDsa]) {
            $certRequest = [Security.Cryptography.X509Certificates.CertificateRequest]::new(
                $certDN, $algorithm, $hashName);

        }
        else {
            throw [InvalidOperationException]::new("Cannot use $($algorithm.GetType().Name) to create CSR.");
        }

        $certRequest.CertificateExtensions.Add($sanBuilder.Build());
        return $certRequest.CreateSigningRequest();
    }
}
