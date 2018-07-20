function Get-ServiceDirectory {
    <#
        .SYNOPSIS
            Fetches the ServiceDirectory from an ACME Servers.

        .DESCRIPTION
            This will issue a web request to either the url or to a well-known ACME server.
            If not forbidden during Module loading, this will initialize the Automatic-Nonce-Handling as well.

        .EXAMPLE
            PS> Get-ServiceDirectory
        .EXAMPLE
            PS> Get-ServiceDirectory "LetsEncrypt"
        .EXAMPLE
            PS> Get-ServiceDirectory -ACMEDirectoryUrl "https://acme-staging-v02.api.letsencrypt.org"
    #>
    [CmdletBinding(DefaultParameterSetName="ByName")]
    [OutputType("ACMEDirectory")]
    param(
        [Parameter(Position=0, ParameterSetName="ByName")]
        [string]
        $ACMEEndpointName = "LetsEncrypt-Staging",

        [Parameter(ParameterSetName="ByUrl")]
        [Uri]
        $ACMEDirectoryUrl
    )

    begin {
        $KnownEndpoints = @{ 
            "LetsEncrypt-Staging"="https://acme-staging-v02.api.letsencrypt.org";
            "LetsEncrypt"="https://acme-v02.api.letsencrypt.org" 
        }
    }

    process {
        [string]$directoryUrl;

        if($PSCmdlet.ParameterSetName -eq "ByName") {
            $acmeBaseUrl = $KnownEndpoints[$ACMEEndpointName];
            if($acmeBaseUrl -eq $null) {
                $knownNames = $KnownEndpoints.Keys -join ", "
                throw "The Name ACME-Enpoint-Name $ACMEEndpointName is not known. Known names are $knownNames."
            }

            $directoryUrl = "$acmeBaseUrl/directory"
        } elseif ($PSCmdlet.ParameterSetName -eq "ByUrl") {
            $directoryUrl = $ACMEDirectoryUrl
        }
        
        Write-Verbose "Calling $directoryUrl to get ACME Service Directory"
        $response = Invoke-WebRequest $directoryUrl;

        $result = [AcmeDirectory]::new(($response.Content | ConvertFrom-Json));

        if($Script:AutoNonce) {
            $Script:NewNonceUrl = $result.NewNonce;

            New-Nonce | Out-Null;
        }

        return $result;
    }
}