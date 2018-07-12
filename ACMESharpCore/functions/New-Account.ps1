function New-Account {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true,ParameterSetName="Direct")]
        [ACMESharp.Crypto.JOSE.JwsAlgorithm] $JwsAlgorithm,

        [Parameter(Mandatory=$true,ParameterSetName="Direct")]
        [uri] $ACMENewAccountUrl, 

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Nonce,

        [Switch]
        $AcceptTOS,

        [Parameter(Mandatory = $true)]
        [string[]]
        $EmailAddresses
    )

    $payload = @{}
    $payload.add("TermsOfServiceAgreed", $AcceptTOS.IsPresent);
    $payload.add("Contact", @($EmailAddresses | ForEach-Object { "mailto:$_" }));

    $request = New-SignedMessage -Url $ACMENewAccountUrl -Payload $payload -JwsAlgorithm $JwsAlgorithm -Nonce $Nonce

    Write-Verbose "Signed message will have the following content: $request"
    if($PSCmdlet.ShouldProcess("New-Registration", "Sending registration to ACME Server $ACMENewAccountUrl")) {
        Invoke-WebRequest $ACMENewAccountUrl -Method POST -Body $request -ContentType "application/jose+json"
    }
}