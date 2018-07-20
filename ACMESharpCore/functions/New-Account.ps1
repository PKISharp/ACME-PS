function New-Account {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [uri] $Url, 

        [Parameter(Mandatory=$true)]
        [ACMESharp.Crypto.JOSE.JwsAlgorithm] $JwsAlgorithm,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Nonce = $Script:Nonce,

        [Switch]
        $AcceptTOS,

        [Parameter(Mandatory = $true)]
        [string[]]
        $EmailAddresses
    )

    $payload = @{}
    $payload.add("TermsOfServiceAgreed", $AcceptTOS.IsPresent);
    $payload.add("Contact", @($EmailAddresses | ForEach-Object { "mailto:$_" }));

    $requestBody = New-SignedMessage -Url $Url -Payload $payload -JwsAlgorithm $JwsAlgorithm -Nonce $Nonce

    Write-Debug "Prepared request body: $requestBody"
    if($PSCmdlet.ShouldProcess("New-Registration", "Sending registration to ACME Server $Url")) {
        $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST

        if($response.StatusCode -eq 200) {
            Write-Warning "JWK had already been registered for an Account - trying to fetch account."

            $Nonce = $response.NextNonce;
            $keyId = $response.Headers["Location"][0];

            return Get-Account -Url $keyId -JwsAlgorithm $JwsAlgorithm -KeyId $keyId -Nonce $Nonce
        }

        return [AcmeAccount]::new($response, $response.Headers["Location"][0], $JwsAlgorithm);
    }
}