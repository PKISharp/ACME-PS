function Initialize-AutomaticHandlers {
    <#
        .SYNOPSIS
            Initializes automatic handlers.
        
        .DESCRIPTION
            Initializes automatic service directory handling, nonce handling, accountkey handling and account handling.
            Use this if you already have an exported account key to initialize all automatic handling.

        
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

    Get-ServiceDirectory -Path $DirectoryPath -AutomaticDirectoryHandling -AutomaticNonceHandling -ErrorAction 'Stop' | Out-Null
    Import-AccountKey -Path $AccountKeyPath -AutomaticAccountKeyHandling -ErrorAction 'Stop' | Out-Null
    Get-Account -AutomaticAccountHandling | Out-Null
}