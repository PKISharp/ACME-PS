function Get-Authorization {
    <#
        .SYNOPSIS
            Fetches authorizations from acme service.

        .DESCRIPTION
            Fetches all authorizations for an order or an single authorizatin by its resource url.


        .PARAMETER Order
            The order, whoose authorizations will be fetched

        .PARAMETER Url
            The authorization resource url to fetch the data.


        .EXAMPLE
            PS> Get-Authorization $myOrder

        .EXAMPLE
            PS> Get-Authorization https://acme.server/authz/1243
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
        $Url
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "FromOrder" {
                $Order.AuthorizationUrls | ForEach-Object { Get-Authorization -Url $_ }
            }
            Default {
                <# TODO: Replace through POST-as-GET #>
                $response = Invoke-AcmeWebRequest $Url -Method GET;
                return [AcmeAuthorization]::new($response);
            }
        }
    }
}