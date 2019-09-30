function New-Nonce {
    <#
        .SYNOPSIS
            Gets a new nonce.

        .DESCRIPTION
            Issues a web request to receive a new nonce from the service directory


        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER PassThru
            Forces the nonce to be returned to the pipeline.


        .EXAMPLE
            PS> New-Nonce -State $state
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
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

    if($response.IsError) {
        throw "$($result.ErrorMessage)`n$($result.Content)";
    }
    if(-not $nonce) {
        throw "Could not retreive new nonce";
    }

    if($PSCmdlet.ShouldProcess("Nonce", "Store new nonce into state")) {
        $State.SetNonce($nonce);
    }

    if($PassThru) {
        return $nonce;
    }
}