function New-Nonce {
    <#
        .SYNOPSIS
            Gets a new nonce from the uri
        .DESCRIPTION
            Issues a web request to receive a new nonce from the given uri

        .EXAMPLE
            PS> New-Nonce -Uri "https://acme-staging-v02.api.letsencrypt.org/acme/new-nonce"
    #>
    [CmdletBinding()]
    [OutputType("String")]
    param(
        # The Uri to send the new-nonce request to
        [Parameter(Mandatory = $true, Position = 0)]
        [uri]
        $Uri,

        [Parameter()]
        [Switch] $SkipModuleNonce
    )

    $response = Invoke-AcmeWebRequest $Uri -Method Head

    if($Script:AutoNonce) {
        $Script:NewNonce = $Uri
        $Script:Nonce = $response.NextNonce;
    }

    return $response.NextNonce
}