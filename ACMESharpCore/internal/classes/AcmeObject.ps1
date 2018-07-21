class AcmeObject {
    AcmeObject() {}

    AcmeObject([AcmeHttpResponse] $httpResponse) {
        $this.ResourceUri = $httpResponse.RequestUri;
    }

    [string] $ResourceUri;
}