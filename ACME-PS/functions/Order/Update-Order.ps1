function Update-Order {
    <#
        .SYNOPSIS
            Updates an order from acme service

        .DESCRIPTION
            Updates the given order instance by querying the acme service.
            The result will be used to update the order stored in the state object


        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER Order
            The order to be updated.

        .PARAMETER PassThru
            Forces the updated order to be returned to the pipeline.


        .EXAMPLE
            PS> $myOrder | Update-Order -State $myState -PassThru
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType("AcmeOrder")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountExists()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [AcmeOrder]
        $Order,

        [Parameter()]
        [switch]
        $PassThru
    )

    process {
        if($PSCmdlet.ShouldProcess("Order", "Get updated order form ACME service and store it to state")) {
            $response = Invoke-SignedWebRequest -Url $Order.ResourceUrl -State $State;
            $Order.UpdateOrder($response);
            $State.SetOrder($Order);

            if($PassThru) {
                return $Order;
            }
        }
}
}
