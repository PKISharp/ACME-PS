class AcmeObjectConverter : System.Management.Automation.PSTypeConverter {
    [bool] CanConvertFrom([object] $object, [Type] $destinationType) {
        if($object -is [string]) {
            return $destinationType -in @([AcmeState],[AcmeIdentifier]);
        }

        return $false;
    }

    [object] ConvertFrom([object] $sourceValue, [Type] $destinationType,
        [IFormatProvider] $formatProvider, [bool] $ignoreCase)
    {
        if($null -eq $sourceValue) { return $null; }

        if(-not $this.CanConvertFrom($sourceValue, $destinationType)) {
            throw [System.InvalidCastException]::new();
        }

        if($destinationType -eq [AcmeState]) {
            $paths = [AcmeStatePaths]::new($sourceValue);
            return [AcmeDiskPersistedState]::new($paths, $false, $true);
        }

        if($destinationType -eq [AcmeIdentifier]) {
            return [AcmeIdentifier]::Parse($sourceValue);
        }
    }


    [bool] CanConvertTo([object] $object, [Type] $destinationType) {
        return $false
    }

    [object] ConvertTo([object] $sourceValue, [Type] $destinationType,
        [IFormatProvider] $formatProvider, [bool] $ignoreCase)
    {
        throw [System.NotImplementedException]::new();
    }
}