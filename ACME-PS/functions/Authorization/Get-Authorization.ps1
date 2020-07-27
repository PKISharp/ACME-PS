function Get-ACMEAuthorization {
    <#
        .SYNOPSIS
            Fetches authorizations from acme service.

        .DESCRIPTION
            Fetches all authorizations for an order or an single authorizatin by its resource url.


        .PARAMETER Order
            The order, whoose authorizations will be fetched

        .PARAMETER Url
            The authorization resource url to fetch the data.

        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.


        .EXAMPLE
            PS> Get-ACMEAuthorization $myOrder $myState

        .EXAMPLE
            PS> Get-ACMEAuthorization https://acme.server/authz/1243 $myState
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ParameterSetName = "FromOrder")]
        [ValidateNotNull()]
        [AcmeOrder]
        $Order,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "FromUrl")]
        [ValidateNotNullOrEmpty()]
        [uri]
        $Url,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountExists()})]
        [AcmeState]
        $State
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "FromOrder" {
                $Order.AuthorizationUrls | ForEach-Object { Get-ACMEAuthorization -Url $_ $State }
            }
            Default {
                $response = Invoke-ACMESignedWebRequest -Url $Url -State $State
                return [AcmeAuthorization]::new($response);
            }
        }
    }
}
