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
        [object] $Payload = "",

        [Parameter()]
        [Alias("SupressKeyId")]
        [switch] $SuppressKeyId,

        [Parameter()]
        [switch] $SkipRetryOnNonceError
    )

    process {
        $accountKey = $State.GetAccountKey();
        $account = $State.GetAccount();
        $keyId = $(if($account -and -not $SuppressKeyId) { $account.KeyId });
        $nonce = $State.GetNonce();

        $requestBody = New-SignedMessage -Url $Url -SigningKey $accountKey -KeyId $keyId -Nonce $nonce -Payload $Payload
        $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST -ErrorAction 'Continue'

        if($response.NextNonce) {
            $State.SetNonce($response.NextNonce);

            if($response.IsError -and -not $SkipRetryOnNonceError) {
                if($response.Content.Type -eq "urn:ietf:params:acme:error:badNonce") {
                    return Invoke-SignedWebRequest -Url $Url -State $State -Payload $Payload -SuppressKeyId:$SuppressKeyId.IsPresent -SkipRetryOnNonceError;
                }
            }
        }

        if($response.IsError) {
            throw [AcmeHttpException]::new($response.ErrorMessage, $response)
        }

        return $response;
    }
}
