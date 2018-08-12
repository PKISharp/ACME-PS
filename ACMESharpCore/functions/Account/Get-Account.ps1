function Get-Account {
    <#
    #>
    [CmdletBinding(DefaultParameterSetName = "FindAccount")]
    param(
        [Parameter(Position = 0, ParameterSetName="FindAccount")]
        [ValidateNotNull()]
        [AcmeDirectory]
        $Directory = $Script:ServiceDirectory,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName="GetAccount")]
        [ValidateNotNull()]
        [uri] $AccountUrl, 

        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [IAccountKey] $AccountKey = $Script:AccountKey,

        [Parameter(Position = 2, ParameterSetName="GetAccount")]
        [ValidateNotNullOrEmpty()]
        [string] $KeyId = $Script:KeyId,

        [Parameter(Position = 3)]
        [ValidateNotNullOrEmpty()]
        [AcmeNonce] $Nonce = $Script:Nonce,

        [Parameter()]
        [switch]
        $AutomaticAccountHandling
    )

    if($PSCmdlet.ParameterSetName -eq "FindAccount") {
        $payload = @{"onlyReturnExisting" = $true};
        $response = Invoke-SignedWebRequest -Url $Directory.NewAccount -Payload $payload -AccountKey $AccountKey -Nonce $Nonce
    
        if($response.StatusCode -eq 200) {
            $Nonce.Push($response.NextNonce);
            $KeyId = $response.Headers["Location"][0];
            
            $AccountUrl = $KeyId;
        } else {
            Write-Error "JWK seems not to be registered for an account."
            return $null;
        }
    } 

    $response = Invoke-SignedWebRequest -Url $AccountUrl -Payload @{} -AccountKey $AccountKey -KeyId $KeyId -Nonce $Nonce.Next
    $result = [AcmeAccount]::new($response, $KeyId);

    if($AutomaticAccountHandling) {
        Enable-AccountHandling -Account $result;
    }

    return $result;
}