<# -- Variables -- #>

# ServiceName (valid names are LetsEncrypt and LetsEncrypt-Stagign, use the latter one for testing your scripts).
$acmeServiceName = "LetsEncrypt-Staging";

# Your email addresses, where acme services will send informations.
$contactMailAddresses = @("mail@example.com", "mail2@example.com");

# This directory is used to store your account key and service directory urls as well as orders and related data
$acmeStateDir = "C:\Temp\AcmeState";


<# -- Script -- #>

Import-Module 'ACME-PS';

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