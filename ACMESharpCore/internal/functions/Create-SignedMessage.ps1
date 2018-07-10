function Create-SignedMessage {
    param(
        [Parameter(Mandatory = $true)]
        [ValdiateNotNullOrEmpty]
        [string] $Url,

        [Prameter(Mandatory = $true)]
        [ValidateNotNull]
        [object] $Payload,

        [Parameter(Mandatory = $true)]
        [ACMESharp.Crypto.JOSE.JwsExport] $JwsExport,

        [Parameter]
        [string] $Nonce,

        [Parameter]
        [string] $AccountKId
    )

    $jwsTool = [ACMESharp.Crypto.JOSE.JwsTool]::new($JwsExport);

    $headers = @{
        "alg"=$jwsTool.JwsAlg;
        "url"=$Url;
    }

    if($Nonce) { $headers.Add("nonce", $Nonce); }
    if($AccountKId) {
        $headers.Add("kid", $AccountKId);
    } else {
        $header.Add("jwk", $jwsTool.ExportJwk());
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

    $signatureBytes = [System.Text.Encoding]::ASCII.GetBytes("$($signedPayload.Protected).$($signedPayload.Payload)");
    $signedPayload.Signature = ConvertTo-UrlBase64 -InputBytes $jwsTool.Sign($signatureBytes);

    return $signedPayload | ConvertTo-Json
}