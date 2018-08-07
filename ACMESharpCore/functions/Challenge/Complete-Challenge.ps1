function Complete-Challenge {
    <#
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [AcmeChallenge] 
        $Challenge,

        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [ACMESharpCore.Crypto.IAccountKey] 
        $AccountKey = $Script:AccountKey,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $KeyId = $Script:KeyId,

        [Parameter(Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $Nonce = $Script:Nonce
    )

    process {
        $payload = @{};

        $requestBody = New-SignedMessage -Url $Challenge.Url -AccountKey $AccountKey -KeyId $KeyId -Nonce $Nonce -Payload $payload;
        $response = Invoke-AcmeWebRequest $Challenge.Url $requestBody -Method POST;

        return $response;
    }
}