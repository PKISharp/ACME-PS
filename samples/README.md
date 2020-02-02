# Samples

Some samples depend on each other, since most will need an existing state and acme account.
All used variables will be defined on top of the scripts.

If you want to know more about the used commands, refer to `Get-Help`

## Create an new account

The [sample](./CreateAccount.ps1) will create a state object, an account key and register an account with the acme service.

## Create a new order

The sample will create orders with [single](./CreateOrderS.ps1) and [multiple](./CreateOrderM.ps1) dns names.

## Fullfill challenges

The [sample](./FullfillChallenge.ps1) will fullfill http-01 challenges for existing orders.  
For the sample to work properly, you need to ensure, your web-server is able to serve extensionless files.
For IIS this can be enabled with [this script](./IISExtensionless.ps1).

## Issue certificate

The samples will show how to issue a certificate. Use [this sample](./IssueCertificateA.ps1) for automatically generated certificate keys or [this sample](./IssueCertificateC.ps1) for custom key material.
