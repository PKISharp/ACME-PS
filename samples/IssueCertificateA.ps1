<# -- Variables -- #>

# This directory is used to store your account key and service directory urls as well as orders and related data
$acmeStateDir = "C:\Temp\AcmeState";

# This path will be used to export your certificate file.
$certExportPath = "C:\Temp\certificates\certificate.pfx";

# This dns names had been used to create the order
$dnsIdentifiers = New-ACMEIdentifier "www.example.com"; 


<# -- Script -- #>
Import-Module 'ACME-PS';

if ($null -eq $order) { # Will fetch the order
    $order = Find-ACMEOrder -State $acmeStateDir -Identifiers $dnsIdentifiers;
}

# Wait a little bit and update the order, until we see the status 'ready' or 'invalid'
while($order.Status -notin ("ready","invalid")) {
    Start-Sleep -Seconds 10;
    $order | Update-ACMEOrder -State $acmeStateDir -PassThru;
}

if($order.Status -eq "invalid") {
    throw "Your order has been marked as invalid - certificate cannot be issued."
}

# Complete the order - this will issue a certificate singing request
Complete-ACMEOrder -State $acmeStateDir -Order $order -GenerateCertificateKey;

# Now we wait until the ACME service provides the certificate url
while(-not $order.CertificateUrl) {
    Start-Sleep -Seconds 15
    $order | Update-Order -State $acmeStateDir -PassThru
}

# As soon as the url shows up we can create the PFX
Export-ACMECertificate -State $acmeStateDir -Order $order -Path "$certExportPath.pfx";
