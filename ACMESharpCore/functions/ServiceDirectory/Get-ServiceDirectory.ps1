function Get-ServiceDirectory {
    <#
        .SYNOPSIS
            Fetches the ServiceDirectory from an ACME Servers.

        .DESCRIPTION
            This will issue a web request to either the url or to a well-known ACME server to fetch the service directory.
            Alternatively the directory can be loaded from a path, when it has been stored with Export-CliXML or as Json.


        .PARAMETER EndpointName
            The Name of an Well-Known ACME-Endpoint.

        .PARAMETER DirectoryUrl
            Url of an ACME Directory.

        .PARAMETER Path
            Path to load the Directory from. The given file needs to be .json or .xml (CLI-Xml)

        .PARAMETER State
            If present, the service directory will be written into the provided state instance.

        .PARAMETER PassThrough
            If set, the service directory will be returned to the pipeline.


        .EXAMPLE
            PS> Get-ServiceDirectory $myState

        .EXAMPLE
            PS> Get-ServiceDirectory "LetsEncrypt" $myState -PassThrough

        .EXAMPLE
            PS> Get-ServiceDirectory -DirectoryUrl "https://acme-staging-v02.api.letsencrypt.org" $myState
    #>
    [CmdletBinding(DefaultParameterSetName="FromName")]
    [OutputType("ACMEDirectory")]
    param(
        [Parameter(Position=1, ParameterSetName="FromName")]
        [string]
        $ServiceName = "LetsEncrypt-Staging",

        [Parameter(Mandatory=$true, ParameterSetName="FromUrl")]
        [Uri]
        $DirectoryUrl,

        [Parameter(Mandatory=$true, ParameterSetName="FromPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [AcmeState]
        $State,

        [Parameter()]
        [switch]
        $PassThrough
    )

    begin {
        $KnownEndpoints = @{
            "LetsEncrypt-Staging"="https://acme-staging-v02.api.letsencrypt.org";
            "LetsEncrypt"="https://acme-v02.api.letsencrypt.org"
        }
    }

    process {
        $ErrorActionPreference = 'Stop';

        if($PSCmdlet.ParameterSetName -in @("FromName", "FormUrl")) {
            if($PSCmdlet.ParameterSetName -eq "FromName") {
                $acmeBaseUrl = $KnownEndpoints[$ServiceName];
                if($null -eq $acmeBaseUrl) {
                    $knownNames = $KnownEndpoints.Keys -join ", "
                    throw "The ACME-Service-Name $ServiceName is not known. Known names are $knownNames."
                }

                $serviceDirectoryUrl = "$acmeBaseUrl/directory"
            } elseif ($PSCmdlet.ParameterSetName -eq "FromUrl") {
                $serviceDirectoryUrl = $DirectoryUrl
            }

            $response = Invoke-WebRequest $serviceDirectoryUrl;

            $result = [AcmeDirectory]::new(($response.Content | ConvertFrom-Json));
            $result.ResourceUrl = $serviceDirectoryUrl;
        }

        if($PSCmdlet.ParameterSetName -eq "FromPath") {
            if($Path -like "*.json") {
                $result = [ACMEDirectory](Get-Content $Path | ConvertFrom-Json)
            } else {
                $result = [AcmeDirectory](Import-Clixml $Path)
            }
        }

        $state.ServiceDirectory = $result;

        if($PassThrough) {
            return $result;
        }
    }
}