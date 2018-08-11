class AcmeDirectory {
    AcmeDirectory([PSCustomObject] $obj) {
        $this.NewAccount = $obj.NewAccount;
        $this.NewAuthz = $obj.NewAuthz;
        $this.NewNonce = $obj.NewNonce;
        $this.NewOrder = $obj.NewOrder;
        $this.KeyChange = $obj.KeyChange;
        $this.RevokeCert = $obj.RevokeCert;

        $this.Meta = [AcmeDirectoryMeta]::new($obj.Meta);
    }

    [string] $NewAccount;
    [string] $NewAuthz;
    [string] $NewNonce;
    [string] $NewOrder;
    [string] $KeyChange;
    [string] $RevokeCert;

    [AcmeDirectoryMeta] $Meta;
}

class AcmeDirectoryMeta {
    AcmeDirectoryMeta([PSCustomObject] $obj) {
        $this.CaaIdentites = $obj.CaaIdentities;
        $this.TermsOfService = $obj.TermsOfService;
        $this.Website = $obj.Website;
    }

    [string[]] $CaaIdentites;
    [string] $TermsOfService;
    [string] $Website;
}