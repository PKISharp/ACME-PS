function Enable-NonceHandling {
    <#
        .SYNOPSIS  
            Enables automatic nonce handling.
    
        .DESCRIPTION
            Enables automatic nonce handling with the given nonce. 
            This will set module-scoped variables, so other cmdlets of this module will be able to use the nonce, without explicitly passing it.
            The nonce will automatically updated to always reflect nextNonce of acme http responses.


        .PARAMETER Nonce
            The nonce to register for automatic handling.

        
        .EXAMPLE
            PS> Enable-NonceHandling $myNonce
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [AcmeNonce]
        $Nonce,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [uri]
        $NewNonceUrl
    )

    process {
        Write-Verbose "Enabling automatic nonce handling."

        $Script:AutoNonce = $true;
        $Script:NewNonceUrl = $NewNonceUrl;
        $Script:Nonce = $Nonce.Next;
    }
}