function Set-AccountKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate()})]
        [AcmeState]
        $State,

        [Parameter()]
        [switch]
        $PassThrough,

        [Parameter(Mandatory = $true, ParameterSetName="NewAccountKey")]
        [IAccountKey] $NewAccountKey
    )

    $innerPayload = @{
        "account" = $State.Account.KeyId;
        "oldKey" = $State.AccountKey.ExportPuplicKey()
    };

    $payload = New-SignedMessage -Url $Url -AccountKey $NewAccountKey -Payload $innerPayload;
    Invoke-SignedWebRequest $Url -$State $payload -ErrorAction 'Stop';

    $State.AccountKey = $NewAccountKey
    return Get-Account -Url $TargetAccount.ResourceUrl -State $State -KeyId $Account.KeyId
}