function Complete-Order {
    <#
        .SYNOPSIS
            Finalizes an acme order

        .DESCRIPTION
            Finalizes the acme order by submitting a CSR to the acme service.

        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER Order
            The order to be finalized.

        .PARAMETER CertificateKey
            The certificate key to be used to create a CSR.


        .EXAMPLE
            PS> Complete-Order -Order $myOrder -CertificateKey $myCertKey
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [AcmeOrder]
        $Order,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ICertificateKey]
        $CertificateKey,

        [Parameter()]
        [switch]
        $PassThru
    )

    process {
        $ErrorActionPreference = 'Stop';

        $dnsNames = $Order.Identifiers | ForEach-Object { $_.Value }

        $csr = $CertificateKey.GenerateCsr($dnsNames);
        $payload = @{ "csr"= (ConvertTo-UrlBase64 -InputBytes $csr) }

        $requestUrl = $Order.FinalizeUrl;

        if($PSCmdlet.ShouldProcess("Order", "Finalizing order at ACME service by submitting CSR")) {
            $response = Invoke-SignedWebRequest $requestUrl $State $payload;

            $Order.UpdateOrder($response);
        }

        if($PassThru) {
            return $Order;
        }
    }
}