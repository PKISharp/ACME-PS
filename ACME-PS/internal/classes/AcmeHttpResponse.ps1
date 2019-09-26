class AcmeHttpResponse {
    AcmeHttpResponse() {}

    AcmeHttpResponse([System.Net.Http.HttpResponseMessage] $responseMessage) {
        $this.RequestUri = $responseMessage.RequestMessage.RequestUri;
        
        $this.StatusCode = $responseMessage.StatusCode;
        $this.IsError = $this.StatusCode -ge 400;

        $this.Headers = @{};
        foreach($h in $responseMessage.Headers) {
            $this.Headers.Add($h.Key, $h.Value);

            if($h.Key -eq "Replay-Nonce") {
                $this.NextNonce = $h.Value[0];
            }
        }

        $contentType = $responseMessage.Headers.ContentType;
        if($contentType -imatch "application/(.*\+)?json") {
            $stringContent = $responseMessage.Content.ReadAsStringAsync().GetAwaiter().GetResult();
            $this.Content = $stringContent | ConvertFrom-Json;

            if($contentType -eq "application/problem+json") {
                $this.IsError = $true;
            }
        } elseif ($contentType -ieq "application/pem-certificate-chain"){
            $this.Content = [byte[]]$responseMessage.Content;
        } else {
            $this.IsError = true;
            $this.Content = "Unexpected server response."
        }
    }

    [string] $RequestUri;
    [int] $StatusCode;
    [bool] $IsError;

    $Content;
    [hashtable] $Headers;

    [string] $NextNonce;
}