class AcmeAccount {
    AcmeAccount([AcmeHttpResponse] $httpResponse, [string] $KeyId)
    {
        $this.HttpResponse = $httpResponse;
        $this.KeyId = $KeyId;

        $this.Status = $httpResponse.Content.Status;
        $this.Id = $httpResponse.Content.Id;
        $this.Contact = $httpResponse.Content.Contact;
        $this.InitialIp = $httpResponse.Content.InitialIp;
        $this.CreatedAt = $httpResponse.Content.CreatedAt;

        $this.OrderListUrl = $httpResponse.Content.Orders;
        $this.ResourceUrl = $KeyId;
    }

    [AcmeHttpResponse] $HttpResponse
    [string] $ResourceUrl;

    [string] $KeyId;

    [string] $Status;

    [string] $Id;
    [string[]] $Contact;
    [string] $InitialIp;
    [string] $CreatedAt;

    [string] $OrderListUrl;
}