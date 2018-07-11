function New-Registration {
    [CmdletBinding(DefaultParameterSetName="Store", SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true,ParameterSetName="Direct")]
        [ValidateNotNullOrEmpty]
        [ACMESharp.Crypto.JOSE.JwsAlgorithm] $JwsAlgorithm,

        [Parameter(Mandatory=$true,ParameterSetName="Direct")]
        [ValidateNotNullOrEmpty]
        [uri] $ACMENewAccountUrl, 

        [Switch]
        $AcceptTOS,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty]
        [string[]]
        $EmailAddresses
    )

    $payload = [ACMESharp.Protocol.Messages.CreateAccountRequest]::new();
    $payload.TermsOfServiceAgreed = $AcceptTOS;
    $payload.Contacts = $EmailAddresses | ForEach-Object { "mail:$_" }

    $request = New-SignedMessage -Payload $payload -JwsAlgorithm $JwsAlgorithm

    if($PSCmdlet.ShouldProcess("New-Registration", "Sending registration to ACME Server $ACMENewAccountUrl")) {
        Invoke-WebRequest $ACMENewAccountUrl -Method POST -Body $request
    }
}