function Invoke-ACMEWebRequest {
    <#
    #>
    [CmdletBinding()]
    param(
        # Parameter help description
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [uri]
        $Uri,

        # Parameter help description
        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [string]
        $JsonBody,

        # Parameter help description
        [Parameter(Mandatory = $true)]
        [ValidateSet("GET", "POST", "HEAD")]
        [string]
        $Method,

        # Parameter help description
        [Parameter()]
        [ValidateNotNull()]
        [hashtable]
        $Headers
    )

    $httpRequest = [System.Net.Http.HttpRequestMessage]::new($Method, $Uri);
    Write-Verbose "Sending HttpRequest ($Method) to $Uri";
    
    foreach($header in $Headers) {
        $httpRequest.Headers.Add($header.Key, $header.Value)
    }

    if($Method -in @("POST", "PUT")) {
        $httpRequest.Content = [System.Net.Http.StringContent]::new($JsonBody, [System.Text.Encoding]::UTF8);
        $httpRequest.Content.Headers.ContentType = "application/jose+json";

        Write-Debug "The content of the request is $JsonBody";
    }

    #TODO: This should possibly swapped out to be something singleton-ish.
    $httpClient = [System.Net.Http.HttpClient]::new();

    $httpResponse = $httpClient.SendAsync($httpRequest).GetAwaiter().GetResult();
    $response = $httpResponse.Content.ReadAsStringAsync().GetAwaiter().GetResult();

    if($httpResponse.IsSuccessStatusCode) {
        return [ACMEResponse]::new($httpResponse, $response);
    }

    if($httpResponse.Content.Headers.ContentType -eq "application/problem+json") {
        Write-Error "Server returned Problem: $response"
        return [ACMEResponse]::new($httpResponse, $response);
    }

    Write-Error "Unexpected response from server: $($httpResponse.StatusCode), with content:`n$response"
    return $response;
}