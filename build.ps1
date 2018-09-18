[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $ModuleOutPath = "./publish/ACME-PS",

    [Parameter()]
    [Switch] $SignModule
)

$ErrorActionPreference = 'Stop';
$InformationPreference = 'Continue';

$ModuleSourcePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "./ACME-PS"));
$ModuleOutPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $ModuleOutPath));

<# Clean Publish folder #>
if(Test-Path $ModuleOutPath) {
    Write-Information "Delete old files from $ModuleOutPath";
    Get-ChildItem "$ModuleOutPath/*" -Recurse | Remove-Item -Force -Recurse | Out-Null
} else {
    Write-Information "Creating $ModuelOutPath";
    New-Item $ModuleOutPath -ItemType Directory
}

<# Publish the module #>
Import-Module "$PSScriptRoot/ACME-PS" -Force -ErrorAction 'Stop' -Verbose:$false # This will create the All* files.

Write-Information "Copying $ModuleSourcePath/ACME-PS.psd1"
Copy-Item -Path "$ModuleSourcePath/ACME-PS.psd1" -Destination "$ModuleOutPath/" -Force;

Write-Information "Copying $ModuleSourcePath/TypeDefinitions.ps1"
Copy-Item -Path "$ModuleSourcePath/TypeDefinitions.ps1" -Destination "$ModuleOutPath/" -Force;

Write-Information "Copying $ModuleSourcePath/Prerequisites.ps1"
Copy-Item -Path "$ModuleSourcePath/Prerequisites.ps1" -Destination "$ModuleOutPath/" -Force;

$ModuleFiles = @(
    "internal/AllClasses.ps1",
    "internal/AllFunctions.ps1",
    "AllFunctions.ps1"
)

Write-Information "Merging Module content files $([string]::Join(", ", $ModuleFiles))"
$ModuleFiles | ForEach-Object { Get-Content "$ModuleSourcePath/$_" } | Set-Content "$ModuleOutPath/ACME-PS.psm1";

if($SignModule) {
    Write-Information "Signing all *.ps* files"
    $files = "$ModuleOutPath/*.ps*"
    $cert = Get-Item Cert:\CurrentUser\My\39BCA611578AD62BA5126A406DBD4CC5DAFB859C

    Set-AuthenticodeSignature -FilePath $files -Certificate $cert | Out-Null
}

Write-Information "Finished";