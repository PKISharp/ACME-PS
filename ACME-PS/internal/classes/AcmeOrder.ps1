class AcmeOrder {
    AcmeOrder([PsCustomObject] $obj) {
        $this.Status = $obj.Status;
        $this.Expires  = $obj.Expires;
        $this.NotBefore = $obj.NotBefore;
        $this.NotAfter = $obj.NotAfter;

        $this.Identifiers = $obj.Identifiers | ForEach-Object { [AcmeIdentifier]::new($_) };
        if ([string]::IsNullOrWhiteSpace($this.PrimaryDomain)) {
            $this.PrimaryDomain = $this.Identifiers[0].Value
        }

        $this.AuthorizationUrls = $obj.AuthorizationUrls;
        $this.FinalizeUrl = $obj.FinalizeUrl;
        $this.CertificateUrl = $obj.CertificateUrl;

        $this.ResourceUrl = $obj.ResourceUrl;
    }

    AcmeOrder([AcmeHttpResponse] $httpResponse)
    {
        $this.UpdateOrder($httpResponse)
    }

    [void] UpdateOrder([AcmeHttpResponse] $httpResponse) {
        $this.Status = $httpResponse.Content.Status;
        $this.Expires  = $httpResponse.Content.Expires;

        $this.NotBefore = $httpResponse.Content.NotBefore;
        $this.NotAfter = $httpResponse.Content.NotAfter;

        $this.Identifiers = $httpResponse.Content.Identifiers | ForEach-Object { [AcmeIdentifier]::new($_) };
        if ([string]::IsNullOrWhiteSpace($this.PrimaryDomain)) {
            $this.PrimaryDomain = $this.Identifiers[0].Value
        }

        $this.AuthorizationUrls = $httpResponse.Content.Authorizations;
        $this.FinalizeUrl = $httpResponse.Content.Finalize;

        $this.CertificateUrl = $httpResponse.Content.Certificate;

        if($httpResponse.Headers.Location) {
            $this.ResourceUrl = $httpResponse.Headers.Location[0];
        } else {
            $this.ResourceUrl = $httpResponse.RequestUri;
        }
    }

    [string] $ResourceUrl;

    [string] $Status;
    [string] $Expires;

    [Nullable[System.DateTimeOffset]] $NotBefore;
    [Nullable[System.DateTimeOffset]] $NotAfter;

    [AcmeIdentifier[]] $Identifiers;
    [string] $PrimaryDomain

    [string[]] $AuthorizationUrls;
    [string] $FinalizeUrl;

    [string] $CertificateUrl;
}