function Invoke-SignedWebRequest {
    [CmdletBinding()]
    [OutputType("AcmeHttpResponse")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $Url,

        [Parameter(Mandatory = $true, Position = 1)]
        [AcmeState] $State,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNull()]
        [object] $Payload,

        [Parameter()]
        [switch] $SupressKeyId
    )

    process {
        $accountKey = $State.GetAccountKey();
        $account = $State.GetAccount();
        $keyId = $(if($account -and -not $SupressKeyId) { $account.KeyId });
        $nonce = $State.GetNonce();

        $requestBody = New-SignedMessage -Url $Url -AccountKey $accountKey -KeyId $keyId -Nonce $nonce -Payload $Payload
        $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST

        if($null -ne $response -and $response.NextNonce) {
            $State.SetNonce($response.NextNonce);
        }

        return $response;
    }
}