function Set-Account {
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


        .EXAMPLE
            PS> Set-Account -State $myState -NewAccountKey $myNewAccountKey
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
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
        [IAccountKey] $NewAccountKey
    )

    $innerPayload = @{
        "account" = $State.GetAccount().KeyId;
        "oldKey" = $State.GetAccountKey().ExportPuplicKey()
    };

    $payload = New-SignedMessage -Url $Url -SigningKey $NewAccountKey -Payload $innerPayload;

    if($PSCmdlet.ShouldProcess("Account", "Set new AccountKey and store it into state")) {
        Invoke-SignedWebRequest -Url $Url -State $State -Payload $payload -ErrorAction 'Stop';

        $State.Set($NewAccountKey);
        $account = Get-Account -Url $TargetAccount.ResourceUrl -State $State -KeyId $Account.KeyId

        $State.Set($account);

        if($PassThru) {
            return $account;
        }
    }
}