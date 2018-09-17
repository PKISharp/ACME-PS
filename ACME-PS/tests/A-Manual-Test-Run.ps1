$ModuleBase = Split-Path -Path $PSScriptRoot -Parent

Remove-Module ACME-PS -ErrorAction Ignore
Import-Module "$ModuleBase\ACME-PS.psd1"
#Import-Module "$ModuleBase\ACME-PS.psm1" -DisableNameChecking

Invoke-Pester -Path "$ModuleBase\tests"