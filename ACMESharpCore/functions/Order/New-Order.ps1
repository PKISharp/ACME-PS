function New-Order {
    <#
        .SYNOPSIS
            Creates a new order object.

        .DESCRIPTION
            Creates a new order object to be used for signing a new certificate including all submitted identifiers.


        .PARAMETER State
            State instance containing service directory, account key, account and nonce.

        .PARAMETER Identifiers
            The list of identifiers, which will be covered by the certificates subject alternative names.

        .PARAMETER NotBefore
            Earliest date the certificate should be considered valid.

        .PARAMETER NotAfter
            Latest date the certificate should be considered valid.


        .EXAMPLE
            PS> New-Order -Directory $myDirectory -AccountKey $myAccountKey -KeyId $myKid -Nonce $myNonce -Identifiers $myIdentifiers

        .EXAMPLE
            PS> New-Order -Identifiers (New-Identifier "dns" "www.test.com")
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true)]
        [AcmeIdentifier[]] $Identifiers,

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
    $response = Invoke-SignedWebRequest $requestUrl $State $payload;

    $order = [AcmeOrder]::new($response);
    $state.AddOrder($order);
    
    return $order;
}