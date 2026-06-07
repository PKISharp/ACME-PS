class AcmeChallenge {
    [PSCustomObject] $AcmeObject;
    [PSCustomObject] $Data;

    static hidden [hashtable[]] $_memberDefinitions = @(
        @{MemberName = "Type";   Value = { $this.AcmeObject.type } },
        @{MemberName = "Url";    Value = { $this.AcmeObject.url } },
        @{MemberName = "Token";  Value = { $this.AcmeObject.token } },
        @{MemberName = "Status"; Value = { $this.AcmeObject.status } },
        @{MemberName = "Error";  Value = { $this.AcmeObject.error } }
    );

    static AcmeChallenge() {
        $TypeName = [AcmeChallenge].Name
        foreach ($definition in [AcmeChallenge]::_memberDefinitions) {
            Update-TypeData -TypeName $TypeName -MemberType 'ScriptProperty' @definition
        }
    }


    AcmeChallenge([PSCustomObject] $acmeObject) {
        $this.AcmeObject = $acmeObject;
    }

    [hashtable] ToHashtable() {
        $hashtable = @{}
        $this.AcmeObject.PSObject.Properties | ForEach-Object {
            $hashtable[$_.Name] = $_.Value
        }

        return $hashtable;
    }

    [string] ToJson() {
        return $this.ToHashtable() | ConvertTo-Json;
    }
}
