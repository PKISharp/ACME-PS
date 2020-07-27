function Complete-ACMEChallenge {
    <#
        .SYNOPSIS
            Signals a challenge to be checked by the ACME service.

        .DESCRIPTION
            The ACME service will be called to signal, that the challenge is ready to be validated.
            The result of the operation will be returned.


        .PARAMETER Challenge
            The challenge, which is ready to be validated.

        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.


        .EXAMPLE
            PS> Complete-Challange $myState $myChallange

        .EXAMPLE
            PS> $myChallenge | Complete-ACMEChallenge $myState
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [AcmeChallenge]
        $Challenge,

        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountExists()})]
        [AcmeState]
        $State
    )

    process {
        $payload = @{};

        if($PSCmdlet.ShouldProcess("Challenge", "Complete challenge by submitting completion to ACME service")) {
            $response = Invoke-ACMESignedWebRequest -Url $Challenge.Url -State $State -Payload $payload;

            return [AcmeChallenge]::new($response, $Challenge.Identifier);
        }
    }
}
