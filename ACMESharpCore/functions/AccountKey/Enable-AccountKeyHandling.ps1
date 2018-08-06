function Enable-AccountKeyHandling {
    <#
        .SYNOPSIS  
            Enables automatic account key handling.
    
        .DESCRIPTION
            Enables automatic account key handling with the given account key. 
            This will set module-scoped variables, so other cmdlets of this module will be able to just use the account key, without explicitly passing it.


        .PARAMETER AccountKey
            The account key to register for automatic key handling.

        
        .EXAMPLE
            PS> Enable-AccountKeyHandling $myAccountKey
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [AcmeSharpCore.Crypto.IAccountKey]
        $AccountKey
    )

    process {
        Write-Verbose "Enabling automatic account key handling."

        $Script:AutoAccountKey = $true;
        $Script:AccountKey = $accountKey;
    }
}