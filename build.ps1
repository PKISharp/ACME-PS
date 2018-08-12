[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $ModuleOutPath = "./publish",

    [Parameter()]
    [Switch] $PublishModule,

    [Parameter()]
    [Switch] $SignModule,

    [Parameter()]
    [Switch] $SkipDependencies
)

$ErrorActionPreference = 'Stop';
$InformationPreference = 'Continue';

$ModuleSourcePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "./ACMESharpCore"));
$ModuleOutPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $ModuleOutPath));

<# Clean Publish folder #>
if(Test-Path $ModuleOutPath) {
    Write-Information "Deleting $ModuleOutPath/*";
    Get-ChildItem "$ModuleOutPath/*" -Recurse | Remove-Item -Force -Recurse | Out-Null
} else {
    New-Item $ModuleOutPath -ItemType Directory
}

<# Publish the module #>
Import-Module "$PSScriptRoot/ACMESharpCore" -Force -ErrorAction 'Stop' # This will create the All* files.

Copy-Item -Path "$ModuleSourcePath/ACMESharpCore.psd1" -Destination "$ModuleOutPath/ACMESharpCore.psd1" -Force;
Copy-Item -Path "$ModuleSourcePath/TypeDefinitions.ps1" -Destination "$ModuleOutPath/" -Force;

$ModuleFiles = @(
    "internal/AllClasses.ps1",
    "internal/AllFunctions.ps1",
    "AllFunctions.ps1"
)

$ModuleFiles | ForEach-Object { Get-Content "$ModuleSourcePath/$_" } | Set-Content "$ModuleOutPath/ACMESharpCore.psm1";

if($SignModule) {
    $files = "$ModuleOutPath/ACMESharpCore.ps*"
    $cert = Get-Item Cert:\CurrentUser\My\017E67F53FCB161D63E7881F1F96A8452859200D

    Set-AuthenticodeSignature -FilePath $files -Certificate $cert
}