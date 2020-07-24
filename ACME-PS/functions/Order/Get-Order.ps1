function Get-ACMEOrder {
    <#
        .SYNOPSIS
            Fetches an order from acme service

        .DESCRIPTION
            Uses the given url to fetch an existing order object from the acme service.


        .PARAMETER Url
            The resource url of the order to be fetched.

        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.


        .EXAMPLE
            PS> Get-ACMEOrder -Url "https://service.example.com/kid/213/order/123"
    #>
    [CmdletBinding()]
    [OutputType("AcmeOrder")]
    param(
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

    $response = Invoke-ACMESignedWebRequest -Url $Url -State $State;
    return [AcmeOrder]::new($response);
}
