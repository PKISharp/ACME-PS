function Get-ACMEServiceDirectory {
    <#
        .SYNOPSIS
            Fetches the ServiceDirectory from an ACME Servers.

        .DESCRIPTION
            This will issue a web request to either the url or to a well-known ACME server to fetch the service directory.
            Alternatively the directory can be loaded from a path, when it has been stored with Export-CliXML or as Json.


        .PARAMETER ServiceName
            The Name of an Well-Known ACME service provider.

        .PARAMETER DirectoryUrl
            Url of an ACME Directory.

        .PARAMETER Path
            Path to load the Directory from. The given file needs to be .json or .xml (CLI-Xml)

        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER PassThru
            Forces the service directory to be returned to the pipeline.


        .EXAMPLE
            PS> Get-ACMEServiceDirectory $myState

        .EXAMPLE
            PS> Get-ACMEServiceDirectory "LetsEncrypt" $myState -PassThru

        .EXAMPLE
            PS> Get-ACMEServiceDirectory -DirectoryUrl "https://acme-staging-v02.api.letsencrypt.org" $myState
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
        $PassThru
    )

    begin {
        $KnownEndpoints = @{
            "LetsEncrypt-Staging"="https://acme-staging-v02.api.letsencrypt.org";
            "LetsEncrypt"="https://acme-v02.api.letsencrypt.org"
        }
    }

    process {
        $ErrorActionPreference = 'Stop';

        if($PSCmdlet.ParameterSetName -in @("FromName", "FromUrl")) {
            if($PSCmdlet.ParameterSetName -eq "FromName") {
                $acmeBaseUrl = $KnownEndpoints[$ServiceName];
                if($null -eq $acmeBaseUrl) {
                    $knownNames = $KnownEndpoints.Keys -join ", "
                    Write-Error "The ACME-Service-Name $ServiceName is not known. Known names are $knownNames.";
                    return;
                }

                $serviceDirectoryUrl = "$acmeBaseUrl/directory"
            } elseif ($PSCmdlet.ParameterSetName -eq "FromUrl") {
                $serviceDirectoryUrl = $DirectoryUrl
            }

            $response = Invoke-WebRequest $serviceDirectoryUrl -UseBasicParsing;

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

        $State.Set($result);

        if($PassThru) {
            return $result;
        }
    }
}
