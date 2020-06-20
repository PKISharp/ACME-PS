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

        .PARAMETER SaveCertificateKey
            If present, the certificate will be saved with the order object. Use this, if the certificate key
            has not been exported, yet.

        .PARAMETER GenerateCertificateKey
            If present, the cmdlet will automatically create a certificate key and store it with the order object.
            Should the order already have an associated key, it will be used.

        .PARAMETER PassThru
            Forces the order to be returned to the pipeline.


        .EXAMPLE
            PS> Complete-Order -State $myState -Order $myOrder -CertificateKey $myCertKey

        .EXAMPLE
            PS> Complete-Order -State $myState -Order $myOrder -GenerateCertificateKey
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountExists()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [AcmeOrder]
        $Order,

        [Parameter(Mandatory = $true, ParameterSetName="CustomKey")]
        [ValidateNotNull()]
        [ICertificateKey]
        $CertificateKey,

        [Parameter(ParameterSetName="CustomKey")]
        [switch]
        $SaveCertificateKey,

        [Parameter(Mandatory = $true, ParameterSetName="AutoKey")]
        [switch]
        $GenerateCertificateKey,

        [Parameter()]
        [switch]
        $PassThru
    )

    process {
        $ErrorActionPreference = 'Stop';

        if($GenerateCertificateKey) {
            $CertificateKey = $State.GetOrderCertificateKey($Order);

            if($null -eq $CertificateKey) {
                $SaveCertificateKey = $true;
                $CertificateKey = New-CertificateKey -SkipKeyExport -WarningAction 'SilentlyContinue';
            }
        }

        if($null -eq $CertificateKey) {
            throw "You need to provide a certificate key or enable automatic generation.";
        }

        if($SaveCertificateKey) {
            $State.SetOrderCertificateKey($Order, $CertificateKey);
        }

        $dnsNames = $Order.Identifiers | ForEach-Object { $_.Value }
        if($Order.CSROptions -and -not [string]::IsNullOrWhiteSpace($Order.CSROptions.DistinguishedName)) {
            $certDN = $Order.CSROptions.DistinguishedName;
        } else {
            $certDN = "CN=$($Order.Identifiers[0].Value)";
        }

        $csr = $CertificateKey.GenerateCsr($dnsNames, $certDN);
        $payload = @{ "csr"= (ConvertTo-UrlBase64 -InputBytes $csr) };

        $requestUrl = $Order.FinalizeUrl;

        if($PSCmdlet.ShouldProcess("Order", "Finalizing order at ACME service by submitting CSR")) {
            $response = Invoke-SignedWebRequest -Url $requestUrl -State $State -Payload $payload;

            $Order.UpdateOrder($response);
        }

        if($PassThru) {
            return $Order;
        }
    }
}
