function Update-Order {
    <#
        .SYNOPSIS
            Updates an order from acme service

        .DESCRIPTION
            Uses the order to fetch an update from the acme service.


        .PARAMETER Order
            The order to be updated.
    #>
    [CmdletBinding()]
    [OutputType("AcmeOrder")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [AcmeOrder]
        $Order,

        [Parameter()]
        [switch]
        $PassThrough
    )

    $response = Invoke-AcmeWebRequest $Order.ResourceUrl -Method GET;
    $Order.UpdateOrder($response);

    if($PassThrough) {
        return $Order;
    }
}