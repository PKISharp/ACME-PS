<#
    .SYNOPSIS
        Initializes state from saved date.

    .DESCRIPTION
        Initializes state from saved data.
        Use this if you already have an account key and an account.


    .PARAMETER Path
        Path to an exported runtime state directory.

    .EXAMPLE
        PS> Get-State
#>
function Get-State {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path = (Get-RuntimeDataPath)
    )

    $ErrorActionPreference = 'Stop';

    Write-Verbose "Loading ACME-PS state from $Path";
    $paths = [AcmeStatePaths]::new($Path);
    return [AcmeDiskPersistedState]::new($paths, $false, $true);
}
