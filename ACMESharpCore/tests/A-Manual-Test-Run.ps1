$ModuleBase = Split-Path -Path $PSScriptRoot -Parent

Remove-Module AcmeSharpCore -ErrorAction Ignore
Import-Module "$ModuleBase"
#Import-Module "$ModuleBase\ACMESharpCore.psm1" -DisableNameChecking

Invoke-Pester -Path "$ModuleBase\tests"