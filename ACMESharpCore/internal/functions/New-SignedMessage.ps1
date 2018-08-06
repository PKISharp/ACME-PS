function New-SignedMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $Url,

        [Parameter(Mandatory = $true, Position = 1)]
        [ACMESharpCore.Crypto.JOSE.JwsAlgorithm] $JwsAlgorithm,

        [Parameter(Position = 2)]
        [string] $KeyId,

        [Parameter(Position = 3)]
        [string] $Nonce,

        [Parameter(Mandatory = $true, Position = 4)]
        [ValidateNotNull()]
        [object] $Payload
    )

    $headers = @{};
    $headers.Add("alg", $JwsAlgorithm.JwsAlg);
    $headers.Add("url", $Url);

    if($Nonce) {
        Write-Debug "Nonce $Nonce will be used";
        $headers.Add("nonce", $Nonce); 
    }

    if($KeyId) {
        Write-Debug "KeyId $KeyId will be used";
        $headers.Add("kid", $KeyId);
    }

    if(-not ($KeyId)) {
        Write-Debug "No KeyId present, addind JWK.";
        $headers.Add("jwk", $JwsAlgorithm.ExportPublicJwk());
    }

    if($Payload -is [string]) {
        Write-Debug "Payload was string, using without Conversion."
        $messagePayload = $Payload;
    } else {
        Write-Debug "Payload was object, converting to Json";
        $messagePayload = $Payload | ConvertTo-Json -Compress;
    }

    $jsonHeaders = $headers | ConvertTo-Json -Compress 

    Write-Debug "Payload is now: $messagePayload";
    Write-Debug "Headers are: $jsonHeaders"

    $signedPayload = @{};

    $signedPayload.add("header", $null);
    $signedPayload.add("protected", ($jsonHeaders | ConvertTo-UrlBase64));
    $signedPayload.add("payload", ($messagePayload | ConvertTo-UrlBase64));
    $signedPayload.add("signature", (ConvertTo-UrlBase64 -InputBytes $JwsAlgorithm.Sign("$($signedPayload.Protected).$($signedPayload.Payload)")));

    $result = $signedPayload | ConvertTo-Json;
    Write-Debug "Created signed message`n: $result";
    
    return $result;
}