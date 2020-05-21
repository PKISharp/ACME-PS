class AcmeChallenge {
    AcmeChallenge([PSCustomObject] $obj, [AcmeIdentifier] $identifier) {
        $this.Type = $obj.type;
        $this.Url = $obj.url;
        $this.Token = $obj.token;

        $this.Identifier = $identifier;

        $this.Status = $obj.status;
        $this.Error = $obj.error;
    }

    [string] $Type;
    [string] $Url;
    [string] $Token;

    [string] $Status;
    [string] $Error;

    [AcmeIdentifier] $Identifier;

    [PSCustomObject] $Data;
}
