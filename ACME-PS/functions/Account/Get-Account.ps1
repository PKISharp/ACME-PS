function Get-ACMEAccount {
    <#
        .SYNOPSIS
            Loads account data from the ACME service.

        .DESCRIPTION
            If you do not provide additional parameters, this will search the account with the account key
            present in the state object. If an KeyId or Url is provided, they'll be used to load the account
            from that.

        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER AccountUrl
            The rescource url of the account to load.

        .PARAMETER KeyId
            The KeyId of the account to load.


        .EXAMPLE
            PS> Get-ACMEAccount -State $myState -PassThru

        .EXAMPLE
            PS> Get-ACMEAccount -State $myState -KeyId 12345
    #>
    [CmdletBinding(DefaultParameterSetName = "FindAccount")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountKeyExists()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName="GetAccount")]
        [ValidateNotNull()]
        [uri] $AccountUrl,

        [Parameter(Mandatory = $true, Position = 2, ParameterSetName="GetAccount")]
        [ValidateNotNullOrEmpty()]
        [string] $KeyId
    )

    if($PSCmdlet.ParameterSetName -eq "FindAccount") {
        $requestUrl = $State.GetServiceDirectory().NewAccount;
        $payload = @{"onlyReturnExisting" = $true};
        $response = Invoke-ACMESignedWebRequest -Url $requestUrl -State $State -Payload $payload

        if($response.StatusCode -eq 200) {
            $KeyId = $response.Headers["Location"][0];

            $AccountUrl = $KeyId;
        } else {
            Write-Error "JWK seems not to be registered for an account."
            return $null;
        }
    }

    $response = Invoke-ACMESignedWebRequest -Url $AccountUrl -State $State -Payload @{}
    $result = [AcmeAccount]::new($response, $KeyId);

    return $result;
}
