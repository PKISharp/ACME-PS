function Set-ACMEAccount {
    <#
        .SYNOPSIS
            Updates an ACME account

        .DESCRIPTION
            Updates the ACME account, by sending the update information to the ACME service.

        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER PassThru
            Forces the updated account to be returned to the pipeline.

        .PARAMETER NewAccountKey
            New account key to be associated with the account.

        .PARAMETER DisableAccount
            If set, the account will be disabled and thus not be usable with the acme-service anymore.

        .EXAMPLE
            PS> Set-ACMEAccount -State $myState -NewAccountKey $myNewAccountKey
    #>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountExists()})]
        [AcmeState]
        $State,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(Mandatory = $true, ParameterSetName="NewAccountKey")]
        [IAccountKey]
        $NewAccountKey,

        [Parameter(Mandatory = $true, ParameterSetName="DisableAccount")]
        [switch]
        $DisableAccount
    )

    switch ($PSCmdlet.ParameterSetName) {
        "NewAccountKey" {
            $innerPayload = @{
                "account" = $State.GetAccount().KeyId;
                "oldKey" = $State.GetAccountKey().ExportPuplicKey()
            };

            $payload = New-SignedMessage -Url $Url -SigningKey $NewAccountKey -Payload $innerPayload;
            $message = "Set new account key and store it into state?";
        }

        "DisableAccount" {
            $payload = @{"status"= "deactivated"};
            $message = "Disable account? - This is irrevocable!"
        }

        Default {
            return;
        }
    }

    if($PSCmdlet.ShouldProcess("Account", $message)) {
        $response = Invoke-ACMESignedWebRequest -Url $Url -State $State -Payload $payload -ErrorAction 'Stop';
        $keyId = $State.GetAccount().KeyId;

        $account = [AcmeAccount]::new($response, $keyId);

        if($null -ne $NewAccountKey) { $State.Set($NewAccountKey); }
        $State.Set($account);

        if($PassThru) {
            return $account;
        }
    }
}
