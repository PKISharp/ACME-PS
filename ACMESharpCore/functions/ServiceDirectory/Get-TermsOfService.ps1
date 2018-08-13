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
        [Parameter(Mandatory=$true)]
        [AcmeState]
        $State
    )

    process {
        Start-Process $State.GetServiceDirectory().Meta.TermsOfService;
    }
}