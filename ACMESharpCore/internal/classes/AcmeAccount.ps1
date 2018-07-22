class AcmeAccount {
    AcmeAccount([AcmeHttpResponse] $httpResponse, [string] $KeyId, [ACMESharp.Crypto.JOSE.JwsAlgorithm] $JwsAlgorithm)
    {
        $this.KeyId = $KeyId;
        $this.JwsAlgorithm = $JwsAlgorithm;

        $this.Status = $httpResponse.Content.Status;
        $this.Id = $httpResponse.Content.Id;
        $this.Contact = $httpResponse.Content.Contact;
        $this.InitialIp = $httpResponse.Content.InitialIp;
        $this.CreatedAt = $httpResponse.Content.CreatedAt;

        $this.OrderListUrl = $httpResponse.Content.Orders;
        $this.ResourceUrl = $KeyId;
    }

    [string] $ResourceUrl;

    [string] $KeyId;
    [ACMESharp.Crypto.JOSE.JwsAlgorithm] $JwsAlgorithm;

    [string] $Status;

    [string] $Id;
    [string[]] $Contact;
    [string] $InitialIp;
    [string] $CreatedAt;

    [string] $OrderListUrl;
}