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

if (!(Test-Path -Path "$script:PSModuleRoot\AllFunctions.ps1")) {
    foreach ($class in (Get-ChildItem "$script:PSModuleRoot\internal\classes\*.ps1")) {
        . Import-ModuleFile $class.FullName;
    }

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