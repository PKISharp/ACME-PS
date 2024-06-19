[OutputType([string])]

# requires -Modules ACME-PS, Az, Az.Websites

<# 
  Azure Runbooks seem to have problems with ACME-PS, if Az.Storage is used as well.
  To work-around the problems, it seems neccessary to explicitly import the azure cmdlets used
  before ACME-PS is imported

  Import-Module 'Az';
  Import-Module 'Az.Storage';
  Import-Module 'Az.Websites';
  Import-Module 'ACME-PS';
#>

param(
    [Parameter()]
    [String] $Subscription = "",

    [Parameter()]
    [String] $Domain = "example.org",

    [Parameter()]
    [String] $RegistrationEmail = "first-mail@example.org",

    [Parameter()]
    [String] $ResourceGroupName = "MY_RESSOURCE_GROUP",

    [Parameter()]
    [String] $WebApp = "my-web-app"
)

# Your email addresses, where acme services will send informations.
$contactMailAddresses = @($RegistrationEmail);

# This directory is used to store your account key and service directory urls as well as orders and related data
$acmeStateDir = "C:\app\AcmeState";

# This path will be used to export your certificate file.
$certExportPathParent = "C:\app\certificates\";
$certExportPath = "C:\app\certificates\certificate.pfx";

# ServiceName (valid names are LetsEncrypt and LetsEncrypt-Staging, use the latter one for testing your scripts).
# $acmeServiceName = "LetsEncrypt-Staging";
$acmeServiceName = "LetsEncrypt";


function PublishWebsiteFile
{
    param(
        [Parameter(Mandatory)]
        $ResourceGroupName,

        [Parameter(Mandatory)]
        $WebApp,

        [Parameter(Mandatory)]
        $PublishSettingsFile,

        [Parameter(Mandatory)]
        $RemotePath,

        [Parameter(Mandatory)]
        $FileContent
    )

    $RemotePath = $RemotePath.Trim("/\")

    $publishSettings = [xml] (Get-Content $PublishSettingsFile -Raw)
    $ftpPublishSettings = $publishSettings.publishData.publishProfile | ? publishMethod -eq MSDeploy

    $username = $ftpPublishSettings.userName
    $password = $ftpPublishSettings.userPWD
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

    $apiBaseUrl = "https://$WebApp.scm.azurewebsites.net/api"
    Invoke-RestMethod -Uri "$apiBaseUrl/vfs/site/wwwroot/$RemotePath" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo); 'If-Match' = '*'} -Method PUT -Body $FileContent
}

# removes entry "0.0.0.0/0" from list
function EnableFirewall
{
    param(
        [Parameter(Mandatory)]
        $ResourceGroupName,

        [Parameter(Mandatory)]
        $WebApp
    )

    $p1 = @{
        ResourceGroupName = $ResourceGroupName
        ResourceType = "Microsoft.Web/sites/config"
        ResourceName = "$WebApp/web"
        ApiVersion = "2018-02-01"
    }

    $WebAppConfig = Get-AzResource @p1
    $IpSecurityRestrictions = $WebAppConfig.properties.ipsecurityrestrictions

    $IpSecurityRestrictions = $IpSecurityRestrictions | ? { $_.ipAddress -ne "0.0.0.0/0" }
    $WebAppConfig.properties.ipSecurityRestrictions = $IpSecurityRestrictions

    Set-AzResource `
        -ResourceId $WebAppConfig.ResourceId `
        -Properties $WebAppConfig.Properties `
        -ApiVersion 2018-02-01 `
        -Force;
}

# adds entry "0.0.0.0/0" to list
function DisableFirewall
{
    param(
        [Parameter(Mandatory)]
        $ResourceGroupName,

        [Parameter(Mandatory)]
        $WebApp
    )

    $p1 = @{
        ResourceGroupName = $ResourceGroupName
        ResourceType = "Microsoft.Web/sites/config"
        ResourceName = "$WebApp/web"
        ApiVersion = "2018-02-01"
    }

    Write-Progress "Adding entry for $WebApp/web ..."
    $WebAppConfig = Get-AzResource @p1
    $IpSecurityRestrictions = $WebAppConfig.properties.ipsecurityrestrictions

    $restriction = @{}
    $restriction.Add("ipAddress", "0.0.0.0/0")
    $restriction.Add("action", "Allow")
    $restriction.Add("tag", "Default")
    $restriction.Add("priority", 1)
    $restriction.Add("name", "Allow All")
    $restriction.Add("description", "Rule created automatically by Let's Encrypt script")
    $IpSecurityRestrictions+= $restriction

    $WebAppConfig.properties.ipSecurityRestrictions = $IpSecurityRestrictions

    Set-AzResource `
        -ResourceId $WebAppConfig.ResourceId `
        -Properties $WebAppConfig.Properties `
        -ApiVersion 2018-02-01 `
        -Force;
}

"Logging in to Azure ..."
Connect-AzAccount -Identity -Subscription $Subscription

Write-Progress "WARNING! Disable firewall via whitelist..."
DisableFirewall -ResourceGroupName $ResourceGroupName -WebApp $WebApp


"*** STARTING with Service Name: $acmeServiceName"


# see https://github.com/PKISharp/ACMESharpCore-PowerShell/tree/master/samples

Import-Module 'ACME-PS';
Import-Module 'Az';
Import-Module 'Az.Storage';
Import-Module 'Az.Websites';

try
{
    "*** 0. Create temp folder"
    If(!(test-path -PathType container $certExportPathParent))
    {
      New-Item -ItemType Directory -Path $certExportPathParent

      "Temp folder created"
    }

    ###
    ### 1. Create an new account
    ### https://github.com/PKISharp/ACMESharpCore-PowerShell/blob/master/samples/CreateAccount.ps1
    ###

    "*** 1. Create an new account"

    # Create the state object - will be saved to disk
    New-ACMEState -Path $acmeStateDir;

    # Load URLs from service directory
    Get-ACMEServiceDirectory -State $acmeStateDir -ServiceName $acmeServiceName;

    # Retrieve the first anti-replay nonce
    New-ACMENonce -State $acmeStateDir;

    # Create an account key and store it to the state
    New-ACMEAccountKey -State $acmeStateDir;

    # Register account key with acme service
    New-ACMEAccount -State $acmeStateDir -EmailAddresses $contactMailAddresses -AcceptTOS;


    ###
    ### 2. Create a new order
    ### https://github.com/PKISharp/ACMESharpCore-PowerShell/blob/master/samples/CreateOrderS.ps1
    ###

    "*** 2. Create a new order..."

    # This dns names will be used as identifier
    $dnsIdentifiers = New-ACMEIdentifier $Domain;

    # Create a new order
    $order = New-ACMEOrder -State $acmeStateDir -Identifiers $dnsIdentifiers;

    Write-Host ($order | Format-List | Out-String)


    ###
    ### 3. Fullfill challenge
    ### https://github.com/PKISharp/ACMESharpCore-PowerShell/blob/master/samples/CreateOrderS.ps1
    ###

    "*** 3. Fullfill challenge..."

    # Fetch the authorizations for that order
    $authorizations = @(Get-ACMEAuthorization -State $acmeStateDir -Order $order);

    foreach($authz in $authorizations) {

        # Select a challenge to fullfill
        $challenge = Get-ACMEChallenge -State $acmeStateDir -Authorization $authZ -Type "http-01";

        # Inspect the challenge data (uncomment, if you want to see the object)
        # Depending on the challenge-type this will include different properties
        "Challenge Data:"
        $challenge.Data;

        "Uploading challenge to WebApp"

        $tempFile = New-TemporaryFile
        try
        {
            $null = Get-AzWebAppPublishingProfile  `
                -ResourceGroupName $ResourceGroupName `
                -Name $WebApp `
                -OutputFile $tempFile

            PublishWebsiteFile -ResourceGroupName $ResourceGroupName `
                -WebApp $WebApp `
                -PublishSettingsFile $tempFile `
                -RemotePath $challenge.Data.RelativeUrl `
                -FileContent $challenge.Data.Content

            "Make sure $($challenge.Data.AbsoluteUrl) is reachable from outside of your network."
        }
        finally
        {
            Remove-Item $tempFile
        }

        # Signal the ACME server that the challenge is ready
        $challenge | Complete-ACMEChallenge -State $acmeStateDir;
    }

    ###
    ### 4. Issue certificate
    ### https://github.com/PKISharp/ACMESharpCore-PowerShell/blob/master/samples/IssueCertificateA.ps1
    ###

    "*** 4. Issue certificate..."

    # Wait a little bit and update the order, until we see the status 'ready' or 'invalid'
    while($order.Status -notin ("ready","invalid")) {
        Start-Sleep -Seconds 5;
        $order | Update-ACMEOrder -State $acmeStateDir -PassThru;
    }

    if($order.Status -eq "invalid") {
        throw "Your order has been marked as invalid - certificate cannot be issued."
    }

    # Complete the order - this will issue a certificate singing request
    Complete-ACMEOrder -State $acmeStateDir -Order $order -GenerateCertificateKey;

    # Now we wait until the ACME service provides the certificate url
    while(-not $order.CertificateUrl) {
        Start-Sleep -Seconds 45
        $order | Update-ACMEOrder -State $acmeStateDir -PassThru
    }

    $securePassword = ConvertTo-SecureString "XXX" –asplaintext –force
    Start-Sleep -Seconds 30
    
    "Checking Files in C:\Temp\certificates\"
    Get-ChildItem $certExportPathParent

    "Exporting..."

    # As soon as the url shows up we can create the PFX
    Export-ACMECertificate -State $acmeStateDir `
        -Order $order `
        -Path $certExportPath `
        -Password $securePassword

    Start-Sleep -Seconds 30
    "Exporting completed..."

    "Checking Files in C:\Temp\certificates\"
    Get-ChildItem $certExportPathParent

    "🚀 Wohoo! Apply new SSL Binding to $WebApp..."
    New-AzWebAppSSLBinding -ResourceGroupName $ResourceGroupName `
        -WebAppName $WebApp `
        -CertificateFilePath $certExportPath `
        -CertificatePassword "XXX" `
        -Name $Domain

    Write-Progress "END OF WARNING! Enable firewall via whitelist..."
    EnableFirewall -ResourceGroupName $ResourceGroupName -WebApp $WebApp

}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}