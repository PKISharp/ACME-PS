class AcmeIdentifier {
    [PSCustomObject] $AcmeObject;

    hidden [string] $_type;
    hidden [string] $_value;


    hidden static [hashtable[]] $_memberDefinitions = @(
        @{MemberName = "Type";  Value = { if ($null -ne $this.AcmeObject) { $this.AcmeObject.type } else { $this._type } } },
        @{MemberName = "Value"; Value = { if ($null -ne $this.AcmeObject) { $this.AcmeObject.value } else { $this._value } } }
    );

    static AcmeIdentifier() {
        $TypeName = [AcmeIdentifier].Name
        foreach ($definition in [AcmeIdentifier]::_memberDefinitions) {
            Update-TypeData -TypeName $TypeName -MemberType 'ScriptProperty' @definition
        }
    }
    
    
    AcmeIdentifier([string] $value) {
        $this._type = "dns";
        $this._value = $value;
    }

    AcmeIdentifier([string] $type, [string] $value) {
        $this._type = $type;
        $this._value = $value;
    }

    AcmeIdentifier([PsCustomObject] $acmeObject) {
        $this.AcmeObject = $acmeObject;
    }


    [string] ToString() {
        return "$($this.Type):$($this.Value)";
    }

    [hashtable] ToHashtable() {
        return @{
            Type = $this.Type;
            Value = $this.Value;
        }
    }

    [string] ToJson() {
        return $this.ToHashtable() | ConvertTo-Json -Depth 1;
    }


    static [AcmeIdentifier] Parse([string] $textValue) {
        if ($textValue -like "*:*") {
            $__type, $__value = $textValue -split ":",2;
            return [AcmeIdentifier]::new($__type, $__value);
        }

        return [AcmeIdentifier]::new($textValue);
    }
}
