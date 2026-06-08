<#
    .SYNOPSIS
        Fetches the ServiceDirectory from an ACME Server.

    .DESCRIPTION
        This will issue a web request to either the url or to a well-known ACME server to fetch the service directory.
        Alternatively the directory can be loaded from a json file.


    .PARAMETER ServiceName
        The Name of an Well-Known ACME service provider.

    .PARAMETER DirectoryUrl
        Url of an ACME Directory.

    .PARAMETER FilePath
        If given, specifies the path to load the directory from or save the directory to.

    .PARAMETER PassThru
        Forces the service directory to be returned to the pipeline.

    .PARAMETER InMemory
        If set, the service directory will not be saved to disk, but only returned to the pipeline.

    .PARAMETER Force
        If set, an existing file at the given path will be overwritten without warning.


    .EXAMPLE
        PS> Get-ServiceDirectory

    .EXAMPLE
        PS> Get-ServiceDirectory "LetsEncrypt" -PassThru

    .EXAMPLE
        PS> Get-ServiceDirectory -DirectoryUrl "https://acme-staging-v02.api.letsencrypt.org"
#>
function Get-ServiceDirectory {
    [CmdletBinding(DefaultParameterSetName = "FromPath", SupportsShouldProcess = $true)]
    [OutputType("ACMEDirectory")]
    param(
        [Parameter(Position = 1, ParameterSetName = "FromName")]
        [Parameter(Position = 1, ParameterSetName = "FromName-InMemory")]
        [string]
        $ServiceName,

        [Parameter(Mandatory = $true, ParameterSetName = "FromUrl")]
        [Parameter(Mandatory = $true, ParameterSetName = "FromUrl-InMemory")]
        [Uri]
        $DirectoryUrl,

        [Parameter(ParameterSetName = "FromName")]
        [Parameter(ParameterSetName = "FromUrl")]
        [Parameter(ParameterSetName = "FromPath")]
        [string]
        $FilePath = (Join-Path -Path (Get-RuntimeDataPath) -ChildPath "_directory.json"),

        [Parameter(Mandatory = $true, ParameterSetName = "FromName-InMemory")]
        [Parameter(Mandatory = $true, ParameterSetName = "FromUrl-InMemory")]
        [switch]
        $InMemory,

        [Parameter(ParameterSetName = "FromName")]
        [Parameter(ParameterSetName = "FromUrl")]
        [switch]
        $PassThru,

        [Parameter(ParameterSetName = "FromName")]
        [Parameter(ParameterSetName = "FromUrl")]
        [switch]
        $Force
    )

    $KnownEndpoints = @{
        "LetsEncrypt-Staging" = "https://acme-staging-v02.api.letsencrypt.org/directory";
        "LetsEncrypt"         = "https://acme-v02.api.letsencrypt.org/directory"
    }

    $ErrorActionPreference = 'Stop';

    if ($PSCmdlet.ParameterSetName -in @("FromName", "FromUrl", "FromName-InMemory", "FromUrl-InMemory")) {
        if ($PSCmdlet.ParameterSetName -like "FromName*") {
            $acmeBaseUrl = $KnownEndpoints[$ServiceName];
            if ($null -eq $acmeBaseUrl) {
                $knownNames = $KnownEndpoints.Keys -join ", "
                Write-Error "The ACME-Service-Name $ServiceName is not known. Known names are $knownNames.";
                return;
            }

            $serviceDirectoryUrl = $acmeBaseUrl;
        }
        elseif ($PSCmdlet.ParameterSetName -like "FromUrl*") {
            $serviceDirectoryUrl = $DirectoryUrl
        }

        if (-not $InMemory) {
            if ((Test-Path $FilePath) -and (-not $Force)) {
                Write-Error "The file $FilePath already exists. Use -Force to overwrite it.";
                return;
            }
        }

        $response = Invoke-WebRequest $serviceDirectoryUrl -UseBasicParsing;
        $result = [AcmeDirectory]::new(($response.Content | ConvertFrom-Json), $serviceDirectoryUrl);

        if ($InMemory) {
            Write-Warning "The service directory will not be saved to disk. It will only be returned to the pipeline.";
            return $result;
        }

        if ($PSCmdlet.ShouldProcess("Service Directory", "Save service directory to $FilePath")) {
            $directoryPath = Split-Path -Path $FilePath -Parent
            if (-not (Test-Path -Path $directoryPath)) {
                New-Item -Path $directoryPath -ItemType Directory -Force | Out-Null
            }
            
            $result.ToJson() > $FilePath;
        }
        
        if ($PassThru) {
            return $result;
        }
    }

    if ($PSCmdlet.ParameterSetName -eq "FromPath") {
        return [AcmeDirectory]::new((Get-Content $FilePath | ConvertFrom-Json), $null);
    }
}
