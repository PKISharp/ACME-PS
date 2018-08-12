function Complete-Order {
    <#
        .SYNOPSIS
            Finalizes an acme order

        .DESCRIPTION
            Finalizes the acme order by submitting a CSR to the acme service.

        .PARAMETER State
            State instance containing service directory, account key, account and nonce.
        
        .PARAMETER Order
            The order to be finalized.
        
        .PARAMETER CertificateKey
            The certificate key to be used to create a CSR.


        .EXAMPLE
            PS> Complete-Order -Order $myOrder -CertificateKey $myCertKey
    #>
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate()})]
        [AcmeState]
        $State,

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
        $accountKey = $State.AccountKey;
        $keyId = $State.Account.KeyId;

        $response = Invoke-SignedWebRequest -Url $requestUrl -AccountKey $AccountKey -KeyId $KeyId -Nonce $Nonce.Next -Payload $payload;

        $Order.UpdateOrder($response);
    }
}