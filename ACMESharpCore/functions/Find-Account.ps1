function Find-Account {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true, Position = 0)]
        [uri] $Url, 

        [Parameter(Mandatory=$true, Position = 1)]
        [ACMESharpCore.Crypto.JOSE.JwsAlgorithm] $JwsAlgorithm,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string] $Nonce = $Script:Nonce
    )

    $payload = @{"onlyReturnExisting" = $true};

    $requestBody = New-SignedMessage -Url $Url -Payload $payload -JwsAlgorithm $JwsAlgorithm -Nonce $Nonce
    $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST

    if($response.StatusCode -eq 200) {
        $Nonce = $response.NextNonce;
        $keyId = $response.Headers["Location"][0];

        return Get-Account -Url $keyId -JwsAlgorithm $JwsAlgorithm -KeyId $keyId -Nonce $Nonce
    } else {
        Write-Error "JWK seems not to be registered for an account."
        return $null;
    }
}