function Get-Order {
    <#
        .SYNOPSIS
            Fetches an order from acme service

        .DESCRIPTION
            Uses the given url to fetch an existing order object from the acme service.


        .PARAMETER Url
            The resource url of the order to be fetched.

        
        .EXAMPLE
            PS> Get-Order -Url "https://service.example.com/kid/213/order/123"
    #>
    [CmdletBinding()]
    [OutputType("AcmeOrder")]
    param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = "FromUrl")]
        [ValidateNotNullOrEmpty()]
        [uri]
        $Url
    )

    $response = Invoke-AcmeWebRequest $Url -Method GET;
    return [AcmeOrder]::new($response);
}