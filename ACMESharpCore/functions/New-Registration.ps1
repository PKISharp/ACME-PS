function New-Registration {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter()]
        [string]
        $ACMEStoreDir = ".",

        [Switch]
        $AcceptTOS,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty]
        [string[]]
        $EmailAddresses
    )

    $serviceDirectory = [LocalStore]::Load($ACMEStoreDir);

    $payload = [ACMESharp.Protocol.Messages.CreateAccountRequest]::new();
    $payload.TermsOfServiceAgreed = $AcceptTOS;
    $payload.Contacts = $EmailAddresses | ForEach-Object { "mail:$_" }

    $request = Create-SignedMessage 

    if($PSCmdlet.ShouldProcess("New-Registration", "Sending registration to ACME Server")) {
        Invoke-WebRequest $serviceDirectory.NewAccount -Method POST -Body $request
    }
}