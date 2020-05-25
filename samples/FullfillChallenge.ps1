<# -- Variables -- #>

# This directory is used to store your account key and service directory urls as well as orders and related data
$acmeStateDir = "C:\Temp\AcmeState";

# This directory should point to your web-server document root.
$documentRoot = "C:\inetpub\wwwroot";

# This dns names had been used to create the order
$dnsIdentifiers = New-ACMEIdentifier "www.example.com"; 


<# -- Script -- #>
Import-Module 'ACME-PS';

if ($null -eq $order) { # Will fetch the order, if you don't have it already
    $order = Find-ACMEOrder -State $acmeStateDir -Identifiers $dnsIdentifiers;
}

# Fetch the authorizations for that order
$authorizations = @(Get-ACMEAuthorization -State $acmeStateDir -Order $order);

foreach($authz in $authorizations) {
    # Select a challenge to fullfill
    $challenge = Get-ACMEChallenge -State $acmeStateDir -Authorization $authZ -Type "http-01";

    # Inspect the challenge data (uncomment, if you want to see the object)
    # Depending on the challenge-type this will include different properties
    # $challenge.Data;

    $chFilename = [System.IO.Path]::Combine($documentRoot, $challenge.Data.RelativeUrl);
    $chDirectory = [System.IO.Path]::GetDirectoryName($chFilename);

    # Ensure the challenge directory exists
    if(-not (Test-Path $chDirectory)) {
        New-Item -Path $chDirectory -ItemType Directory;
    }

    Set-Content -Path $chFilename -Value $challenge.Data.Content -NoNewline;

    do {
        ## Sample content - not needed in production.
        $prompt = "Make sure $($challenge.Data.AbsoluteUrl) is reachable from outside of your network. If yes, type 'y'";
        $promptResult = $PSCmdlet.ShouldContinue($prompt, "URL reachable?");
    } while(-not $promptResult);

    # Signal the ACME server that the challenge is ready
    $challenge | Complete-ACMEChallenge -State $acmeStateDir;
}

# Wait a little bit and update the order, until we see the status 'ready' or 'invalid'
while($order.Status -notin ("ready","invalid")) {
    Start-Sleep -Seconds 10;
    $order | Update-ACMEOrder -State $acmeStateDir -PassThru;
}


# Should the order get invalid, use Get-ACMEAuthorizationError to list error details.
if($order.Status -ieq ("invalid")) {
    $order | Get-ACMEAuthorizationError -State $acmeStateDir;
    throw "Order was invalid";
}
