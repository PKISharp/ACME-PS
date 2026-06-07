class AcmeDirectory {
    [string] $ResourceUrl;
    [PSCustomObject] $AcmeObject;
    [AcmeDirectoryMeta] $Meta;

    static hidden [hashtable[]] $_memberDefinitions = @(
        @{MemberName = "NewAccount"; Value = { $this.AcmeObject.newAccount } },
        @{MemberName = "NewAuthz"; Value = { $this.AcmeObject.newAuthz } },
        @{MemberName = "NewNonce"; Value = { $this.AcmeObject.newNonce } },
        @{MemberName = "NewOrder"; Value = { $this.AcmeObject.newOrder } },
        @{MemberName = "KeyChange"; Value = { $this.AcmeObject.keyChange } },
        @{MemberName = "RevokeCert"; Value = { $this.AcmeObject.revokeCert } }
    );

    static AcmeDirectory() {
        $TypeName = [AcmeDirectory].Name
        foreach ($definition in [AcmeDirectory]::_memberDefinitions) {
            Update-TypeData -TypeName $TypeName -MemberType 'ScriptProperty' @definition
        }
    }

    AcmeDirectory([PSCustomObject] $obj, [string] $ResourceUrl = $null) {
        $this.ResourceUrl = if ($null -ne $ResourceUrl) { $ResourceUrl } else { $obj.ResourceUrl }
        $this.AcmeObject = $obj;

        $this.Meta = [AcmeDirectoryMeta]::new($obj.meta);
    }

    [string] ToJson() {
        $hashtable = @{
            ResourceUrl = $this.ResourceUrl
        }
        $this.AcmeObject.PSObject.Properties | ForEach-Object {
            $hashtable[$_.Name] = $_.Value
        }

        return $hashtable | ConvertTo-Json -Depth 5;
    }
}

class AcmeDirectoryMeta {
    [PSCustomObject] $AcmeObject;

    static hidden [hashtable[]] $_memberDefinitions = @(
        @{MemberName = "CaaIdentities"; Value = { $this.AcmeObject.caaIdentities } },
        @{MemberName = "TermsOfService"; Value = { $this.AcmeObject.termsOfService } },
        @{MemberName = "Website"; Value = { $this.AcmeObject.website } },
        @{MemberName = "ExternalAccountRequired"; Value = { $this.AcmeObject.externalAccountRequired } }
    );

    static AcmeDirectoryMeta() {
        $TypeName = [AcmeDirectoryMeta].Name
        foreach ($definition in [AcmeDirectoryMeta]::_memberDefinitions) {
            Update-TypeData -TypeName $TypeName -MemberType 'ScriptProperty' @definition
        }
    }

    AcmeDirectoryMeta([PSCustomObject] $obj) {
        $this.AcmeObject = $obj;
    }
}
