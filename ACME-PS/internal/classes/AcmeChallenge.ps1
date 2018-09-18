class AcmeChallenge {
    AcmeChallenge([PSCustomObject] $obj, [AcmeIdentifier] $identifier) {
        $this.Type = $obj.type;
        $this.Url = $obj.url;
        $this.Token = $obj.token;

        $this.Identifier = $identifier;
    }

    [string] $Type;
    [string] $Url;
    [string] $Token;

    [AcmeIdentifier] $Identifier;

    [PSCustomObject] $Data;
}