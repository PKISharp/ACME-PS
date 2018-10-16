function New-Order {
    <#
        .SYNOPSIS
            Creates a new order object.

        .DESCRIPTION
            Creates a new order object to be used for signing a new certificate including all submitted identifiers.


        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER Identifiers
            The list of identifiers, which will be covered by the certificates subject alternative names.

        .PARAMETER PrimaryDomain
            The domain to be used for the Subject of the certificate. If not supplied, the first Identifier will be used instead.

        .PARAMETER NotBefore
            Earliest date the certificate should be considered valid.

        .PARAMETER NotAfter
            Latest date the certificate should be considered valid.


        .EXAMPLE
            PS> New-Order -Identifiers (New-Identifier "dns" "www.test.com"), (New-Identifier "dns" "www.test2.com") -PrimaryDomain "www.test2.com"

        .EXAMPLE
            PS> New-Order -Identifiers (New-Identifier "dns" "www.test.com")
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true)]
        [AcmeIdentifier[]] $Identifiers,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $PrimaryDomain,

        [Parameter()]
        [System.DateTimeOffset] $NotBefore,

        [Parameter()]
        [System.DateTimeOffset] $NotAfter
    )

    $payload = @{
        "identifiers" = @($Identifiers | Select-Object @{N="type";E={$_.Type}}, @{N="value";E={$_.Value}})
    };

    if($NotBefore -and $NotAfter) {
        $payload.Add("notBefore", $NotBefore.ToString("o"));
        $payload.Add("notAfter", $NotAfter.ToString("o"));
    }

    $requestUrl = $State.GetServiceDirectory().NewOrder;

    if($PSCmdlet.ShouldProcess("Order", "Create new order with ACME Service")) {
        $response = Invoke-SignedWebRequest $requestUrl $State $payload;

        $order = [AcmeOrder]::new($response);

        if ($PrimaryDomain -and $order.Identifiers.Value -icontains $PrimaryDomain) {
            $order.PrimaryDomain = $PrimaryDomain
        }
        else {
            $order.PrimaryDomain = $Identifiers[0].Value
        }

        $state.AddOrder($order);

        return $order;
    }
}