function Get-TermsOfService {
    <#
        .SYNOPSIS
            Show the ACME service TOS

        .DESCRIPTION
            Show the ACME service TOS


        .PARAMETER AcmeDirectory
            The ACME directory object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.


        .EXAMPLE
            PS> Get-TermsOfService -AcmeDirectory $acmeDirectory
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [AcmeDirectory]
        $AcmeDirectory = (Get-ServiceDirectory)
    )

    Start-Process $AcmeDirectory.Meta.TermsOfService;
}
