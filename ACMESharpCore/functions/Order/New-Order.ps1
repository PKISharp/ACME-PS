function New-Order {
    <#
        .SYNOPSIS
            Creates a new order object.

        .DESCRIPTION
            Creates a new order object to be used for signing a new certificate including all submitted identifiers.

        
        .PARAMETER Directory
            The service directory of the ACME service. Can be handled by the module, if enabled.

        .PARAMETER AccountKey
            Your account key for JWS Signing. Can be handled by the module, if enabled.
        
        .PARAMETER KeyId
            Your "kid" as defined in the acme standard (usually the url to your account)

        .PARAMETER Nonce
            Replay nonce from ACME service. Can be handled by the module, if enabled.
        
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
        [Parameter(Position = 0)]
        [ValidateNotNull()]
        [AcmeDirectory]
        $Directory = $Script:ServiceDirectory,

        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [IAccountKey] $AccountKey = $Script:AccountKey,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string] $KeyId = $Script:KeyId,

        [Parameter(Position = 3)]
        [ValidateNotNullOrEmpty()]
        [AcmeNonce] $Nonce = $Script:Nonce,

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

    $requestUrl = $Directory.NewOrder;

    $requestBody = New-SignedMessage -Url $requestUrl -AccountKey $AccountKey -KeyId $KeyId -Nonce $Nonce.Next -Payload $payload;
    $response = Invoke-AcmeWebRequest $requestUrl $requestBody -Method POST;

    return [AcmeOrder]::new($response);
}