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
            The X509Certificate to be revoked, if it contains a private key, it will be used to sign the revocation request.

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

        [Paremeter(ParameterSetName = "ByCert")]
        [ISigningKey] 
        $SigningKey,

        [Parameter(ParameterSetName = "ByCert")]
        [ValidateSet(256, 384, 512)]
        [int] $HashSize,

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

        if($X509Certificate.HasPrivateKey) {
            if($X509Cert.PrivateKey -is [System.Security.Cryptography.RSA]) {
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

                $keyExport.HashSize = $HashSize;
            }
            elseif($X509Cert.PrivateKey -is [System.Security.Cryptography.ECDsa]) {
                $ecParams = $this.ECDsa.ExportParameters($true);
                $keyExport = [ECDsaKeyExport]::new();
        
                $keyExport.D = $ecParams.D;
                $keyExport.X = $ecParams.Q.X;
                $keyExport.Y = $ecParams.Q.Y;
        
                $keyExport.HashSize = $HashSize;
            }
            else {
                throw new "Unsupported X509 certificate key type ($($X509Cert.PrivateKey.GetType())).";
            }

            $signingKey = [KeyFactory]::CreateAccountKey($keyExport);

            Revoke-Certificate -State $State -CertificatePublicKey $certBytes -SigningKey $signingKey;
        }
        else {
            Revoke-Certificate -State $State -CertificatePublicKey $certBytes;
        }
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
        $payload = @{ "certificate" = $base64Certificate; "reason" = 1 };

        if($PSCmdlet.ShouldProcess("Certificate", "Revoking certificate.")) {
            Invoke-SignedWebRequest -Url $url -State $State -Payload $payload;
        }
    }

    throw "No ParameterSet matched.";
}
