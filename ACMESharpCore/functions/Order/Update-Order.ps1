function Update-Order {
    <#
        .SYNOPSIS
            Updates an order from acme service

        .DESCRIPTION
            Updates the given order instance by querying the acme service.
            The result will be used to update the order stored in the state object

        .PARAMETER State
            State instance containing service directory, account key, account and nonce.

        .PARAMETER Order
            The order to be updated.

        .PARAMETER PassThrough
            If present, the updated order will be written to the output.
    #>
    [CmdletBinding()]
    [OutputType("AcmeOrder")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [AcmeOrder]
        $Order,

        [Parameter()]
        [switch]
        $PassThrough
    )

    $response = Invoke-AcmeWebRequest $Order.ResourceUrl -Method GET;
    $Order.UpdateOrder($response);
    $State.SetOrder($Order);

    if($PassThrough) {
        return $Order;
    }
}