function Export-Certificate {
    <#
        .SYNOPSIS
            Exports an issued certificate as pfx with private and public key.

        .DESCRIPTION
            Exports an issued certificate by downloading it from the acme service and combining it with the private key.
            The downloaded certificate will be saved with the order, to enable revocation.


        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER Order
            The order which contains the issued certificate.

        .PARAMETER UseAlternateChain
            Let's Encrypt provides certificates with alternate chains. Currently theres only one named, this switch will make it use the alternate.

        .PARAMETER CertificateKey
            The key which was used to create the orders CSR.

        .PARAMETER Path
            The path where the certificate will be saved.

        .PARAMETER Password
            The password used to secure the certificate.

        .PARAMETER ExcludeChain
            The downloaded certificate might include the full chain, this switch will exclude the chain from exported certificate.

        .PARAMETER Force
            Allows the operation to override existing a certificate.

        .PARAMETER ForceCertificateReload
            DEPRECATED - The cmdlet will always try to reload the certificate from the acme service.

        .PARAMETER DisablePEMStorage
            The downloaded public certificate will not be stored with the order.

        .PARAMETER AdditionalChainCertificates
            Certificates in this Paramter will be appended to the certificate chain during export.
            Provide in PEM form (-----BEGIN CERTIFICATE----- [CertContent] -----END CERTIFICATE-----).

        .EXAMPLE
            PS> Export-Certificate -Order $myOrder -CertficateKey $myKey -Path C:\AcmeCerts\example.com.pfx
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidOverwritingBuiltInCmdlets", "", Scope="Function", Target="*")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountExists()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [AcmeOrder]
        $Order,

        [Parameter()]
        [switch]
        $UseAlternateChain,

        [Parameter()]
        [AcmePSKey]
        $CertificateKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]
        $Path,

        [Parameter()]
        [SecureString]
        $Password,

        [Parameter()]
        [switch]
        $ExcludeChain,

        [Parameter()]
        [switch]
        $Force,

        [Parameter()]
        [Alias("SkipExistingCertificate")]
        [switch]
        $ForceCertificateReload,

        [Parameter()]
        [switch]
        $DisablePEMStorage,

        [Parameter()]
        [string[]]
        $AdditionalChainCertificates
    )

    $ErrorActionPreference = 'Stop'

    if($null -eq $CertificateKey) {
        $CertificateKey = $State.GetOrderCertificateKey($Order);

        if($null -eq $CertificateKey) {
            throw 'Need $CertificateKey to be provided or present in $Order.';
        }
    }

    if(Test-Path $Path) {
        if(!$Force) {
            throw "$Path does already exist. Use -Force to overwrite file.";
        }
    }

    $response = Invoke-SignedWebRequest -Url $Order.CertificateUrl -State $State;

    if($UseAlternateChain) {
        $alternateUrlMatch = ($response.Headers.Link | Select-String -Pattern '<(.*)>;rel="alternate"' | Select-Object -First 1);

        if($null -eq $alternateUrlMatch) {
            Write-Warning "Could not find alternate chain. Using available chain.";
        }
        else {
            $alternateUrl = $alternateUrlMatch.Matches[0].Groups[1].Value;
            $response = Invoke-SignedWebRequest -Url $alternateUrl -State $State;
        }
    }

    $certificate = $response.Content;

    if(-not $DisablePEMStorage) {
        $State.SetOrderCertificate($Order, $certificate);
    }

    if($ExcludeChain) {
        $certContent = [Certificate]::ExportPfxCertificate($certificate, $CertificateKey, $Password)
    } else {
        $pemString = [System.Text.Encoding]::UTF8.GetString($certificate);

        if($null -ne $AdditionalChainCertificates) {
            foreach($chainCert in $AdditionalChainCertificates) {
                $pemString = $pemString + "`n$chainCert";
            }
        }

        $certBoundary = "-----END CERTIFICATE-----";
        $certificates = [System.Collections.ArrayList]::new();
        foreach($pem in $pemString.Split(@($certBoundary), [System.StringSplitOptions]::RemoveEmptyEntries)) {
            if(-not $pem -or -not $pem.Trim()) { continue; }

            $certBytes = [System.Text.Encoding]::UTF8.GetBytes($pem.Trim() + "`n$certBoundary");
            $certificates.Add($certBytes) | Out-Null;
        }

        $certContent = [Certificate]::ExportPfxCertificateChain($certificates, $CertificateKey, $Password)
    }

    Set-ByteContent -Path $Path -Content $certContent;
}
