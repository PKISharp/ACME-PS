[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $ModuleOutPath = "./publish",

    [Parameter()]
    [Switch] $PublishModule
)

$ErrorActionPreference = 'Stop';
$InformationPreference = 'Continue';

$ModuleSourcePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "./ACMESharpCore"));
$BinSourcePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "./ACMESharpCore.Crypto"));

$ModuleOutPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $ModuleOutPath));
$BinOutPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "./ACMESharpCore/bin/ACMESharpCore.Crypto"));

if($PublishModule) {
    $binOutPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "$ModuleOutPath/bin/ACMESharpCore.Crypto"));
}

<# Clean Publish folder #>

if($PublishModule) {
    if(Test-Path $ModuleOutPath) {
        Write-Information "Deleting $ModuleOutPath/*";
        Get-ChildItem "$ModuleOutPath/*" | Remove-Item -Force -Recurse | Out-Null
    } else {
        New-Item $ModuleOutPath -ItemType Directory
    }
}

<# Building the dependencies #>
    
if(Test-Path $binOutPath) {
    Remove-Module "ACMESharpCore" -Force -ErrorAction 'SilentlyContinue'

    Write-Information "Deleting $binOutPath/*";
    Get-ChildItem "$binOutPath/*" | Remove-Item -Force -Recurse | Out-Null
}

Write-Information "Calling dotnet publish $BinSourcePath -o $binOutPath";
$args = @("publish", "`"$BinSourcePath`"", "-o", "`"$binOutPath`"")
& "dotnet.exe" $args


<# Publish the module #>

if($PublishModule) {
    Import-Module "$PSScriptRoot/ACMESharpCore" -Force -ErrorAction 'Stop'

    Copy-Item -LiteralPath "$ModuleSourcePath/ACMESharpCore.psd1" -Destination "$ModuleOutPath/ACMESharpCore.psd1" -Force;
    
    $ModuleFiles = @(
        "internal/AllClasses.ps1",
        "internal/AllFunctions.ps1",
        "AllFunctions.ps1"
    )

    $ModuleFiles | ForEach-Object { Get-Content "$ModuleSourcePath/$_" } | Set-Content "$ModuleOutPath/ACMESharpCore.psm1";
}