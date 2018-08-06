function Set-AccountKey {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [AcmeAccount] $Account = $Script:Account,

        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [AcmeAccount] $AccountKey = $Script:AccountKey,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string] $Nonce = $Script:Nonce,

        [Parameter(Mandatory = $true, ParameterSetName="NewAccountKey")]
        [ACMESharpCore.Crypto.IAccountKey] $NewAccountKey
    )

    $innerPayload = @{
        "account" = $Account.KeyId;
        "oldKey" = $AccountKey.ExportPuplicKey()
    };

    $payload = New-SignedMessage -Url $Url -AccountKey $NewAccountKey -Payload $innerPayload;
    $requestBody = New-SignedMessage -Url $Url -AccountKey $AccountKey -KeyId $Account.KeyId -Nonce $Nonce -Payload $payload;

    $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST;

    return Get-Account -Url $TargetAccount.ResourceUrl -AccountKey $NewAccountKey -KeyId $Account.KeyId `
                       -Nonce $response.NextNonce -AutomaticAccountHandling:$($Script:AutoAccount)
}