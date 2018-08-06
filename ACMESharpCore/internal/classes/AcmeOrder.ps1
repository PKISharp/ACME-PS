class AcmeOrder {
    AcmeOrder([AcmeHttpResponse] $httpResponse)
    {
        $this.HttpResponse = $httpResponse;

        $this.Status = $httpResponse.Content.Status;
        $this.Expires  = $httpResponse.Content.Expires;

        $this.NotBefore = $httpResponse.Content.NotBefore;
        $this.NotAfter = $httpResponse.Content.NotAfter;

        $this.Identifiers = $httpResponse.Content.Identifiers | ForEach-Object { [AcmeIdentifier]::new($_) };

        $this.AuthorizationUrls = $httpResponse.Content.Authorizations;
        $this.FinalizeUrl = $httpResponse.Content.Finalize;

        $this.CertificateUrl = $httpResponse.Content.Certificate;

        $this.ResourceUrl = $httpResponse.Headers.Location[0];
    }

    [AcmeHttpResponse] $HttpResponse;
    [string] $ResourceUrl;

    [string] $Status;
    [System.DateTimeOffset] $Expires;

    [Nullable[System.DateTimeOffset]] $NotBefore;
    [Nullable[System.DateTimeOffset]] $NotAfter;

    [AcmeIdentifier[]] $Identifiers;

    [string[]] $AuthorizationUrls;
    [string] $FinalizeUrl;

    [string] $CertificateUrl;
}