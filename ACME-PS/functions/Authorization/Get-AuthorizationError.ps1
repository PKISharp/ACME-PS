function Get-ACMEAuthorizationError {
    <#
        .SYNOPSIS
            Fetches authorizations erros from acme service.

        .DESCRIPTION
            Fetches all authorization errors for an order.


        .PARAMETER Order
            The order, whoose authorizations errors will be fetched (needs to be in invalid state)

        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.


        .EXAMPLE
            PS> Get-ACMEAuthorizationError $myOrder $myState
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountExists()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ParameterSetName = "FromOrder")]
        [ValidateNotNull()]
        [AcmeOrder]
        $Order
    )

    process {
        $Order = Update-ACMEOrder -State $state -Order $Order -PassThru

        if ($Order.Status -ine "invalid") {
            return;
        }

        $authorizations = $Order.AuthorizationUrls | ForEach-Object { Get-ACMEAuthorization -Url $_ $State }
        $invalidAuthorizations = $authorizations | Where-Object { $_.Status -ieq "invalid" };
        $invalidAuthorizations | ForEach-Object { $_.Challenges | Where-Object { $_.Status -ieq "invalid" } }
    }
}
