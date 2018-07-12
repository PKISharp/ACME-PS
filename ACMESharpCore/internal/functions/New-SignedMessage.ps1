function New-SignedMessage {
    param(
        [Parameter(Mandatory = $true)]
        [ValdiateNotNullOrEmpty]
        [string] $Url,

        [Prameter(Mandatory = $true)]
        [ValidateNotNull]
        [object] $Payload,

        [Parameter(Mandatory = $true)]
        [ACMESharp.Crypto.JOSE.JwsAlgorithm] $JwsAlgorithm,

        [Parameter]
        [string] $Nonce,

        [Parameter]
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
        $header.Add("jwk", ($JwsAlgorithm.ExportPublicJwk() | ConvertTo-Json -Compress));
    }

    [string]$messagePayload;
    if($Payload.GetType() -ne [string]) {
        $messagePayload = $Payload | ConvertTo-Json;
    } else {
        $messagePayload = $Payload;
    }

    $signedPayload = [ACMESharp.Crypto.JOSE.JwsSignedPayload]::new();

    $signedPayload.Header = $null;
    $signedPayload.Protected = $headers | ConvertTo-Json | ConvertTo-UrlBase64;
    $signedPayload.Payload = $messagePayload | ConvertTo-UrlBase64;
    $signedPayload.Signature = ConvertTo-UrlBase64 -InputBytes $JwsAlgorithm.Sign("$($signedPayload.Protected).$($signedPayload.Payload)");

    return $signedPayload | ConvertTo-Json;
}