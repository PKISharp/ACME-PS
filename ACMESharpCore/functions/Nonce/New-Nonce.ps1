function New-Nonce {
    <#
        .SYNOPSIS
            Gets a new nonce.

        .DESCRIPTION
            Issues a web request to receive a new nonce from the service directory


        .PARAMETER State
            The nonce will be written into the provided state instance.

        .PARAMETER PassThru
            If set, the nonce will be returned to the pipeline.


        .EXAMPLE
            PS> New-Nonce -Uri "https://acme-staging-v02.api.letsencrypt.org/acme/new-nonce"
    #>
    [CmdletBinding()]
    [OutputType("string")]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate("ServiceDirectory")})]
        [AcmeState]
        $State,

        [Parameter()]
        [switch]
        $PassThru
    )

    $Url = $State.GetServiceDirectory().NewNonce;

    $response = Invoke-AcmeWebRequest $Url -Method Head
    $nonce = $response.NextNonce;

    if(-not $nonce) {
        throw "Could not retreive new nonce";
    }

    $State.SetNonce($nonce);

    if($PassThru) {
        return $nonce;
    }
}