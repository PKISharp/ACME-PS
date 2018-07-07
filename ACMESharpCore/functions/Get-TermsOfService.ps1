function Get-TermsOfService {
    <#
        .SYNOPSIS
        Reads the TOS from the ACME-Server

        .DESCRIPTION
        Reads the TOS from the given ACME-Server
    #>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = "ByURL", Mandatory = $true)]
        [string]$acmeServerTOSUrl,

        [Parameter(ParameterSetName = "ByReg", Mandatory = $true)]
        [object]$acmeRegistration
    )

    { }
}