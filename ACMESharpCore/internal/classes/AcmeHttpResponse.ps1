class AcmeHttpResponse {
    AcmeHttpResponse([System.Net.Http.HttpResponseMessage] $responseMessage, [string] $stringContent) {   
        $this.RequestUri = $responseMessage.RequestMessage.RequestUri;
        
        $this.NextNonce = $responseMessage.Headers.GetValues("Replay-Nonce")[0];
        $this.StatusCode = $responseMessage.StatusCode;

        if($stringContent) {
            $this.Content = $stringContent | ConvertFrom-Json;
        }

        $this.Headers = @{};
        foreach($h in $responseMessage.Headers) {
            $this.Headers.Add($h.Key, $h.Value);
        }
    }

    [string] $RequestUri;
    [int] $StatusCode;

    [PSCustomObject] $Content;
    [hashtable] $Headers;

    [string] $NextNonce;
}