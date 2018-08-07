function Complete-Order {
    <#
        .SYNOPSIS
        
        .DESCRIPTION


        .PARAMETER Directory
            The service directory of the ACME service. Can be handled by the module, if enabled.

        .PARAMETER AccountKey
            Your account key for JWS Signing. Can be handled by the module, if enabled.
        
        .PARAMETER KeyId
            Your "kid" as defined in the acme standard (usually the url to your account)

        .PARAMETER Nonce
            Replay nonce from ACME service. Can be handled by the module, if enabled.

        .PARAMETER 


        .EXAMPLE
            PS> 
    #>
    param(
        [Parameter(Position = 0)]
        [ValidateNotNull()]
        [AcmeDirectory]
        $Directory = $Script:ServiceDirectory,

        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [ACMESharpCore.Crypto.IAccountKey] $AccountKey = $Script:AccountKey,

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
        [ACMESharpCore.Crypto.ICertificateKey] 
        $CertificateKey
    )

    process {
        $dnsNames = $Order.Identifiers | ForEach-Object { $_.Value }

        $csr = ConvertTo-UrlBase64 $CertificateKey.GenerateCsr($dnsNames);
        $payload = @{ "csr"= $csr }

        $requestUrl = $Order.FinalizeUrl;

        $requestBody = New-SignedMessage -Url $requestUrl -AccountKey $AccountKey -KeyId $KeyId -Nonce $Nonce -Payload $payload;
        $response = Invoke-AcmeWebRequest $requestUrl $requestBody -Method POST;
    }
}