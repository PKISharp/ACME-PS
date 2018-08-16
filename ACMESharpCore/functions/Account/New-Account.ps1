function New-Account {
    <#
        .SYNOPSIS
            Registers your account key with a new ACME-Account.

        .DESCRIPTION
            Registers the given account key with an ACME service to retreive an account that enables you to
            communicate with the ACME service.


        .PARAMETER State
            The account will be written into the provided state instance.

        .PARAMETER PassThrough
            If set, the account will be returned to the pipeline.

        .PARAMETER AcceptTOS
            If you set this, you accepted the Terms-of-service.

        .PARAMETER ExistingAccountIsError
            If set, the script will throw an error, if the key has already been registered.
            If not set, the script will try to fetch the account associated with the account key.

        .PARAMETER EmailAddresses
            Contact adresses for certificate expiration mails and similar.


        .EXAMPLE
            PS> New-Account -AcceptTOS -EmailAddresses "mail@example.com" -AutomaticAccountHandling

        .EXAMPLE
            PS> New-Account $myServiceDirectory $myAccountKey $myNonce -AcceptTos -EmailAddresses @(...) -ExistingAccountIsError
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate("AccountKey")})]
        [AcmeState]
        $State,

        [Parameter()]
        [switch]
        $PassThrough,

        [Switch]
        $AcceptTOS,

        [Switch]
        $ExistingAccountIsError,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $EmailAddresses
    )

    $Contacts = @($EmailAddresses | ForEach-Object { if($_.StartsWith("mailto:")) { $_ } else { "mailto:$_" } });

    $payload = @{
        "TermsOfServiceAgreed"=$AcceptTOS.IsPresent;
        "Contact"=$Contacts;
    }

    $url = $State.GetServiceDirectory().NewAccount;

    if($PSCmdlet.ShouldProcess("New-Account", "Sending account registration to ACME Server $Url")) {
        $response = Invoke-SignedWebRequest $url $State $payload -SupressKeyId -ErrorAction 'Stop'

        if($response.StatusCode -eq 200) {
            if(-not $ExistingAccountIsError) {
                Write-Warning "JWK had already been registered for an account - trying to fetch account."

                $keyId = $response.Headers["Location"][0];

                return Get-Account -AccountUrl $keyId -KeyId $keyId -State $State -PassThrough:$PassThrough
            } else {
                Write-Error "JWK had already been registiered for an account."
            }
        }

        $account = [AcmeAccount]::new($response, $response.Headers["Location"][0]);
        $State.Set($account);

        if($PassThrough) {
            return $result;
        }
    }
}