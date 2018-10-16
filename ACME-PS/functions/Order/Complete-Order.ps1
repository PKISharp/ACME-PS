function Complete-Order {
    <#
        .SYNOPSIS
            Completes an order process at the ACME service, so the certificate will be issued.

        .DESCRIPTION
            Completes an order process by submitting a certificate signing request to the ACME service.


        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER Order
            The order to be completed.

        .PARAMETER CertificateKey
            The certificate key to be used to create the certificate signing request.

        .PARAMETER PassThru
            Forces the order to be returned to the pipeline.

        .EXAMPLE
            PS> Complete-Order -State $myState -Order $myOrder -CertificateKey $myCertKey
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

        Write-Verbose "Generating CSR for $($Order.PrimaryDomain)"
        $csr = $CertificateKey.GenerateCsr($Order.PrimaryDomain, $dnsNames);

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