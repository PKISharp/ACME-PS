function Get-TermsOfService {
    <#
        .SYNOPSIS
            Show the ACME service TOS

        .DESCRIPTION
            Show the ACME service TOS

        
        .PARAMETER Directory
            The directory to read the TOS from.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [AcmeDirectory]
        $Directory = $Script:ServiceDirectory
    )

    process {
        Start-Process $Directory.Meta.TermsOfService;
    }
}