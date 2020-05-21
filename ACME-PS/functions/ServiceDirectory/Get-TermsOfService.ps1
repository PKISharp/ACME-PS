function Get-TermsOfService {
    <#
        .SYNOPSIS
            Show the ACME service TOS

        .DESCRIPTION
            Show the ACME service TOS


        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.


        .EXAMPLE
            PS> Get-TermsOfService -State $state
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [AcmeState]
        $State
    )

    process {
        Start-Process $State.GetServiceDirectory().Meta.TermsOfService;
    }
}
