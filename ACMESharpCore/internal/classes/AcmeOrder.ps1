class AcmeOrder : AcmeObject {
    AcmeOrder([AcmeHttpResponse] $httpResponse)
    : base($httpResponse) {
        $this.Status = $httpResponse.Content.Status;
        $this.Expires  = $httpResponse.Content.Expires;
   
        $this.NotBefore = $httpResponse.Content.NotBefore;
        $this.NotAfter = $httpResponse.Content.NotAfter;
   
        $this.Identifiers = $httpResponse.Content.Identifiers | Select-Object { [AcmeIdentifier]::new($_.Type, $_.Value) };
   
        $this.AuthorizationUrls = $httpResponse.Content.Authorizations;
        $this.FinalizeUrl = $httpResponse.Content.Finalize;
    }

    [string] $Status;
    [System.DateTimeOffset] $Expires;
   
    [System.DateTimeOffset] $NotBefore;
    [System.DateTimeOffset] $NotAfter;
   
    [AcmeIdentifier[]] $Identifiers;
   
    [string[]] $AuthorizationUrls;
    [string] $FinalizeUrl;
}