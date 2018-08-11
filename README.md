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

This small how-to will assume, that you do not want to handle service directory, nonce and accounts and leave that to the module.

```
PS> Import-Module AcmeSharpCore

# This will load the service directoy for Let's-Encrypt-Staging
PS> $directory = Get-AcmeServiceDirectory -AutomaticNonceHandling -AutomaticDirectoryHandling
PS> $directory | Export-Clixml -Path C:\AcmeTemp\ServiceDirectory.xml

# Create and export RSA account key
PS> New-AcmeAccountKey -Path C:\AcmeTemp\AccountKey.xml -AutomaticAccountKeyHandling

# Register account with ACME service
PS> New-AcmeAccount -AcceptTOS -EmailAddresses "mail@example.com"
```

This sequence will create a new account and account keys, to further usage.  
From here we'll start over with the existing key and account.

```
PS> Import-Moduel AcmeSharpCore

# Reload service directory
PS> Get-AcmeServiceDirectory -Path C:\AcmeTemp\ServiceDirectory.xml -AutomaticNonceHandling -AutomaticDirectoryHandling

# Load account key
PS> Get-AcmeAccountKey -Path C:\AcmeTemp\AccountKey.xml -AutomaticAccountKeyHandling

# Get account object
PS> Get-AcmeAccount -AutomaticAccountHandling

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

This will create a hashtable with all information neccessary to fullfill the challenge. The module does not provide tools to handle the challenge, but we are open to issues and PRs to add functions to handle whatever is neccessary.

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
PS> do { 
    Start-Sleep 60; 
    Update-AcmeOrder $order 
    } while (-not $order.CertificateUrl);

# Get Certificate
PS> Export-AcmeCertificate -Order $order -CertificateKey $certKey -Path C:\AcmeTemp\www.example.com.pfx

# Use the certificate (milage may vary, since you might create key and cert PEMs from PFX).
```