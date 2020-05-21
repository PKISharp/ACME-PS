class AcmeHttpException : System.Exception {
    AcmeHttpException([string]$_message, [AcmeHttpResponse]$_response)
        :base($_message) 
    {
        $this.Response = $_response;
    }

    [AcmeHttpResponse]$Response;
}
