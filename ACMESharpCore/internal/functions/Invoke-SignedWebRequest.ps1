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
        [object] $Payload
    )

    process {
        $accountKey = $State.AccountKey;
        $keyId = (if($State.Account) { $State.Account.KeyId });
        $nonce = $State.Nonce;

        $requestBody = New-SignedMessage -Url $Url -AccountKey $accountKey -KeyId $keyId -Nonce $nonce.Next -Payload $Payload
        $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST

        if($null -ne $response -and $response.NextNonce) {
            $nonce.Push($response.NextNonce);
        }

        return $response;
    }
}