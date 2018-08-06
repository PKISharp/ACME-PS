function Set-AccountKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [uri] $Url, 

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [AcmeAccount] $TargetAccount,

        [Parameter(Mandatory = $true, Position = 4)]
        [ValidateNotNullOrEmpty()]
        [string] $Nonce = $Script:Nonce,

        [Parameter(Mandatory = $true)]
        [ACMESharpCore.Crypto.JOSE.JwsAlgorithm] $NewJwsAlgorithm
    )

    $innerPayload = @{
        "account" = $TargetAccount.$KeyId;
        "oldKey" = $AccountKey.ExportPuplicKey()
    };

    $payload = New-SignedMessage -Url $Url -AccountKey $NewJwsAlgorithm -Payload $innerPayload;
    $requestBody = New-SignedMessage -Url $Url -AccountKey $AccountKey -KeyId $KeyId -Nonce $Nonce -Payload $payload;

    $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST;

    return Get-Account -Url $TargetAccount.ResourceUrl -AccountKey $NewJwsAlgorithm -KeyId $KeyId -Nonce $response.NextNonce
}