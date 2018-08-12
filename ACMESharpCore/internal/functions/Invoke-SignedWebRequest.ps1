function Invoke-SignedWebRequest {
    [CmdletBinding()]
    [OutputType("AcmeHttpResponse")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $Url,

        [Parameter(Mandatory = $true, Position = 1)]
        [IAccountKey] $AccountKey,

        [Parameter(Position = 2)]
        [string] $KeyId,

        [Parameter(Position = 3)]
        [AcmeNonce] $Nonce,

        [Parameter(Mandatory = $true, Position = 4)]
        [ValidateNotNull()]
        [object] $Payload
    )

    process {
        $requestBody = New-SignedMessage -Url $Url -AccountKey $AccountKey -KeyId $KeyId -Nonce $Nonce.Next -Payload $Payload
        $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST

        if($null -ne $response -and $response.NextNonce) {
            $Nonce.Push($response.NextNonce);
        }

        return $response;
    }
}