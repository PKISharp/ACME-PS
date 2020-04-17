# ACME-PS

A PowerShell module supporting ACME v2. The module tries to provide you with all means neccessary
to enable you to write a script or module which uses an ACME v2 service to create certificates.

Download the Module via Powershell-Gallery <https://www.powershellgallery.com/packages/ACME-PS/>

## Breaking Change in Version 1.1

Due to changes in RFC 8555 requiring POST-as-GET requests on multiple occasions, we decided to introduce a breaking change.
Most commands will now need the `State` parameter to work correctly. Be aware, that this might not be compatible with non-updated
versions of ACME-Servers.

This change also means, you cannot simply call resource urls. To look into the contents of such an URL use `Invoke-ACMESignedWebRequest -Url $myResourceUrl -State $myState`.

## Samples

You'll find a collection of [samples and descriptions here](./samples/README.md). If you find them to be
not extensive enough, feel free to provide better samples or request enhancements of them via issues.

## Certificate Chain

The certificate chain is not part of the issued certifcate. To get a correct certificate chain,
you'll need to import the intermediate certificates from your acme service.
For Lets Encrypt you can obtain them via <https://letsencrypt.org/certificates/.>

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

- Authorization

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

### Support my work

[![Donate with PayPal button](https://www.paypalobjects.com/en_US/DK/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4VVHGMBA5P3HN)

Bitcoin Wallet: bc1qr9cnq29ey3uvkutcdfsfrtf8p4lhp027krpv2u