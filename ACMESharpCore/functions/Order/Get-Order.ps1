function Get-Order {
    <#
        .SYNOPSIS
            Fetches an order from acme service
        
        .DESCRIPTION
            Uses the given url to fetch an existing order object from the acme service.

        
        .PARAMETER Url
            The resource url of the order to be fetched.
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