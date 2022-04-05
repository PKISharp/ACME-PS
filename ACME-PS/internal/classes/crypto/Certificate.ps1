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

    # note: this returns issuers before the certs they've issued.  This is the opposite order to what's desired; but is the order that produces the correct output when combined with the X509Certificate2Collection's Export command
    static [Security.Cryptography.X509Certificates.X509Certificate2Collection] ConvertToCertificateCollection([Collections.ArrayList] $acmeCertificates) {
        $result = [Security.Cryptography.X509Certificates.X509Certificate2Collection]::new();
        # process any quick wins (i.e. where it's clear there's no dependency
        $todoCount = $acmeCertificates.Count - 1;
        for ($i = $todoCount; $i -ge 0; $i--) {
            if ([string]::IsNullOrWhitespace($acmeCertificates[$i].Issuer) -or ($acmeCertificates[$i].Subject -eq $acmeCertificates[$i].Issuer)) {
                $result.Add($acmeCertificates[$i]); #| out-null
                $acmeCertificates.RemoveAt($i);
            }
        }
        # then work through the chains, returning all certificates whose issuers aren't in the unprocessed collection
        $todoSubjects = [Collections.ArrayList]::new( ($acmeCertificates | Select-Object -ExpandProperty 'Subject') );
        while ($todoCount = $acmeCertificates.Count) {
            $circularLoop = $true;
            for ($i = ($todoCount - 1); $i -ge 0; $i--) {
                if (!$todoSubjects.Contains($acmeCertificates[$i].Issuer)) {
                    $result.Add($acmeCertificates[$i]); #| out-null
                    $todoSubjects.Remove($acmeCertificates[$i].Subject);
                    $acmeCertificates.RemoveAt($i);
                    $circularLoop = $false;
                }
            }
            if ($circularLoop) {
                throw [System.ArgumentException]::new("There appears to be a circular loop in the given certificate's dependency chain"); # I don't think this would ever occur; but maybe it's a risk for some self signed cert scenarios?
            }
        }
        return $result;
    }

    static [Security.Cryptography.X509Certificates.X509Certificate2Collection] ConvertToCertificateCollection([byte[][]] $acmeCertificates, [Security.Cryptography.AsymmetricAlgorithm] $algorithm) {
        $certs = [Collections.ArrayList]::new();
        $certs.Add([Certificate]::CreateX509WithKey($acmeCertificates[0], $algorithm));
        for($i = 1; $i -lt $acmeCertificates.Length; $i++) {
            $certs.Add([Security.Cryptography.X509Certificates.X509Certificate2]::new($acmeCertificates[$i]));
        }
        return [Certificate]::ConvertToCertificateCollection($certs);
    }

    static [byte[]] ExportPfxCertificateChain([byte[][]] $acmeCertificates, [AcmePSKey] $key, [SecureString] $password) {
        return [Certificate]::ExportPfxCertificateChain($acmeCertificates, $key.GetAlgorithm(), $password);
    }

    static [byte[]] ExportPfxCertificateChain([byte[][]] $acmeCertificates, [Security.Cryptography.AsymmetricAlgorithm] $algorithm, [securestring] $password) {

        $certificateCollection = [Certificate]::ConvertToCertificateCollection($acmeCertificates, $algorithm);

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
