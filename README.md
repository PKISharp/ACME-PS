# ACME-PS

A PowerShell module supporting ACME v2. The module tries to provide you with all means neccessary
to enable you to write a script or module which uses an ACME v2 service to create certificates.

Download the Module via Powershell-Gallery <https://www.powershellgallery.com/packages/ACME-PS/>

## Breaking Change in Version 1.1

Due to changes in RFC 8555 requiring POST-as-GET requests on multiple occasions, we decided to introduce a breaking change.
Most commands will now need the `State` parameter to work correctly. Be aware, that this might not be compatible with non-updated
versions of ACME-Servers.

## Synopsis

- ACME service

   The ACME service or ACME directory is the server, which will issue certificates to you.

- Account Key

   The account key is used to authenticate yourself to the ACME service. After registering it with   the server make sure you do not lose the key.
   The module supports RSA and ECDSA keys with different sizes.

- Account

   The account is associated with your account key. It stores informations like contact addresses on the ACME service. As long as you have the account key, you can identify yourself as the owner of the account.

- Identifier

   An Identifier is used to describe what the certificate will be used for. It has the form `dns:www.example.com`.

- Order

   The order is the main object during certificate issuance. It has a collection of identifiers, defining all subject alternate names of the certificate.
   Also it contains an authroization object for each identifier as well as some links allowing you to send the actual certificate signing request and acquiring the certificate.

- Authroization

   An authorization is associated with an identifier. It contains a collection of challenges, of which you have to satisfy one. An authorization will be valid if one challenge is successful.

- Challenge

   A challenge provides data about what you have to do, to prove that you own the dns names you provided as identifiers via the order. The challenge needs to be completed, so the authorization is also valid and thus the order will be ready to be used for certificate issuance.

- Certificate Key

   To complete the order you need to create a key for the certificate itself. This is the public and private key for your certificate. You should keep it save until the certificate is exported.

- Service directory

   The service directory is a collection of URLs describing the endpoints of an ACME service.

- Nonce

   The nonce is used as an anti-replay token. A nonce will be send whenever you communicate with the ACME service and the service will send back a nonce which can be used with the next request.

- State

   The state is a local storage of information neccessary to make handling of request easier.

## Samples

This repoository contains a collection of [samples](samples/).  
You'll find a description of all samples in the [README.md](/samples/README.md).

These samples can be used to create an ACME account, create an order, fullfill a http-01 challenge and issue a certificate for using it.

```powershell
$stateDir = "C:\Temp\AcmeState";

$serviceName = "LetsEncrypt-Staging" # This will issue Fake Certificates - use this for testing!
$contactMail = "mail@example.com";

$dnsName = "www.example.com";
$wwwRoot = "C:\inetpub\wwwroot"
```

### Create an ACME account

This snippet will create an account key and register it with the ACME service.

```powershell
Import-Module ACME-PS;

# Create a state object and save it to the harddrive
$state = New-ACMEState -Path $stateDir

# Fetch the service directory and save it in the state
Get-ACMEServiceDirectory $state -ServiceName $serviceName -PassThru;

# Get the first anti-replay nonce
New-ACMENonce $state;

# Create an account key. The state will make sure it's stored.
New-ACMEAccountKey $state -PassThru;

# Register the account key with the acme service. The account key will automatically be read from the state
New-ACMEAccount $state -EmailAddresses $contactMail -AcceptTOS;
```

### Issue a certificate

This snippet will create an order and prepare the http-01 challenge to be resolved.
Make sure to read and understand what happens, since the script makes assumptions:

- It's a single machine (not a farm)
- The machine is reachable via http for the given $dnsName
- The website is in $wwwRoot

```powershell
# Load an state object to have service directory and account keys available
$state = Get-ACMEState -Path $stateDir;

# It might be neccessary to acquire a new nonce, so we'll just do it for the sake of the example.
New-ACMENonce $state -PassThru;

# Create the identifier for the DNS name
$identifier = New-ACMEIdentifier $dnsName;

# Create the order object at the ACME service.
$order = New-ACMEOrder $state -Identifiers $identifier;

# Fetch the authorizations for that order
$authZ = Get-ACMEAuthorization -State $state -Order $order;

# Select a challenge to fullfill
$challenge = Get-ACMEChallenge $state $authZ "http-01";

# Inspect the challenge data
$challenge.Data;

# Create the file requested by the challenge
$fileName = $wwwRoot + $challenge.Data.RelativeUrl;
$challengePath = [System.IO.Path]::GetDirectoryName($filename);
if(-not (Test-Path $challengePath)) {
  New-Item -Path $challengePath -ItemType Directory
}

Set-Content -Path $fileName -Value $challenge.Data.Content -NoNewLine;

## If you use IIS as I did - make sure theres a mimetype for files without ending.
## The mimetype can be added with extension="." and type="text/plain" in your IIS configuration.
Read-Host -Prompt "Press Enter if your web server supports extension-less files, else [CTRL]+[C]";

# Check if the challenge is readable
Invoke-WebRequest $challenge.Data.AbsoluteUrl;

## Stop here if the Invoke-WebRequest fails and make sure it passes
Read-Host -Prompt "Press Enter if Invoke-WebRequest succeeded, else [CTRL]+[C]";

# Signal the ACME server that the challenge is ready
$challenge | Complete-ACMEChallenge $state;

# Wait a little bit and update the order, until we see the states
while($order.Status -notin ("ready","invalid")) {
    Start-Sleep -Seconds 10;
    $order | Update-ACMEOrder $state -PassThru;
}

# We should have a valid order now and should be able to complete it
# Therefore we need a certificate key
$certKey = New-ACMECertificateKey -Path "$stateDir\$dnsName.key.xml";

# Complete the order - this will issue a certificate singing request
Complete-ACMEOrder $state -Order $order -CertificateKey $certKey;

# Now we wait until the ACME service provides the certificate url
while(-not $order.CertificateUrl) {
    Start-Sleep -Seconds 15
    $order | Update-Order $state -PassThru
}

# As soon as the url shows up we can create the PFX
Export-ACMECertificate $state -Order $order -CertificateKey $certKey -Path "$stateDir\$dnsName.pfx";
```

Now you have a ready to use certificate containing the public and private keys.
If any problems arise, feel free to open an issue.

#### Certificate Chain

The certificate chain is not part of the issued certifcate. To get a correct certificate chain,
you'll need to import the intermediate certificates from your acme service.
For Lets Encrypt you can obtain them via <https://letsencrypt.org/certificates/.>

## How to

### Build the module

To create the output, which will be released to PSGallery, call :

```powershell
PS> & .\build.ps1
```

### Test the module

To run the Pester-Tests call:

```powershell
PS> & .\ACME-PS\tests\A-Manual-Test-Run.ps1
```
