function New-Account {
    <#
        .SYNOPSIS
            Registers your account key with a new ACME-Account.

        .DESCRIPTION
            Registers the given account key with an ACME server to retreive an account that enables you to
            communicate with the ACME server.

        
        .PARAMETER Directory
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNull()]
        [AcmeDirectory]
        $Directory = $Script:ServiceDirectory,

        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [ACMESharpCore.Crypto.IAccountKey] $AccountKey,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string] $Nonce = $Script:Nonce,

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
    $requestBody = New-SignedMessage -Url $url -Payload $payload -AccountKey $AccountKey -Nonce $Nonce

    if($PSCmdlet.ShouldProcess("New-Account", "Sending account registration to ACME Server $Url")) {
        $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST

        if($response.StatusCode -eq 200) {
            if(-not $ExistingAccountIsError) {
                Write-Warning "JWK had already been registered for an account - trying to fetch account."

                $Nonce = $response.NextNonce;
                $keyId = $response.Headers["Location"][0];

                return Get-Account -Url $keyId -AccountKey $AccountKey -KeyId $keyId -Nonce $Nonce
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