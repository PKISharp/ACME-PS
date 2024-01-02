function New-Account {
    <#
        .SYNOPSIS
            Registers your account key with a new ACME-Account.

        .DESCRIPTION
            Registers the given account key with an ACME service to retreive an account that enables you to
            communicate with the ACME service.


        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER PassThru
            Forces the account to be returned to the pipeline.

        .PARAMETER AcceptTOS
            If you set this, you accepted the Terms-of-service.

        .PARAMETER ExistingAccountIsError
            If set, the script will throw an error, if the key has already been registered.
            If not set, the script will try to fetch the account associated with the account key.

        .PARAMETER EmailAddresses
            Contact adresses for certificate expiration mails and similar.

        .PARAMETER ExternalAccountKID
            The account KID assigned by the external account verification.

        .PARAMETER ExternalAccountAlgorithm
            The algorithm to be used to hash the external account binding.

        .PARAMETER ExternalAccountMACKey
            The key to hash the external account binding object (needs to be base64 or base64url encoded)


        .EXAMPLE
            PS> New-Account -AcceptTOS -EmailAddresses "mail@example.com" -AutomaticAccountHandling

        .EXAMPLE
            PS> New-Account $myServiceDirectory $myAccountKey $myNonce -AcceptTos -EmailAddresses @(...) -ExistingAccountIsError
    #>
    [CmdletBinding(SupportsShouldProcess=$true, DefaultParameterSetName="Default")]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountKeyExists()})]
        [AcmeState]
        $State,

        [Parameter()]
        [switch]
        $PassThru,

        [Switch]
        $AcceptTOS,

        [Switch]
        $ExistingAccountIsError,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $EmailAddresses,

        [Parameter(ParameterSetName = "ExternalAccountBinding", Mandatory = $true)]
        [ValidateNotNull()]
        [string]
        $ExternalAccountKID,

        [Parameter(ParameterSetName = "ExternalAccountBinding")]
        [ValidateSet('HS256','HS384','HS512')]
        [string]
        $ExternalAccountAlgorithm = 'HS256',

        [Parameter(ParameterSetName = "ExternalAccountBinding", Mandatory = $true)]
        [ValidateNotNull()]
        [string]
        $ExternalAccountMACKey
    )

    $contacts = @($EmailAddresses | ForEach-Object { if($_.StartsWith("mailto:")) { $_ } else { "mailto:$_" } });

    $payload = @{
        "termsOfServiceAgreed"=$AcceptTOS.IsPresent;
        "contact"=$contacts;
    }

    $serviceDirectory = $State.GetServiceDirectory();
    $url = $serviceDirectory.NewAccount;

    if($PSCmdlet.ParameterSetName -ne "ExternalAccountBinding" -and $serviceDirectory.Meta.ExternalAccountRequired) {
        throw "The ACME service requires an external account to create a new ACME account. Provide `-ExternalAccount*` Parameters."
    }

    if($PSCmdlet.ParameterSetName -eq  "ExternalAccountBinding") {
        $externalAccountBinding = New-ExternalAccountPayload -State $State -ExternalAccountKID $ExternalAccountKID -ExternalAccountMACKey $ExternalAccountMACKey -ExternalAccountAlgorithm $ExternalAccountAlgorithm;
        $payload.Add("externalAccountBinding", $externalAccountBinding);
    }

    if($PSCmdlet.ShouldProcess("New-Account", "Sending account registration to ACME Server $Url")) {
        $response = Invoke-SignedWebRequest -Url $url -State $State -Payload $payload -SuppressKeyId -ErrorAction 'Stop'

        if($response.StatusCode -eq 200) {
            if(-not $ExistingAccountIsError) {
                Write-Warning "JWK had already been registered for an account - trying to fetch account."

                $keyId = $response.Headers["Location"][0];

                return Get-Account -AccountUrl $keyId -KeyId $keyId -State $State
            } else {
                Write-Error "JWK had already been registiered for an account."
                return;
            }
        }

        $account = [AcmeAccount]::new($response, $response.Headers["Location"][0]);
        $State.Set($account);

        if($PassThru) {
            return $account;
        }
    }
}
