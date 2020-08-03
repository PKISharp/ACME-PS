try {
    $ModuleBase = Split-Path -Path $PSScriptRoot -Parent

    Remove-Module ACME-PS -ErrorAction Ignore
    Import-Module "$ModuleBase\ACME-PS.psd1" -Force -ErrorAction 'Stop'

    Invoke-Pester -Path "$ModuleBase\tests"
}
catch {
    Write-Error $error[0];
}