# ACMESharpCore-PowerShell

A PowerShell module supporting ACME v2 certificate management.

## How to create the published module

To create the output, which will be released to PSGallery, call :

```
PS> & build.ps1
```

## How to test the module

To run the Pester-Tests call:

```
PS> & .\AcmeSharpCore\tests\A-Manual-Test-Run.ps1
```

## How to use the module

This sequence will create a new account and account keys, to further usage.

```
PS> Import-Module AcmeSharpCore

# Create a acme state instance, which will make passing around of neccessary informations easy.
PS> $state = New-AcmeState

# This will load the service directoy for Let's-Encrypt-Staging and save.
PS> Get-AcmeServiceDirectory $state -PassThrough | Export-Clixml -Path C:\AcmeTemp\ServiceDirectory.xml

# Create and export RSA account key
PS> New-AcmeAccountKey $state -Path C:\AcmeTemp\AccountKey.xml

# Register account with ACME service
PS> New-AcmeAccount $state -AcceptTOS -EmailAddresses "mail@example.com"
```

From here we'll start over with the existing key and account.

```
PS> Import-Moduel AcmeSharpCore

# Initialize state with existing data (loads service directory, account key, a new nonce and your account)
PS> $state = Initialize-AcmeState -DirectoryPath C:\AcmeTemp\ServiceDirectory.xml -AccountKeyPath C:\AcmeTemp\AccountKey.xml

# Create Identifier(s)
PS> $identifier = New-AcmeIdentifier "www.example.com"

# Create Order
PS> $order = New-AcmeOrder -Identifiers $identifier

# Read Authoriatzions
PS> $authZ = $order | Get-Authorizations

# Pick a challenge
PS> $challenge = $authZ | Get-AcmeChallenge http-01
PS> $challenge | Show-AcmeChallenge
```

This will create a hashtable with all information neccessary to fullfill the challenge. The module does currently not provide tools to handle the challenge, but we are open to PRs adding functions to handle whatever is neccessary.

```
# After preparing the challenge
PS> $challenge | Complete-AcmeChallenge

# After a while we should be able to see the order state changes to valid

PS> Start-Sleep 60
PS> Update-AcmeOrder $order

# Create certificate key
PS> $certKey = New-AcmeCertificateKey -Path C:\AcmeTemp\CertKey_www.example.com.xml

# Complete the order
PS> Complete-Order -Order $order -CertificateKey $certKey

# Check for Certificate Url
PS> while (-not $order.CertificateUrl) {
    Start-Sleep 60;
    Update-AcmeOrder $order
} ;

# Get Certificate
PS> Export-AcmeCertificate -Order $order -CertificateKey $certKey -Path C:\AcmeTemp\www.example.com.pfx

# Use the certificate (milage may vary, since you might create key and cert PEMs from PFX via openssl).
```