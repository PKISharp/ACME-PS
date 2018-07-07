function Initialize-Store {
    <#
        .SYNOPSIS
        Initializes local Storage to cache state from ACME Servers.

        .DESCRIPTION
        This will create files needed to keep track of the local state for communication with the remote ACME servers.

        
    #>
    [CmdletBinding(DefaultParameterSetName="ByName")]
    param(
        [Parameter(ParameterSetName="ByName")]
        [string]
        $ACMEEndpointName = "LetsEncrypt-Staging",

        [Parameter(ParameterSetName="ByUrl")]
        [Uri]
        $ACMEDirectoryUrl,

        [Parameter(ParameterSetName="ByServiceDirectory", ValueFromPipeline=$true)]
        [ACMESharp.Protocol.Resources.ServiceDirectory]
        $ACMEServiceDirectory,

        [Parameter(Mandatory=$true, Position = 0, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LiteralPath,

        [Switch]
        $PassThrough
    )

    process {
        if(Test-Path "$LiteralPath/*") {
            throw "Initializing the store can only be done on a non exitent or empty directory."
        }

        [ACMESharp.Protocol.Resources.ServiceDirectory]$serviceDirectory;

        if($PSCmdlet.ParameterSetName -eq "ByName") {
            $serviceDirectory = Get-ServiceDirectory -ACMEEndpointName $ACMEEndpointName
        } elseif ($PSCmdlet.ParameterSetName -eq "ByUrl"){
            $serviceDirectory = Get-ServiceDirectory -ACMEDirectoryUrl $ACMEDirectoryUrl
        } else {
            $serviceDirectory = $ACMEServiceDirectory
        }
        
        if($serviceDirectory -eq $null) {
            throw "Either provide a well-known ACME service name, ACME service url or ServiceDirectory object."
        }            

        if(!(Test-Path $LiteralPath)) {
            New-Item "$LiteralPath" -ItemType Directory | Out-Null
        }
        
        $serviceDirectory.Directory | Out-File "$LiteralPath/.ACMESharpStore" -Encoding ASCII
        Export-Clixml "$LiteralPath/ServiceDirectory.xml" -InputObject $serviceDirectory | Out-Null

        if($PassThrough) {
            return $serviceDirectory
        }
    }
}