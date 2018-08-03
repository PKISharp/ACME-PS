[CmdletBinding()]
param(
    [Parameter(ParameterSetName = "Publish")]
    [ValidateNotNullOrEmpty()]
    [string] $OutPath = "./publish",

    [Parameter(ParameterSetName = "Publish")]
    [Switch] $PublishModule,


    [Parameter(ParameterSetName = "BuildDeps")]
    [Switch] $BuildDependencies,
    
    [Switch] $Clean
)

$InformationPreference = 'Continue';

if($PSCmdlet.ParameterSetName -eq "BuildDeps") {
    $SourcePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "./ACMESharpCore.Crypto"));
    $OutPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "./ACMESharpCore/bin/ACMESharpCore.Crypto"));

    if($Clean -and (Test-Path $OutPath)) {
        Write-Information "Deleting $OutPath/*";
        Get-ChildItem "$OutPath/*" | Remove-Item -Force | Out-Null
    }

    if($BuildDependencies) {
        Write-Information "Calling dotnet publish $SourcePath -o $Outpath";
        $args = @("publish", "`"$SourcePath`"", "-o", "`"$Outpath`"")
        & "dotnet.exe" $args
    }
}

if($PSCmdlet.ParameterSetName -eq "Publish") {
    $OutPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $OutPath));

    if($Clean -and (Test-Path $OutPath)) {
        Write-Information "Deleting $OutPath/*";
        Get-ChildItem "$OutPath/*" | Remove-Item -Force | Out-Null
    }

    if($PublishModule) {
        <# Define Publish Process here #>
    }
}