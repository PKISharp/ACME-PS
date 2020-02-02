function Find-Order {
    <#
        .SYNOPSIS
            Fetches an order from acme service

        .DESCRIPTION
            Uses the given url to fetch an existing order object from the acme service.


        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER DNSNames
            DNS names that all must appear in the order. If multiple orders would match, the latest one will
            be returned. Returns null, if none is found.

        .PARAMETER Identifiers
            Identifiers that all must appear in the order. If multiple orders woul match, the latest one will
            be returned. Returns null, if none is found.

        .EXAMPLE
            PS> Get-Order -Url "https://service.example.com/kid/213/order/123"
    #>
    [CmdletBinding()]
    [OutputType("AcmeOrder")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "FromString")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $DNSNames,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "FromIdentifier")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Identifiers
    )

    if($PSCmdlet.ParameterSetName -eq "FromString") {
        return $State.FindOrder($DNSNames)
    }

    return $State.FindOrder($Identifiers);
}