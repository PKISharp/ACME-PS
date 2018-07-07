function Get-TermsOfService {
    <#
        .SYNOPSIS
        Reads the TOS from the ACME-Server

        .DESCRIPTION
        Reads the TOS from the given ACME-Server
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $ACMEStorePath = "."
    )

    process {
        Validate-StorePath $ACMEStorePath
    }
}