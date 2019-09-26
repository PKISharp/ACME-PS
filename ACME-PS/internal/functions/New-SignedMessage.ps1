function New-SignedMessage {
    [CmdletBinding(SupportsShouldProcess=$false)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseShouldProcessForStateChangingFunctions", "", Scope="Function", Target="*")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $Url,

        [Parameter(Mandatory = $true, Position = 1)]
        [ISigningKey] $SigningKey,

        [Parameter(Position = 2)]
        [string] $KeyId,

        [Parameter(Position = 3)]
        [string] $Nonce,

        [Parameter(Mandatory = $true, Position = 4)]
        [ValidateNotNull()]
        [object] $Payload
    )

    $headers = @{};
    $headers.Add("alg", $SigningKey.JwsAlgorithmName());
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
        $headers.Add("jwk", $SigningKey.ExportPublicJwk());
    }

    if($Payload -eq $null -or $Payload -is [string]) {
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
    $signedPayload.add("protected", (ConvertTo-UrlBase64 -InputText $jsonHeaders));
    if($messagePayload -eq $null -or $messagePayload.Length -eq 0) {
        $signedPayload.add("payload", "");
    } else {
        $signedPayload.add("payload", (ConvertTo-UrlBase64 -InputText $messagePayload));
    }
    $signedPayload.add("signature", (ConvertTo-UrlBase64 -InputBytes $SigningKey.Sign("$($signedPayload.Protected).$($signedPayload.Payload)")));

    $result = $signedPayload | ConvertTo-Json;
    Write-Debug "Created signed message`n: $result";

    return $result;
}