function New-Nonce {
    <#
        .SYNOPSIS
            Gets a new nonce from the uri

        .DESCRIPTION
            Issues a web request to receive a new nonce from the given uri


        .PARAMETER Url
            Requests a new nonce from the given Url

        .PARAMETER Directory
            Request a new nonce by using the ACME-Directory

        .PARAMETER ForceAutoNonceUsage
            If automatic nonce handling is enabled and service directory handling is disabled, 
            you might need to enforce AutoNonceUrl usage instead of DirectoryUrl usage

        .EXAMPLE
            PS> New-Nonce -Uri "https://acme-staging-v02.api.letsencrypt.org/acme/new-nonce"
    #>
    [CmdletBinding(DefaultParameterSetName="UseDirectory")]
    [OutputType("AcmeNonce")]
    param(
        [Parameter(Position = 0, ParameterSetName="UseUrl")]
        [ValidateNotNullOrEmpty()]
        [uri]
        $Url = $Script:NewNonceUrl,

        [Parameter(ParameterSetName="UseUrl")]
        [Switch]
        $ForceAutoNonceUsage,

        [Parameter(Position = 0, ParameterSetName="UseDirectory")]
        [ValidateNotNull()]
        [AcmeDirectory]
        $Directory = $Script:ServiceDirectory
    )

    if($Directory) {
        Write-Verbose "Using new nonce Url from service directory. "
        $Url = $Directory.NewNonce;
    }

    $response = Invoke-AcmeWebRequest $Url -Method Head 
    return [AcmeNonce]::new($response.NextNonce);
}