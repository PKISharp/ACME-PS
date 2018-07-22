class AcmeAuthorization {
    AcmeAuthorization([AcmeHttpResponse] $httpResponse)
    {
        $this.status = $httpResponse.Content.status;
        $this.expires = $httpResponse.Content.expires;

        $this.identifier = [AcmeIdentifier]::new($httpResponse.Content.identifier);
        $this.challenges = @($httpResponse.Content.challenges | ForEach-Object { [AcmeChallenge]::new($_, $this.identifier) });

        $this.wildcard = $httpResponse.Content.wildcard;
        $this.ResourceUrl = $httpResponse.RequestUri;
    }

    [string] $ResourceUrl;

    [string] $status;
    [System.DateTimeOffset] $expires;

    [AcmeIdentifier] $identifier;
    [AcmeChallenge[]] $challenges;

    [bool] $wildcard;
}