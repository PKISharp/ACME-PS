class AcmeAccount : AcmeObject {
    AcmeAccount([AcmeHttpResponse] $httpResonse)
        : base($httpResonse)
    {
        $this.KeyId = $httpResonse.Headers["Location"][0]
    }
}