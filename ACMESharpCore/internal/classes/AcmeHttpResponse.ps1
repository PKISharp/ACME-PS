class AcmeHttpResponse {
    AcmeHttpResponse() {}

    AcmeHttpResponse([System.Net.Http.HttpResponseMessage] $responseMessage, [string] $stringContent) {
        $this.RequestUri = $responseMessage.RequestMessage.RequestUri;
        $this.StatusCode = $responseMessage.StatusCode;

        if($stringContent) {
            $this.Content = $stringContent | ConvertFrom-Json;
        }

        $this.Headers = @{};
        foreach($h in $responseMessage.Headers) {
            $this.Headers.Add($h.Key, $h.Value);

            if($h.Key -eq "Replay-Nonce") {
                $this.NextNonce = $h.Value[0];
            }
        }
    }

    [string] $RequestUri;
    [int] $StatusCode;

    [PSCustomObject] $Content;
    [hashtable] $Headers;

    [string] $NextNonce;
}