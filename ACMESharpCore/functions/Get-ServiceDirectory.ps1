function Get-ServiceDirectory {
    <#
        .SYNOPSIS
        Fetches the ServiceDirectory from an ACME Servers.

        .DESCRIPTION
        This will issue a web request to either the url or to a well-known ACME server.

        
    #>
    [CmdletBinding(DefaultParameterSetName="ByName")]
    [OutputType([ACMEServiceDirectory])]
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
        
        Write-Information "Calling $directoryUrl to get ACME Service Directory"
        $jsonDirectory = (Invoke-WebRequest $directoryUrl).Content | ConvertFrom-Json;

        $result = [ACMESharp.Protocol.Resources.ServiceDirectory]::new();
        
        $result.Directory = $directoryUrl;
        $result.KeyChange = $jsonDirectory.KeyChange
        $result.NewAccount = $jsonDirectory.NewAccount;
        $result.NewAuthz = $jsonDirectory.NewAuthz;
        $result.NewNonce = $jsonDirectory.NewNonce;
        $result.NewOrder = $jsonDirectory.NewOrder;
        $result.RevokeCert = $jsonDirectory.RevokeCert;

        $result.Meta = [ACMESharp.Protocol.Resources.DirectoryMeta]::new();
        $result.Meta.TermsOfService = $jsonDirectory.Meta.TermsOfService;
        $result.Meta.Website = $jsonDirectory.Meta.Website;
        $result.Meta.CaaIdentities = $jsonDirectory.Meta.CaaIdentities;
        $result.Meta.ExternalAccountRequired = $jsonDirectory.Meta.ExternalAccountRequired;

        return $result;
    }
}