function Get-Account {
    <#
    #>
    [CmdletBinding(DefaultParameterSetName = "FindAccount")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate("AccountKey")})]
        [AcmeState]
        $State,

        [Parameter()]
        [switch]
        $PassThrough,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName="GetAccount")]
        [ValidateNotNull()]
        [uri] $AccountUrl, 

        [Parameter(Mandatory = $true, Position = 2, ParameterSetName="GetAccount")]
        [ValidateNotNullOrEmpty()]
        [string] $KeyId
    )

    $accountKey = $State.AccountKey;

    if($PSCmdlet.ParameterSetName -eq "FindAccount") {
        $requestUrl = $State.ServiceDirectory.NewAccount;
        $payload = @{"onlyReturnExisting" = $true};
        $response = Invoke-SignedWebRequest -Url $requestUrl -Payload $payload -AccountKey $AccountKey -Nonce $Nonce
    
        if($response.StatusCode -eq 200) {
            $KeyId = $response.Headers["Location"][0];
            
            $AccountUrl = $KeyId;
        } else {
            Write-Error "JWK seems not to be registered for an account."
            return $null;
        }
    } 

    $response = Invoke-SignedWebRequest -Url $AccountUrl -Payload @{} -AccountKey $AccountKey -KeyId $KeyId -Nonce $Nonce
    $result = [AcmeAccount]::new($response, $KeyId);

    if($AutomaticAccountHandling) {
        Enable-AccountHandling -Account $result;
    }

    return $result;
}