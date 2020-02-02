<# -- Variables (multiple DNS names) -- #>

# This directory is used to store your account key and service directory urls as well as orders and related data
$acmeStateDir = "C:\Temp\AcmeState"; # Strings are automatically be converted to AcmeState

# This dns names will be used as identifier
$dnsIdentifiers = @("example.com","www.example.com"); # Strings will automatically be converted to AcmeIdentifier


<# -- Script (multiple DNS names) -- #>
Import-Module 'ACME-PS';

# Create a new order 
$order = New-ACMEOrder -State $acmeStateDir -Identifiers $dnsIdentifiers;