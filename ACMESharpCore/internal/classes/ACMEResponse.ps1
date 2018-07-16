class ACMEResponse {
    ACMEResponse([Microsoft.PowerShell.Commands.WebResponseObject] $response) {
        $this.NextNonce = $response.Headers["replay-nonce"];
        $this.Content = $response.Content | ConvertFrom-Json;
    }

    ACMEResponse([System.Net.Http.HttpResponseMessage] $responseMessage, [string] $stringContent) {
        $this.NextNonce = $responseMessage.Headers["replay-nonce"];
        $this.Content = $stringContent | ConvertFrom-Json;
    }

    [PSCustomObject] $Content;
    [string] $NextNonce;
}