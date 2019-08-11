function Invoke-SignedWebRequest {
    [CmdletBinding()]
    [OutputType("AcmeHttpResponse")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $Url,

        [Parameter(Mandatory = $true, Position = 1)]
        [AcmeState] $State,

        [Parameter(Position = 2)]
        [ValidateNotNull()]
        [object] $Payload = @{},

        [Parameter()]
        [switch] $SupressKeyId
    )

    process {
        $accountKey = $State.GetAccountKey();
        $account = $State.GetAccount();
        $keyId = $(if($account -and -not $SupressKeyId) { $account.KeyId });
        $nonce = $State.GetNonce();

        $requestBody = New-SignedMessage -Url $Url -SigningKey $accountKey -KeyId $keyId -Nonce $nonce -Payload $Payload
        $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST -ErrorAction 'Continue'

        if($null -ne $response -and $response.NextNonce) {
            $State.SetNonce($response.NextNonce);
        }

        if($response.IsError) {
            throw $response;
        }

        return $response;
    }
}