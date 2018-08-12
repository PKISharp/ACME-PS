function Initialize-State {
    <#
        .SYNOPSIS
            Initializes state from saved date.
        
        .DESCRIPTION
            Initializes state from saved data.
            Use this if you already have an exported account key and an account.

        
        .PARAMETER DirectoryPath
            Path to an exported service directory
        
        .PARAMETER AccountKeyPath
            Path to an exported account key

        
        .EXAMPLE
            PS> Initialize-AutomaticHandlers C:\myServiceDirectory.xml C:\myKey.json
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DirectoryPath,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AccountKeyPath
    )

    $ErrorActionPreference = 'Stop';

    $state = New-State

    Get-ServiceDirectory -State $state -Path $DirectoryPath
    New-Nonce -State $state
    Import-AccountKey -State $state -Path $AccountKeyPath 
    Get-Account -State $state

    return $state;
}