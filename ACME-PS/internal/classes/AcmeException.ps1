class AcmeHttpException : System.Exception {
    AcmeHttpException([string]$_message, [AcmeHttpResponse]$_response) {
        $this.Message = $_message;
        $this.Response = $_response;
    }

    [AcmeHttpResponse]$Response;
}