[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $ModuleOutPath = "./build/ACME-PS",

    [Parameter()]
    [Switch] $SignModule
)

begin {
    function Merge-ContentInto {
        param(
            [Parameter(Mandatory = $true, ValueFromPipeline=$true)]
            [ValidateNotNullOrEmpty()]
            [string] $File,

            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [string] $OutFile
        )

        process {
            Get-Content $_ | Add-Content $OutFile
        }
    }
}

process {
    $ErrorActionPreference = 'Stop';
    $InformationPreference = 'Continue';

    $ModuleSourcePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "./ACME-PS"));
    $ModuleOutPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $ModuleOutPath));
    $ModuleOutFile = [System.IO.Path]::Combine($ModuleOutPath, "ACME-PS.psm1");

    <# Clean Publish folder #>
    if(Test-Path $ModuleOutPath) {
        Write-Information "Delete old files from $ModuleOutPath";
        Get-ChildItem "$ModuleOutPath/*" -Recurse | Remove-Item -Force -Recurse | Out-Null
    } else {
        Write-Information "Creating $ModuleOutPath";
        New-Item $ModuleOutPath -ItemType Directory
    }

    <# Publish the module #>
    $ContentFiles = @(
        "$ModuleSourcePath/ACME-PS.psd1",
        "$ModuleSourcePath/TypeDefinitions.ps1",
        "$ModuleSourcePath/Prerequisites.ps1",
        "$ModuleSourcePath/ACME-PS.png",
        "$ModuleSourcePath/../LICENSE"
    )

    # Class files are sequence sensitive
    $ClassPath = [System.IO.Path]::Combine($ModuleSourcePath, "./internal/classes");
    $ClassFiles = @(
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
    );

    $ScriptPaths = @(
        "internal/functions",
        "functions"
    )

    $ScriptFiles = $ScriptPaths | ForEach-Object { Get-ChildItem -Path ([System.IO.Path]::Combine($ModuleSourcePath, $_)) -Recurse -Include "*.ps1" }

    Write-Information "Merge class files into $ModuleOutFile";
    $ClassFiles | ForEach-Object { [System.IO.Path]::Combine($ClassPath, "$_.ps1") } | Merge-ContentInto -OutFile $ModuleOutFile;

    Write-Information "Merge srcipt files into $ModuleOutFile";
    $ScriptFiles | ForEach-Object { $_.FullName } | Merge-ContentInto -OutFile $ModuleOutFile;

    Write-Information "Copy content files";
    $ContentFiles | ForEach-Object { Copy-Item -Path $_ -Destination "$ModuleOutPath/" }

    if($SignModule) {
        Write-Information "Signing all *.ps* files"
        $files = "$ModuleOutPath/*.ps*"
        $cert = Get-Item Cert:\CurrentUser\My\39BCA611578AD62BA5126A406DBD4CC5DAFB859C

        Set-AuthenticodeSignature -FilePath $files -Certificate $cert | Out-Null
    }

    Write-Information "Finished building - running tests";

    <# Run tests
    try {
        Remove-Module ACME-PS -ErrorAction Ignore
        Import-Module "$ModuleOutPath\ACME-PS.psd1" -ErrorAction 'Stop'

        Invoke-Pester -Path "$ModuleSourcePath\tests"
    }
    catch {
        Write-Error $error[0];
    }#>
}