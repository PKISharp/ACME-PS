function Complete-Challenge {
    <#
        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
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

        if($PSCmdlet.ShouldProcess("Challenge", "Complete challenge by submitting completion to ACME service")) {
            $response = Invoke-SignedWebRequest $Challenge.Url $State $payload;

            return [AcmeChallenge]::new($response, $Challenge.Identifier);
        }
    }
}