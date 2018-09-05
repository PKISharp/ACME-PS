function Set-Account {
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

    $payload = New-SignedMessage -Url $Url -AccountKey $NewAccountKey -Payload $innerPayload;

    if($PSCmdlet.ShouldProcess("Account", "Set new AccountKey and store it into state")) {
        Invoke-SignedWebRequest $Url -$State $payload -ErrorAction 'Stop';

        $State.Set($NewAccountKey);
        return Get-Account -Url $TargetAccount.ResourceUrl -State $State -KeyId $Account.KeyId
    }
}