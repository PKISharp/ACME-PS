function Revoke-Certificate {
    <#
        .SYNOPSIS
            Revokes the certificate associated with the order.

        .DESCRIPTION
            Revokes the certificate associated with the order.


        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER Order
            The order which contains the issued certificate.

        .EXAMPLE
            PS> Revoke-Certificate -State $myState -Order $myOrder
    #>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountExists()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [AcmeOrder]
        $Order
    )

    $certificate = $State.GetOrderCertificate($Order);
    $base64Certificate = [System.Convert]::ToBase64String($certificate);

    $url = $State.GetServiceDirectory().RevokeCert;
    $payload = @{ "certificate" = $base64Certificate };

    if($PSCmdlet.ShouldProcess("Certificate", "Revoking certificate.")) {
        Invoke-SignedWebRequest -Url $url -State $State -Payload $payload;
    }
}