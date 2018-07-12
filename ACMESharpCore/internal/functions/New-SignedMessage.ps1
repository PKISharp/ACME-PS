function New-SignedMessage {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Url,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object] $Payload,

        [Parameter(Mandatory = $true)]
        [ACMESharp.Crypto.JOSE.JwsAlgorithm] $JwsAlgorithm,

        [Parameter()]
        [string] $Nonce,

        [Parameter()]
        [string] $AccountKId
    )

    $headers = @{}
    $headers.Add("alg", $JwsAlgorithm.JwsAlg);
    $headers.Add("url", $Url);

    if($Nonce) { 
        $headers.Add("nonce", $Nonce); 
    }

    if($AccountKId) {
        $headers.Add("kid", $AccountKId);
    } else {
        $headers.Add("jwk", $JwsAlgorithm.ExportPublicJwk());
    }

    [string]$messagePayload;
    if($Payload.GetType() -ne [string]) {
        $messagePayload = $Payload | ConvertTo-Json;
    } else {
        $messagePayload = $Payload;
    }

    $signedPayload = @{};

    $signedPayload.add("header", $null);
    $signedPayload.add("protected", ($headers | ConvertTo-Json | ConvertTo-UrlBase64));
    $signedPayload.add("payload", ($messagePayload | ConvertTo-UrlBase64));
    $signedPayload.add("signature", (ConvertTo-UrlBase64 -InputBytes $JwsAlgorithm.Sign("$($signedPayload.Protected).$($signedPayload.Payload)")));

    return $signedPayload | ConvertTo-Json;
}