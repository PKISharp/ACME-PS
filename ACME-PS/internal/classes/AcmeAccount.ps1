class AcmeAccount {
    [string] $ResourceUrl;
    [PSCustomObject] $AcmeObject;

    static hidden [hashtable[]] $_memberDefinitions = @(
        # Non RFC 8555 property    
        @{MemberName = "KeyId";     Value = { $this.ResourceUrl } },
        # Non RFC 8555 property
        @{MemberName = "Id";        Value = { $this.AcmeObject.id } },
        
        @{MemberName = "Status";    Value = { $this.AcmeObject.status } },
        @{MemberName = "Contact";   Value = { $this.AcmeObject.contact } },
        @{MemberName = "ExternalAccountBinding"; Value = { $this.AcmeObject.externalAccountBinding } },
        @{MemberName = "TermsOfServiceAgreed"; Value = { $this.AcmeObject.termsOfServiceAgreed } },
        @{MemberName = "Orders";    Value = { $this.AcmeObject.orders } }
    );
    
    static AcmeAccount() {
        $TypeName = [AcmeAccount].Name
        foreach ($definition in [AcmeAccount]::_memberDefinitions) {
            Update-TypeData -TypeName $TypeName -MemberType 'ScriptProperty' @definition
        }
    }

    AcmeAccount([PSCustomObject] $acmeObject, [string] $ResourceUrl = $null) {
        $this.ResourceUrl = if ($null -ne $ResourceUrl) { $ResourceUrl } else { $acmeObject.ResourceUrl };
        $this.AcmeObject = $acmeObject;
    }

    [hashtable] ToHashtable() {
        $hashtable = @{
            ResourceUrl = $this.ResourceUrl
        }
        $this.AcmeObject.PSObject.Properties | ForEach-Object {
            $hashtable[$_.Name] = $_.Value
        }

        return $hashtable
    }

    [string] ToJson() {
        return $this.ToHashtable() | ConvertTo-Json;
    }
}
