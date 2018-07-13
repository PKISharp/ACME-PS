function New-Account {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [uri] $Url, 

        [Parameter(Mandatory=$true)]
        [ACMESharp.Crypto.JOSE.JwsAlgorithm] $JwsAlgorithm,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Nonce,

        [Switch]
        $AcceptTOS,

        [Parameter(Mandatory = $true)]
        [string[]]
        $EmailAddresses,

        [Switch]
        $SkipCheckForExistingAccount
    )

    if(!$SkipCheckForExistingAccount) {
        Write-Verbose "Checking for existing account."
        $payload = @{ "onlyReturnExisting" = $true }

        $requestBody = New-SignedMessage -Url $Url -Payload $payload -JwsAlgorithm $JwsAlgorithm -Nonce $Nonce

        try {
            $response = Invoke-WebRequest $Url -Method POST -Body $requestBody -ContentType "application/jose+json"
        } catch {
            $exResponse = $Error[0].Exception.Response;
            if($Error[0].Exception.Response) {
                $exResponse.StatusCode -eq 
            }
            else {
                Write-Error $Error;
                return;
            }
        }

        return $response;
    }

    $payload = @{}
    $payload.add("TermsOfServiceAgreed", $AcceptTOS.IsPresent);
    $payload.add("Contact", @($EmailAddresses | ForEach-Object { "mailto:$_" }));

    $requestBody = New-SignedMessage -Url $Url -Payload $payload -JwsAlgorithm $JwsAlgorithm -Nonce $Nonce

    Write-Verbose "Prepared request body: $requestBody"
    if($PSCmdlet.ShouldProcess("New-Registration", "Sending registration to ACME Server $Url")) {
        $response = Invoke-WebRequest $Url -Method POST -Body $requestBody -ContentType "application/jose+json"

        if($response.StatusCode -eq 200) {
            Write-Warning "JWK had already been registered for an Account - trying to fetch account."

            $newNonce = $response.Headers["Replay-Nonce"];
            $accountUrl = $response.Headers["Location"];

            $keyId = $accountUrl -split '/' | Select-Object -Last 1

            return Get-Account -Url $accountUrl -JwsAlgorithm $JwsAlgorithm -KeyId $keyId -Nonce $newNonce
        }

        return [ACMEResponse]::new($response);
    }
}