class AcmeIdentifier {
    AcmeIdentifier([string] $type, [string] $value) {
        $this.Type = $type;
        $this.Value = $value;
    }

    AcmeIdentifier([PsCustomObject] $obj) {
        $this.type = $obj.type;
        $this.value = $obj.Value;
    }

    [string] $type;
    [string] $value;

    [string] ToString() {
        return "$($this.Type.ToLower()):$($this.Value.ToLower())";
    }
}