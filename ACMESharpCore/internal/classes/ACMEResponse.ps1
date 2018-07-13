class ACMEResponse {
    ACMEResponse([Microsoft.PowerShell.Commands.WebResponseObject] $response) {
        $this.NextNonce = $response.Headers["replay-nonce"];
        $this.Content = $response.Content | ConvertFrom-Json;
    }

    [PSCustomObject] $Content;
    [string] $NextNonce;
}