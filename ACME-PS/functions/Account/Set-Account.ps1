function Set-Account {
    <#
        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate()})]
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
        Invoke-SignedWebRequest $Url -$State $payload -ErrorAction 'Stop';

        $State.Set($NewAccountKey);
        return Get-Account -Url $TargetAccount.ResourceUrl -State $State -KeyId $Account.KeyId
    }
}