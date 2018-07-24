function New-Account {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true, Position = 0)]
        [uri] $Url, 

        [Parameter(Mandatory=$true, Position = 1)]
        [ACMESharp.Crypto.JOSE.JwsAlgorithm] $JwsAlgorithm,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string] $Nonce = $Script:Nonce,

        [Switch]
        $AcceptTOS,

        [Switch]
        $ExistingAccountIsError,

        [Parameter(Mandatory = $true)]
        [string[]]
        $EmailAddresses
    )

    $payload = @{}
    $payload.add("TermsOfServiceAgreed", $AcceptTOS.IsPresent);
    $payload.add("Contact", @($EmailAddresses | ForEach-Object { if($_.StartsWith("mailto:")) { $_ } else { "mailto:$_" } }));

    $requestBody = New-SignedMessage -Url $Url -Payload $payload -JwsAlgorithm $JwsAlgorithm -Nonce $Nonce

    Write-Debug "Prepared request body: $requestBody"
    if($PSCmdlet.ShouldProcess("New-Registration", "Sending registration to ACME Server $Url")) {
        $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST

        if($response.StatusCode -eq 200) {
            if(-not $ExistingAccountIsError) {
                Write-Warning "JWK had already been registered for an account - trying to fetch account."

                $Nonce = $response.NextNonce;
                $keyId = $response.Headers["Location"][0];

                return Get-Account -Url $keyId -JwsAlgorithm $JwsAlgorithm -KeyId $keyId -Nonce $Nonce
            } else {
                Write-Error "JWK had already been registiered for an account."
            }
        } 

        return [AcmeAccount]::new($response, $response.Headers["Location"][0]);
    }
}