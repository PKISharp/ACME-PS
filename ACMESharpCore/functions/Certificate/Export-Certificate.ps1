function Export-PfxCertificate {
    <#
        .SYNOPSIS
            Exports an issued certificate as pfx with private and public key.

        .DESCRIPTION
            Exports an issued certificate by downloading it from the acme service and combining it with the private key.

        
        .PARAMETER Order
            The order which contains the issued certificate.
        
        .PARAMETER CertificateKey
            The key which was used to create the orders CSR.

        .PARAMETER Path
            The path where the key will be saved.

        .PARAMETER Password
            The password used to secure the certificate.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [AcmeOrder]
        $Order,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ICertificateKey] 
        $CertificateKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]
        $Path,

        [Parameter()]
        [string]
        $Passsword,

        [Parameter()]
        [switch]
        $Force
    )

    $ErrorActionPreference = 'Stop'

    if(Test-Path $Path) {
        if($Force) {
            Clear-Content $Path;
        } else {
            Write-Error "$Path did already exist."
        }
    }

    $response = Invoke-WebRequest $Order.CertificateUrl -UseBasicParsing;
    $certicate = [byte[]]$response.Content;

    $CertificateKey.ExportPfx($certicate, $Passsword) | Set-Content $Path -AsByteStream
}