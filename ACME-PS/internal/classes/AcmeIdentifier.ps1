class AcmeIdentifier {
    static [AcmeIdentifier] Parse([string] $textValue) {
        if($textValue -contains ":") {
            $_type, $_value = $textValue -split ":",2;
            return [AcmeIdentifier]::new($_type, $_value);
        }

        return [AcmeIdentifier]::new($textValue);
    }

    AcmeIdentifier([string] $value) {
        $this.Type = "dns";
        $this.Value = $value;
    }

    AcmeIdentifier([string] $type, [string] $value) {
        $this.Type = $type;
        $this.Value = $value;
    }

    AcmeIdentifier([PsCustomObject] $obj) {
        $this.type = $obj.type;
        $this.value = $obj.Value;
    }

    [string] $Type;
    [string] $Value;

    [string] ToString() {
        return "$($this.Type.ToLower()):$($this.Value.ToLower())";
    }
}
