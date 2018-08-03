function Get-ServiceDirectory {
    <#
        .SYNOPSIS
            Fetches the ServiceDirectory from an ACME Servers.

        .DESCRIPTION
            This will issue a web request to either the url or to a well-known ACME server to fetch the service directory.
            Alternatively the directory can be loaded from a path, when it has been stored with Export-CliXML or as Json.

        
        .PARAMETER ACMEEndointName
            The Name of an Well-Known ACME-Endpoint.
        
        .PARAMETER ACMEDirectoryUrl
            Url of an ACME Directory.
        
        .PARAMETER Path
            Path to load the Directory from. The given file needs to be .json or .xml (CLI-Xml)
        
        .PARAMETER EnableModuleUrlHandling
            If set, the loaded service collection will be set as Module-Scoped variable. 
            Other functions needing Urls from the service collection will be able to determine them automatically.
        
        .PARAMETER EnableModuleNonceHandling
            If set, the nonce will be initialized and handled by the module. You can access the current Nonce by calling Get-Nonce.


        .EXAMPLE
            PS> Get-ServiceDirectory

        .EXAMPLE
            PS> Get-ServiceDirectory "LetsEncrypt"

        .EXAMPLE
            PS> Get-ServiceDirectory "LetsEncrypt" -EnableModuleUrlHandling -EnableModuleNonceHandling

        .EXAMPLE
            PS> Get-ServiceDirectory -ACMEDirectoryUrl "https://acme-staging-v02.api.letsencrypt.org"
    #>
    [CmdletBinding(DefaultParameterSetName="FromName")]
    [OutputType("ACMEDirectory")]
    param(
        [Parameter(Mandatory=$true, Position=0, ParameterSetName="FromName")]
        [string]
        $ACMEEndpointName = "LetsEncrypt-Staging",

        [Parameter(Mandatory=$true, ParameterSetName="FromUrl")]
        [Uri]
        $ACMEDirectoryUrl,

        [Parameter(Mandatory=$true, ParameterSetName="FromPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter()]
        [Switch]
        $EnableModuleUrlHandling,

        [Parameter()]
        [Switch]
        $EnableModuleNonceHandling
    )

    begin {
        $KnownEndpoints = @{ 
            "LetsEncrypt-Staging"="https://acme-staging-v02.api.letsencrypt.org";
            "LetsEncrypt"="https://acme-v02.api.letsencrypt.org" 
        }
    }

    process {
        if($PSCmdlet.ParameterSetName -in @("FromName", "FormUrl")) {
            if($PSCmdlet.ParameterSetName -eq "FromName") {
                $acmeBaseUrl = $KnownEndpoints[$ACMEEndpointName];
                if($acmeBaseUrl -eq $null) {
                    $knownNames = $KnownEndpoints.Keys -join ", "
                    throw "The Name ACME-Enpoint-Name $ACMEEndpointName is not known. Known names are $knownNames."
                }

                $directoryUrl = "$acmeBaseUrl/directory"
            } elseif ($PSCmdlet.ParameterSetName -eq "FromUrl") {
                $directoryUrl = $ACMEDirectoryUrl
            }
            
            Write-Verbose "Calling $directoryUrl to get ACME Service Directory"
            $response = Invoke-WebRequest $directoryUrl;

            $result = [AcmeDirectory]::new(($response.Content | ConvertFrom-Json));
        }

        if($PSCmdlet.ParameterSetName -eq "FromPath") {
            if($Path -like "*.json") {
                $result = [ACMEDirectory](Get-Content $Path | ConvertFrom-Json)
            } else {
                $result = [AcmeDirectory](Import-Clixml $Path)
            }
        }

        if($EnableModuleUrlHandling) {
            $Script:ServiceDirectory = $result;
        }

        if($EnableModuleNonceHandling) {
            $Script:AutoNonce = $true;
            $Script:NewNonceUrl = $result.NewNonce;
            New-Nonce | Out-Null;
        }

        return $result;
    }
}