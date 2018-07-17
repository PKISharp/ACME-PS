class AcmeObject {
    AcmeObject() {}

    AcmeObject([AcmeHttpResponse] $httpResponse) {
        $this.NextNonce = $httpResponse.NextNonce
    }

    [string] $NextNonce
}