function Enable-AccountHandling {
    <#
        .SYNOPSIS  
            Enables automatic account handling.
    
        .DESCRIPTION
            Enables automatic account handling with the given account. 
            This will set module-scoped variables, so other cmdlets of this module will be able to just use the account, without explicitly passing it.


        .PARAMETER AccountKey
            The account to register for automatic handling.

        
        .EXAMPLE
            PS> Enable-AccountHandling $myAccount
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [AcmeAccount]
        $Account
    )

    process {
        Write-Verbose "Enabling automatic account handling."

        $Script:AutoAccount = $true;
        $Script:Account = $Account;
    }
}