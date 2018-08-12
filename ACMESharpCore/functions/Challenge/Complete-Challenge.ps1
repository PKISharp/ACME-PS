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
        $payload = @{};

        $response = Invoke-SignedWebRequest -Url $Challenge.Url -AccountKey $AccountKey -KeyId $KeyId -Nonce $Nonce.Next -Payload $payload;

        return [AcmeChallenge]::new($response, $Challenge.Identifier);
    }
}