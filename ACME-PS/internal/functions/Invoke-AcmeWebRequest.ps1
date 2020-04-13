function Invoke-ACMEWebRequest {
    <#
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [Alias("Url")]
        [uri] $Uri,

        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [string]
        $JsonBody,

        [Parameter(Mandatory = $true)]
        [ValidateSet("GET", "POST", "HEAD")]
        [string]
        $Method
    )

    $httpRequest = [System.Net.Http.HttpRequestMessage]::new($Method, $Uri);
    Write-Verbose "Sending HttpRequest ($Method) to $Uri";

    if($Method -in @("POST", "PUT")) {
        $httpRequest.Content = [System.Net.Http.StringContent]::new($JsonBody, [System.Text.Encoding]::UTF8);
        $httpRequest.Content.Headers.ContentType = "application/jose+json";

        Write-Debug "The content of the request is $JsonBody";
    }

    try {
        $httpClient = [System.Net.Http.HttpClient]::new();
        $httpResponse = $httpClient.SendAsync($httpRequest).GetAwaiter().GetResult();
        $result = [AcmeHttpResponse]::new($httpResponse);
    } catch {
        $result = [AcmeHttpResponse]::new();
        $result.IsError = $true;
        $result.ErrorMessage = $_.Exception.Message;
        $result.Content = $_.Exception;
    }

    return $result;
}