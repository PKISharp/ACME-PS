function New-Registration {
    [CmdletBinding(DefaultParameterSetName="Store", SupportsShouldProcess=$true)]
    param(
        [Parameter(ParameterSetName="Store")]
        [ValidateNotNullOrEmpty]
        [string]
        $ACMEStoreDir = ".",

        [Parameter(Mandatory=$true,ParameterSetName="Direct")]
        [ValidateNotNullOrEmpty]
        [ACMESharp.Crypto.JOSE.JwsExport] $JwsExport,

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

    if($PSCmdlet.ParameterSetName -eq "Store") {
        $localStore = [LocalStore]::Load($ACMEStoreDir);
        $ACMENewAccountUrl = $localStore.Directory.NewAccount;
        $JwsExport = $localStore.AccountKey;
    }

    $payload = [ACMESharp.Protocol.Messages.CreateAccountRequest]::new();
    $payload.TermsOfServiceAgreed = $AcceptTOS;
    $payload.Contacts = $EmailAddresses | ForEach-Object { "mail:$_" }

    $request = Create-SignedMessage -Payload $payload -JwsExport $JwsExport

    if($PSCmdlet.ShouldProcess("New-Registration", "Sending registration to ACME Server $ACMENewAccountUrl")) {
        Invoke-WebRequest $ACMENewAccountUrl -Method POST -Body $request
    }
}