<# -- Variables -- #>

# This directory is used to store your account key and service directory urls as well as orders and related data
$acmeStateDir = "C:\Temp\AcmeState";

# This directory should point to your web-server document root.
$documentRoot = "C:\inetpub\wwwroot";

# This dns names had been used to create the order
$dnsIdentifiers = New-ACMEIdentifier "www.example.com"; 

# The order that has been created (skip if you have one saved)
$myOrder = Find-ACMEOrder -State $acmeStateDir -Identifiers $dnsIdentifiers;


<# -- Script -- #>

Import-Module 'ACME-PS';
