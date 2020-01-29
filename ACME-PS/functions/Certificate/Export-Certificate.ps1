function Export-Certificate {
    <#
        .SYNOPSIS
            Exports an issued certificate as pfx with private and public key.

        .DESCRIPTION
            Exports an issued certificate by downloading it from the acme service and combining it with the private key.


        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER Order
            The order which contains the issued certificate.

        .PARAMETER CertificateKey
            The key which was used to create the orders CSR.

        .PARAMETER Path
            The path where the certificate will be saved.

        .PARAMETER Password
            The password used to secure the certificate.

        .PARAMETER Force
            Allows the operation to override existing a certificate.


        .EXAMPLE
            PS> Export-Certificate -Order $myOrder -CertficateKey $myKey -Path C:\AcmeCerts\example.com.pfx
    #>
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
        [ValidateNotNull()]
        [ICertificateKey]
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
        $Force,

        [Parameter()]
        [switch]
        $IgnoreSavedCertificate
    )

    $ErrorActionPreference = 'Stop'

    if($null -eq $CertificateKey) {
        $CertificateKey = $State.GetOrderCertificateKey($Order);

        if($null -eq $CertificateKey) {
            throw 'Need $CertificateKey to be provided or present in $Order and $State respectively'
        }
    }

    if(Test-Path $Path) {
        if(!$Force) {
            throw "$Path does already exist."
        }
    }

    if(-not $IgnoreSavedCertificate) {
        $certificate = $State.GetOrderCertificate($Order);
    }

    if($null -ne $certificate) {
        $response = Invoke-SignedWebRequest -Url $Order.CertificateUrl -State $State;
        $certificate = $response.Content;

        if(-not $IgnoreSavedCertificate) {
            $State.SetOrderCertificate($Order);
        }
    }

    Set-ByteContent -Path $Path -Content $CertificateKey.ExportPfx($certificate, $Password)
}