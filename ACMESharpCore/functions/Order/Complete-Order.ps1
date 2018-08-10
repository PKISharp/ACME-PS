function Complete-Order {
    <#
        .SYNOPSIS
            Finalizes an acme order

        .DESCRIPTION
            Finalizes the acme order by submitting a CSR to the acme service.

        .PARAMETER Directory
            The service directory of the ACME service. Can be handled by the module, if enabled.

        .PARAMETER AccountKey
            Your account key for JWS Signing. Can be handled by the module, if enabled.
        
        .PARAMETER KeyId
            Your "kid" as defined in the acme standard (usually the url to your account)

        .PARAMETER Nonce
            Replay nonce from ACME service. Can be handled by the module, if enabled.

        .PARAMETER Order
            The order to be finalized.
        
        .PARAMETER CertificateKey
            The certificate key to be used to create a CSR.


        .EXAMPLE
            PS> Complete-Order -Order $myOrder -CertificateKey $myCertKey
    #>
    param(
        [Parameter(Position = 0)]
        [ValidateNotNull()]
        [AcmeDirectory]
        $Directory = $Script:ServiceDirectory,

        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [IAccountKey] $AccountKey = $Script:AccountKey,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string] $KeyId = $Script:KeyId,

        [Parameter(Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string] $Nonce = $Script:Nonce,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [AcmeOrder]
        $Order,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ICertificateKey] 
        $CertificateKey
    )

    process {
        $ErrorActionPreference = 'Stop';

        $dnsNames = $Order.Identifiers | ForEach-Object { $_.Value }

        $csr = $CertificateKey.GenerateCsr($dnsNames);
        $payload = @{ "csr"= (ConvertTo-UrlBase64 -InputBytes $csr) }

        $requestUrl = $Order.FinalizeUrl;

        $requestBody = New-SignedMessage -Url $requestUrl -AccountKey $AccountKey -KeyId $KeyId -Nonce $Nonce -Payload $payload;
        $response = Invoke-AcmeWebRequest $requestUrl $requestBody -Method POST;

        $Order.UpdateOrder($response);
    }
}