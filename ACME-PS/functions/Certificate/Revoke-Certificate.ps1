function Revoke-Certificate {
    <#
        .SYNOPSIS
            Revokes the certificate associated with the order.

        .DESCRIPTION
            Revokes the certificate associated with the order. This cmdlet needs the account key.
            ACME supports revoking the certificate via the certificate private key - currently this module
            does not support that way to revoke the certificate.


        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER CertificatePublicKey
            The certificate to be revoked. Either as base64url-string or byte[]. Needs to be DER encoded (vs. PEM - so no ---- Begin Certificate ----).

        .PARAMETER SigningKey
            The key to sign the revocation request. If you provide the X509Certificate or Order parameter, this will be set automatically.

        .PARAMETER Order
            The order which contains the issued certificate.

        .PARAMETER X509Certificate
            The X509Certificate to be revoked, if it contains a private key, it will be used to sign the revocation request.

        .PARAMETER PFXCertificatePath
            The pfx file path containing the certificate to be revoked.

        .PARAMETER PFXCertificatePassword
            The pfx file might need a password. Provide it here.

        .EXAMPLE
            PS> Revoke-Certificate -State $myState -Order $myOrder

        .EXAMPLE
            PS> Revoke-Certificate -State $myState -PFXCertificatePath C:\Temp\myCert.pfx
    #>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "", Scope="Function", Target="*")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountExists()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true, ParameterSetName = "ByCert")]
        [Parameter(Mandatory = $true, ParameterSetName = "ByPrivateKey")]
        $CertificatePublicKey,

        [Parameter(Mandatory = $true, ParameterSetName = "ByPrivateKey")]
        [AcmePSKey]
        $SigningKey,

        [Parameter(Mandatory = $true, ParameterSetName = "ByOrder")]
        [ValidateNotNull()]
        [AcmeOrder]
        $Order,

        [Parameter(Mandatory = $true, ParameterSetName = "ByX509")]
        [ValidateNotNull()]
        [Security.Cryptography.X509Certificates.X509Certificate2]
        $X509Certificate,

        [Parameter(Mandatory = $true, ParameterSetName = "ByPFXFile")]
        [ValidateNotNull()]
        [string]
        $PFXCertificatePath,

        [Parameter(ParameterSetName = "ByPFXFile")]
        [string]
        $PFXCertificatePassword
    )

    if($PSCmdlet.ParameterSetName -eq "ByPFXFile") {
        $x509Certificate = if([string]::IsNullOrEmpty($PFXCertificatePassword)) {
            [Security.Cryptography.X509Certificates.X509Certificate2]::new($PFXCertificatePath);
        } else {
            [Security.Cryptography.X509Certificates.X509Certificate2]::new($PFXCertificatePath, $PFXCertificatePassword);
        }

        return Revoke-Certificate -State $State -X509Certificate $x509Certificate;
    }

    if($PSCmdlet.ParameterSetName -eq "ByX509") {
        $certBytes = $X509Certificate.Export([Security.Cryptography.X509Certificates.X509ContentType]::Cert);

        if($X509Certificate.HasPrivateKey) {
            $privateKey = [Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($X509Certificate);

            if($null -eq $privateKey) {
                $privateKey = [Security.Cryptography.X509Certificates.ECDsaCertificateExtensions]::GetECDsaPrivateKey($X509Certificate);
            }

            if($null -eq $privateKey) {
                throw "Unsupported X509 certificate key type."
            }

            $key = [AcmePSKey]::new($privateKey);

            return Revoke-Certificate -State $State -CertificatePublicKey $certBytes -SigningKey $key;
        }
        else {
            return Revoke-Certificate -State $State -CertificatePublicKey $certBytes;
        }
    }

    if($PSCmdlet.ParameterSetName -eq "ByOrder") {
        $certBytes = $State.GetOrderCertificate($Order);
        if($null -eq $certBytes) {
            throw "Cannot get certificate associated with order, revocation failed."
        }

        $certBase64String = [Text.Encoding]::ASCII.GetString($certBytes) -split "-----" |
            ForEach-Object { $_.Replace("`r","").Replace("`n","").Trim() } | Where-Object { $_ -like "MII*" } | Select-Object -First 1;

        $derBytes = [System.Convert]::FromBase64String($certBase64String);

        return Revoke-Certificate -State $State -CertificatePublicKey $derBytes;
    }

    if($PSCmdlet.ParameterSetName -in @("ByCert", "ByPrivateKey")) {
        if ($CertificatePublicKey -is [string]) {
            $base64DERCertificate = $CertificatePublicKey;
        }
        elseif($CertificatePublicKey -is [byte[]]) {
            $base64DERCertificate = ConvertTo-UrlBase64 -InputBytes $CertificatePublicKey;
        }
        else {
            throw "CertificatePublicKey either needs to be string or byte[]";
        }

        $url = $State.GetServiceDirectory().RevokeCert;
        $payload = @{ "certificate" = $base64DERCertificate; "reason" = 1 };

        if($PSCmdlet.ShouldProcess("Certificate", "Revoking certificate.")) {
            if ($PSCmdlet.ParameterSetName -eq "ByCert") {
                return Invoke-SignedWebRequest -Url $url -State $State -Payload $payload;
            } elseif ($PSCmdlet.ParameterSetName -eq "ByPrivateKey") {
                return Invoke-SignedWebRequest -Url $url -State $State -Payload $payload -SigningKey $SigningKey
            }
        }
    }

    throw "No ParameterSet matched.";
}
