function Complete-Challenge {
    <#
        .PARAMETER State
            State instance containing service directory, account key, account and nonce.
        
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [AcmeChallenge] 
        $Challenge,

        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate()})]
        [AcmeState]
        $State
    )

    process {
        $accountKey = $State.AccountKey;
        $keyId = $State.Account.KeyId;
        $nonce = $State.Nonce;    

        $payload = @{};

        $response = Invoke-SignedWebRequest -Url $Challenge.Url -AccountKey $AccountKey -KeyId $KeyId -Nonce $Nonce -Payload $payload;

        return [AcmeChallenge]::new($response, $Challenge.Identifier);
    }
}