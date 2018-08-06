function Enable-ServiceDirectoryHandling {
    <#
        .SYNOPSIS  
            Enables automatic service directory handling.
    
        .DESCRIPTION
            Enables automatic service directory handling with the given service directory. 
            This will set module-scoped variables, so other cmdlets of this module will be able to use the service directory, without explicitly passing it.


        .PARAMETER ServiceDirectory
            The service directory to register for automatic handling.

        
        .EXAMPLE
            PS> Enable-ServiceDirectoryHandling $myDirectory
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [AcmeDirectory]
        $ServiceDirectory
    )

    process {
        Write-Verbose "Enabling automatic service directory handling."

        $Script:AutoDirectory = $true;
        $Script:ServiceDirectory = $ServiceDirectory;
    }
}