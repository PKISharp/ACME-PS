function Import-ModuleFile {
    <#
    .SYNOPSIS
        Helps import script files
    .DESCRIPTION
        Helps import  files
        Always dotsource this function!
    .PARAMETER Path
        The full path to the file to import
    .EXAMPLE
        PS C:\> Import-ModuleFile -Path $function.FullName
        Imports the file stored at '$function.FullName'
	#>
    [CmdletBinding()]
    Param (
        $Path
    )

    if ($script:doDotSource) { . $Path }
    else { $ExecutionContext.InvokeCommand.InvokeScript($false, ([scriptblock]::Create([io.file]::ReadAllText($Path))), $null, $null) }
}

function Merge-ModuleFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ParameterSetName="Path")]
        [ValidateNotNullOrEmpty()]
        [string] $Path,

        [Parameter(Mandatory = $true, ParameterSetName="Files")]
        [ValidateNotNullOrEmpty()]
        [string[]] $Files,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $OutFile
    )

    if(Test-Path $OutFile) {
        Remove-Item $OutFile
        New-Item $OutFile
    }

    if($PSCmdlet.ParameterSetName -eq "Path") {
        $Files = Get-ChildItem -Path $Path -Recurse -Include "*.ps1"
    }

    $Files | ForEach-Object { Get-Content $_ } | Set-Content $OutFile
}


$script:PSModuleRoot = $PSScriptRoot

$classPath = "$script:PSModuleRoot\internal\classes";
$classes = @(
    "crypto/KeyExport",
    "crypto/KeyBase",
    "crypto/Certificate",
    "crypto/RSAKey",
    "crypto/ECDsaKey",
    "crypto/KeyAuthorization",
    "crypto/AlgorithmFactory",
    "AcmeHttpResponse",
    "AcmeHttpException",
    "AcmeDirectory",
    "AcmeAccount",
    "AcmeIdentifier",
    "AcmeChallenge",
    "AcmeCsrOptions"
    "AcmeOrder",
    "AcmeAuthorization",
    "AcmeState",
    "AcmeState.InMemory",
    "AcmeState.DiskPersisted"
)

$classMergeFile = "$classPath\..\AllClasses.ps1";
$internalFunctions = "$script:PSModuleRoot\internal\AllFunctions.ps1"
$exportedFunctions = "$script:PSModuleRoot\AllFunctions.ps1"

Merge-ModuleFiles -Files @($classes | ForEach-Object { "$classPath\$_.ps1" }) -OutFile $classMergeFile
Merge-ModuleFiles -Path "$script:PSModuleRoot\internal\functions\*" -OutFile $internalFunctions
Merge-ModuleFiles -Path "$script:PSModuleRoot\functions\*" -OutFile $exportedFunctions

$classes | ForEach-Object { Get-Content "$classPath\$_.ps1" } | Set-Content $classMergeFile
. Import-ModuleFile $classMergeFile;
. Import-ModuleFile $internalFunctions;
. Import-ModuleFile $exportedFunctions;