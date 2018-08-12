function New-Account {
    <#
        .SYNOPSIS
            Registers your account key with a new ACME-Account.

        .DESCRIPTION
            Registers the given account key with an ACME service to retreive an account that enables you to
            communicate with the ACME service.

        
        .PARAMETER Directory
            The service directory of the ACME service. Can be handled by the module, if enabled.

        .PARAMETER AccountKey
            Your account key for JWS Signing. Can be handled by the module, if enabled.
        
        .PARAMETER Nonce
            Replay nonce from ACME service. Can be handled by the module, if enabled.

        .PARAMETER AcceptTOS
            If you set this, you accepted the Terms-of-service.

        .PARAMETER ExistingAccountIsError
            If set, the script will throw an error, if the key has already been registered.
            If not set, the script will try to fetch the account associated with the account key.

        .PARAMETER EmailAddresses
            Contact adresses for certificate expiration mails and similar.

        .PARAMETER AutomaticAccountHandling
             If set, the module will be initialized to automatically provide the account, where neccessary.

            
        .EXAMPLE
            PS> New-Account -AcceptTOS -EmailAddresses "mail@example.com" -AutomaticAccountHandling

        .EXAMPLE
            PS> New-Account $myServiceDirectory $myAccountKey $myNonce -AcceptTos -EmailAddresses @(...) -ExistingAccountIsError
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNull()]
        [AcmeDirectory]
        $Directory = $Script:ServiceDirectory,

        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [IAccountKey] $AccountKey = $Script:AccountKey,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [AcmeNonce] $Nonce = $Script:Nonce,

        [Switch]
        $AcceptTOS,

        [Switch]
        $ExistingAccountIsError,

        [Parameter(Mandatory = $true)]
        [string[]]
        $EmailAddresses,

        [Parameter()]
        [switch]
        $AutomaticAccountHandling
    )

    $Contacts = @($EmailAddresses | ForEach-Object { if($_.StartsWith("mailto:")) { $_ } else { "mailto:$_" } });

    $payload = @{
        "TermsOfServiceAgreed"=$AcceptTOS.IsPresent;
        "Contact"=$Contacts;
    }
    
    $url = $Directory.NewAccount;
    $requestBody = New-SignedMessage -Url $url -Payload $payload -AccountKey $AccountKey -Nonce $Nonce.Next

    if($PSCmdlet.ShouldProcess("New-Account", "Sending account registration to ACME Server $Url")) {
        $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST

        if($response.StatusCode -eq 200) {
            if(-not $ExistingAccountIsError) {
                Write-Warning "JWK had already been registered for an account - trying to fetch account."

                $Nonce.Push($response.NextNonce);
                $keyId = $response.Headers["Location"][0];

                return Get-Account -Url $keyId -AccountKey $AccountKey -KeyId $keyId -Nonce $Nonce.Next -AutomaticAccountHandling:$AutomaticAccountHandling
            } else {
                Write-Error "JWK had already been registiered for an account."
            }
        } 

        $result = [AcmeAccount]::new($response, $response.Headers["Location"][0]);

        if($AutomaticAccountHandling) {
            Enable-AccountHandling -Account $result;
        }

        return $result;
    }
}