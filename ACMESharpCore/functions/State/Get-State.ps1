function Get-State {
    <#
        .SYNOPSIS
            Initializes state from saved date.

        .DESCRIPTION
            Initializes state from saved data.
            Use this if you already have an exported account key and an account.


        .PARAMETER Path
            Path to an exported service directory

        .EXAMPLE
            PS> Initialize-AutomaticHandlers C:\myServiceDirectory.xml C:\myKey.json
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )

    $ErrorActionPreference = 'Stop';

    Write-Verbose "Loading AcmeSharpCore state from $Path";
    $state = [AcmeState]::FromPath($Path);
    return $state;
}