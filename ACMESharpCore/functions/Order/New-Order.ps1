function New-Order {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNull()]
        [AcmeDirectory]
        $Directory = $Script:ServiceDirectory,

        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [ACMESharpCore.Crypto.IAccountKey] $AccountKey = $Script:AccountKey,

        [Parameter(Position = 2, ParameterSetName="GetAccount")]
        [ValidateNotNullOrEmpty()]
        [string] $KeyId = $Script:KeyId,

        [Parameter(Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string] $Nonce = $Script:Nonce,

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

    $requestBody = New-SignedMessage -Url $Url -JwsAlgorith $AccountKey -KeyId $KeyId -Nonce $Nonce -Payload $payload;
    $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST;

    return [AcmeOrder]::new($response);
}