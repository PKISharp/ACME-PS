class AcmeCsrOptions {
    AcmeCsrOptions() { }

    AcmeCsrOptions([PsCustomObject] $obj) {
        $this.DistinguishedName = $obj.DistinguishedName
    }

    [string]$DistinguishedName;
}
