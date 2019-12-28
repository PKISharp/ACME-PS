[System.ComponentModel.TypeConverter([StringToAcmeStateConverter])]
<# abstract #> class AcmeState {
    AcmeState() {
        if ($this.GetType() -eq [AcmeState]) {
            throw [System.InvalidOperationException]::new("This is intended to be abstract - inherit To it.");
        }
    }

    <# abstract #> [string]        GetNonce()                  { throw [System.NotImplementedException]::new(); }
    <# abstract #> [AcmeDirectory] GetServiceDirectory()       { throw [System.NotImplementedException]::new(); }
    <# abstract #> [IAccountKey]   GetAccountKey()             { throw [System.NotImplementedException]::new(); }
    <# abstract #> [AcmeAccount]   GetAccount()                { throw [System.NotImplementedException]::new(); }

    <# abstract #> [void] SetNonce([string] $value)            { throw [System.NotImplementedException]::new(); }
    <# abstract #> [void] Set([AcmeDirectory] $value)          { throw [System.NotImplementedException]::new(); }
    <# abstract #> [void] Set([IAccountKey] $value)            { throw [System.NotImplementedException]::new(); }
    <# abstract #> [void] Set([AcmeAccount] $value)            { throw [System.NotImplementedException]::new(); }

    <# abstract #> [AcmeOrder] FindOrder([string[]] $dnsNames) { throw [System.NotImplementedException]::new(); }

    <# abstract #> [void] AddOrder([AcmeOrder] $order)           { throw [System.NotImplementedException]::new(); }
    <# abstract #> [void] SetOrder([AcmeOrder] $order)           { throw [System.NotImplementedException]::new(); }
    <# abstract #> [void] RemoveOrder([AcmeOrder] $order)      { throw [System.NotImplementedException]::new(); }

    [bool] DirectoryExists() {
        if ($null -eq $this.GetServiceDirectory()) {
            Write-Warning "State does not contain a service directory. Run Get-ACMEServiceDirectory to get one."
            return $false;
        }

        return $true;
    }

    [bool] NonceExists() {
        $exists = $this.DirectoryExists();

        if($null -eq $this.GetNonce()) {
            Write-Warning "State does not contain a nonce. Run New-ACMENonce to get one."
            return $false;
        }

        return $exists;
    }

    [bool] AccountKeyExists() {
        $exists = $this.NonceExists();

        if($null -eq $this.GetAccountKey()) {
            Write-Warning "State does not contain an account key. Run New-ACMEAccountKey to create one."
            return $false;
        }

        return $exists;
    }

    [bool] AccountExists() {
        $exists = $this.AccountKeyExists();

        if($null -eq $this.GetAccount()) {
            Write-Warning "State does not contain an account. Register one by running New-ACMEAccount."
            return $false;
        }

        return $exists;
    }
}

class StringToAcmeStateConverter : System.Management.Automation.PSTypeConverter {
    hidden [bool] CanConvert([object] $object, [System.Type] $destinationType) {
        return $object -is [string] -and $destinationType -eq [AcmeState];
    }

    hidden [AcmeState] Convert([string] $inputString) {
        $paths = [AcmeStatePaths]::new($inputString);
        return [AcmeDiskPersistedState]::new($paths, $false, $true);
    }
    
    [bool] CanConvertFrom([object] $object, [Type] $destinationType) {
        return $this.CanConvert($object, $destinationType);
    }

    [bool] CanConvertFrom([PSObject] $object, [Type] $destinationType) {
        return $this.CanConvert($object, $destinationType);
    }

    [bool] CanConvertTo([object] $object, [Type] $destinationType) {
        return $this.CanConvert($object, $destinationType);
    }

    [bool] CanConvertTo([PSObject] $object, [Type] $destinationType) {
        return $this.CanConvert($object, $destinationType);
    }

    [object] ConvertFrom([PSObject] $sourceValue, [Type] $destinationType,
        [IFormatProvider] $formatProvider, [bool] $ignoreCase)
    {
        if(-not $this.CanConvert($sourceValue, $destinationType)) {
            return $null;
        }

        return Convert([string]$sourceValue)
    }

    [object] ConvertFrom([object] $sourceValue, [Type] $destinationType,
        [IFormatProvider] $formatProvider, [bool] $ignoreCase)
    {
        if(-not $this.CanConvert($sourceValue, $destinationType)) {
            return $null;
        }

        return Convert([string]$sourceValue)
    }

    [object] ConvertTo([object] $sourceValue, [Type] $destinationType,
        [IFormatProvider] $formatProvider, [bool] $ignoreCase)
    {
        if(-not $this.CanConvert($sourceValue, $destinationType)) {
            return $null;
        }

        return Convert([string]$sourceValue)
    }

    [object] ConvertTo([PSObject] $sourceValue, [Type] $destinationType,
        [IFormatProvider] $formatProvider, [bool] $ignoreCase)
    {
        if(-not $this.CanConvert($sourceValue, $destinationType)) {
            return $null;
        }

        return Convert([string]$sourceValue)
    }
}