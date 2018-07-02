
$ErrorActionPreference = 'Stop'

function Get-ACMETermsOfService {
<#
.DESCRIPTION
Retrieves the Terms of Service for an ACME CA.
#>

}

function New-ACMEAccount {
<#
.DESCRIPTION
Creates a new Account with an ACME CA.

.PARAMETER Emails
One or more email addresses to associate as a contact with the ACME Account.

.PARAMETER AcceptToS
Switch to indicate acceptances of ACME CA's Terms of Service.
#>

param(
	[string[]]$Emails,
	[switch]$AcceptToS
)

}

