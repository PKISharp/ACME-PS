class AcmeIdentifier {
    AcmeIdentifier([string] $type, [string] $value) {
        $this.Type = $type;
        $this.Value = $value;
    }

    [string] $Type;
    [string] $Value;
}