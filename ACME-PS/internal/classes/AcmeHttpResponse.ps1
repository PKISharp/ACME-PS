class AcmeHttpResponse {
    AcmeHttpResponse() {}

    AcmeHttpResponse([System.Net.Http.HttpResponseMessage] $responseMessage) {
        $this.RequestUri = $responseMessage.RequestMessage.RequestUri;
        
        $this.StatusCode = $responseMessage.StatusCode;
        if($this.StatusCode -ge 400) {
            Write-Debug "StatusCode was > 400, Setting IsError true."
            $this.IsError = $true;
        }

        $this.Headers = @{};
        foreach($h in $responseMessage.Headers) {
            Write-Debug "Add Header $($h.Key) with $($h.Value)"
            $this.Headers.Add($h.Key, $h.Value);

            if($h.Key -eq "Replay-Nonce") {
                Write-Debug "Found Replay-Nonce-Header $($h.Value[0])"
                $this.NextNonce = $h.Value[0];
            }
        }

        $contentType = if ($null -ne $responseMessage.Content) { $responseMessage.Content.Headers.ContentType } else { "N/A" };
        Write-Debug "Content-type is $contentType"
        if($contentType -imatch "application/(.*\+)?json") {
            $stringContent = $responseMessage.Content.ReadAsStringAsync().GetAwaiter().GetResult();
            $this.Content = $stringContent | ConvertFrom-Json;

            if($contentType -eq "application/problem+json") {
                $this.IsError = $true;
                $this.ErrorMessage = "Server returned problem (Status: $($this.StatusCode))."
            }
        } 
        elseif ($contentType -ieq "application/pem-certificate-chain") {
            $this.Content = [byte[]]$responseMessage.Content.ReadAsByteArrayAsync().GetAwaiter().GetResult();
        }
        else {
            try {
                $this.Content = $responseMessage.Content.ReadAsStringAsync().GetAwaiter().GetResult();
            } catch {
                $this.Content = "";
            }

            if ($this.StatusCode -ge 400) {
                $this.ErrorMessage = "Unexpected server response (Status: $($this.StatusCode), ContentType: $contentType)."
            }
        }
    }

    [string] $RequestUri;
    [int] $StatusCode;
    
    [string] $NextNonce;

    [hashtable] $Headers;
    $Content;

    [bool] $IsError;
    [string] $ErrorMessage;
}