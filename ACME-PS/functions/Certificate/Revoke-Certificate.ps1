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
            The certificate to be revoked. Either as base64-string or byte[]. Needs to be DER encoded.

        .PARAMETER Order
            The order which contains the issued certificate.

        .PARAMETER PFXCertificatePath
            The pfx file path containing the certificate to be revoked.

        .PARAMETER X509Certificate
            The X509Certificate to be revoked.

        .EXAMPLE
            PS> Revoke-Certificate -State $myState -Order $myOrder

        .EXAMPLE
            PS> Revoke-Certificate -State $myState -PFXCertificatePath C:\Temp\myCert.pfx
    #>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountExists()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true, ParameterSetName = "ByCert")]
        $CertificatePublicKey,

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

        [Parameter(Mandatory = $true, ParameterSetName = "ByPFXFile")]
        [string]
        $PFXCertificatePassword
    )

    if($PSCmdlet.ParameterSetName -eq "ByPFXFile") {
        $x509Certificate = if([string]::IsNullOrEmpty($PFXCertificatePassword)) {
            [Security.Cryptography.X509Certificates.X509Certificate2]::new($PFXCertificatePath);
        } else {
            [Security.Cryptography.X509Certificates.X509Certificate2]::new($PFXCertificatePath, $PFXCertificatePassword);
        }

        Revoke-Certificate -State $State -X509Certificate $x509Certificate;
        return;
    }

    if($PSCmdlet.ParameterSetName -eq "ByX509") {
        $certBytes = $X509Certificate.Export([Security.Cryptography.X509Certificates.X509ContentType]::Cert);
        Revoke-Certificate -State $State -CertificatePublicKey $certBytes;
        
        return;
    }

    if($PSCmdlet.ParameterSetName -eq "ByOrder") {
        $certBytes = $State.GetOrderCertificate($Order);
        if($null -eq $certBytes) {
            throw "Cannot get certificate associated with order, revocation failed."
        }

        Revoke-Certificate -State $State -CertificatePublicKey $certBytes;
        return;
    }

    if($PSCmdlet.ParameterSetName -eq "ByCert") {
        $base64Certificate = if([string] -eq $CertificatePublicKey.GetType()) {
            $CertificatePublicKey;
        } elseif ([byte[]] -eq $CertificatePublicKey.GetType()) {
            [System.Convert]::ToBase64String($CertificatePublicKey);
        } else {
            throw "CertificatePublicKey either needs to be string or byte[]";
        };
        
        $url = $State.GetServiceDirectory().RevokeCert;
        $payload = @{ "certificate" = $base64Certificate };

        if($PSCmdlet.ShouldProcess("Certificate", "Revoking certificate.")) {
            Invoke-SignedWebRequest -Url $url -State $State -Payload $payload;
        }
    }

    throw "No ParameterSet matched.";
}
