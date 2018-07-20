param(
    [Switch] $SkipAutoNonce
)

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
 
$script:PSModuleRoot = $PSScriptRoot

if (!(Test-Path -Path "$script:PSModuleRoot\FullModule.ps1")) {
    $classPath = "$script:PSModuleRoot\internal\classes";
    $classes = @(
        "AcmeHttpResponse",
        "AcmeObject",
        "AcmeDirectory",
        "AcmeAccount"
    )

    Clear-Content "$classPath\..\AllClasses.ps1"
    $classes | % { Get-Content "$classPath\$_.ps1" } | Set-Content "$classPath\..\AllClasses.ps1"

    #TODO: This is a workaround for loading the functions. Needed it, because using a class inside the ctor of another class was not possible.
    . Import-ModuleFile "$classPath\..\AllClasses.ps1";

    # All internal functions privately available within the toolset
    foreach ($function in (Get-ChildItem "$script:PSModuleRoot\internal\functions\*.ps1")) {
        . Import-ModuleFile $function.FullName;
    }
    
    # All exported functions
    foreach ($function in (Get-ChildItem "$script:PSModuleRoot\functions\*.ps1")) {
        . Import-ModuleFile $function.FullName;
    }
}
else {
    # This is created by the build script and will improve module loading time
    . "$script:PSModuleRoot\AllFunctions.ps1"
}

$Script:AutoNonce = (-not $SkipAutoNonce)