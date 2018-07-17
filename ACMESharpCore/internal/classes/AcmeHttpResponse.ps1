class AcmeHttpResponse {
    AcmeHttpResponse([System.Net.Http.HttpResponseMessage] $responseMessage, [string] $stringContent) {      
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

    [int] $StatusCode;

    [PSCustomObject] $Content;
    [hashtable] $Headers;

    [string] $NextNonce;
}