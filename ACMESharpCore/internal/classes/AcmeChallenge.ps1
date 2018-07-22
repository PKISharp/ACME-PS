class AcmeChallenge {
    AcmeChallenge([PSCustomObject] $obj, [AcmeIdentifier] $identifier) {
        $this.type = $obj.type;
        $this.url = $obj.url;
        $this.token = $obj.token;

        $this.identifier = $identifier;
    }

    [string] $type;
    [string] $url;
    [string] $token;

    [AcmeIdentifier] $identifier;
}