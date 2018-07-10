function Create-SignedMessage {
    param(
        [Parameter](Mandatory = $true)
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

    $encoder = [System.Text.Encoding]::UTF8;
    $signedPayload = [ACMESharp.Crypto.JOSE.JwsSignedPayload]::new();
    
    #TODO: .. unfinished business here ..

    $signedPayload.Header = $null;
    $signedPayload.Protected = $encoder.GetBytes($headers | ConvertTo-Json);
    $signedPayload.Pay

    return $signedPayload | ConvertTo-Json
}