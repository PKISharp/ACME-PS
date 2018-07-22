class AcmeAuthroization {
    AcmeAuthroization([AcmeHttpResponse] $httpResponse)
    {
        $this.status = $httpResponse.Content.status;
        $this.expires = $httpResponse.Content.expires;

        $this.identifier = [AcmeIdentifier]::new($httpResponse.Content.identifier);
        $this.challenges = @($httpResponse.Content.challenges | ForEach-Object { [AcmeChallenge]::new($_, $this.identifier) });

        $this.wildcard = $httpResponse.Content.wildcard;
        $this.ResourceUri = $httpResponse.RequestUri;
    }

    [string] $ResourceUri;

    [string] $status;
    [System.DateTimeOffset] $expires;

    [AcmeIdentifier] $identifier;
    [AcmeChallenge[]] $challenges;

    [bool] $wildcard;
}