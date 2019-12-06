class AcmeStateX {

    hidden [string] GetOrderHash([AcmeOrder] $order) {
        $orderIdentifiers = $order.Identifiers | Foreach-Object { $_.ToString() } | Sort-Object;
        $identifier = [string]::Join('|', $orderIdentifiers);

        $sha256 = [System.Security.Cryptography.SHA256]::Create();
        try {
            $identifierBytes = [System.Text.Encoding]::UTF8.GetBytes($identifier);
            $identifierHash = $sha256.ComputeHash($identifierBytes);
            $result = ConvertTo-UrlBase64 -InputBytes $identifierHash;

            return $result;
        } finally {
            $sha256.Dispose();
        }
    }
    

    hidden [AcmeOrder] LoadOrder([string] $orderHash) {
        $orderFile = $this.GetOrderFileName($orderHash);
        if(Test-Path $orderFile) {
            $order = Import-AcmeObject -Path $orderFile -TypeName "AcmeOrder";
            return $order;
        }

        return $null;
    }

    [void] AddOrder([AcmeOrder] $order) {
        $this.SetOrder($order);
    }

    [void] SetOrder([AcmeOrder] $order) {
        if($this.AutoSave) {
            $orderHash = $this.GetOrderHash($order);
            $orderFileName = $this.GetOrderFileName($orderHash);

            if(-not (Test-Path $order)) {
                $orderListFile = $this.Filenames.OrderList;

                foreach ($id in $order.Identifiers) {
                    if(-not (Test-Path $orderListFile)) {
                        New-Item $orderListFile -Force;
                    }

                    "$($id.ToString())=$orderHash" | Add-Content $orderListFile;
                }
            }

            $order | Export-AcmeObject $orderFileName -Force;
        } else {
            Write-Warning "auto saving the state has been disabled, so set order is a no-op."
        }
    }

    [void] RemoveOrder([AcmeOrder] $order) {
        if($this.AutoSave) {
            $orderHash = $this.GetOrderHash($order);
            $orderFileName = $this.GetOrderFileName($orderHash);

            if(Test-Path $orderFileName) {
                Remove-Item $orderFileName;
            }

            $orderListFile = $this.Filenames.OrderList;
            Set-Content -Path $orderListFile -Value (Get-Content -Path $orderListFile | Select-String -Pattern "=$orderHash" -NotMatch -SimpleMatch)
        } else {
            Write-Warning "auto saving the state has been disabled, so set order is a no-op."
        }
    }

    [AcmeOrder] FindOrder([string[]] $dnsNames) {
        $orderListFile = $this.Filenames.OrderList;

        $first = $true;
        $lastMatch = $null;
        foreach($dnsName in $dnsNames) {
            $match = Select-String -Path $orderListFile -Pattern "$dnsName=" -SimpleMatch | Select-Object -Last 1
            if($first) { $lastMatch = $match; }
            if($match -ne $lastMatch) { return $null; }

            $lastMatch = $match;
        }

        $orderHash = ($lastMatch -split "=", 2)[1];
        return $this.LoadOrder($orderHash);
    }


}

<# abstract #> class AcmeState {
    static [AcmeState] FromPath([string] $path) {
        return [AcmeState]::FromPaths([AcmeStatePaths]::new($path));
    }

    static [AcmeState] FromPaths([AcmeStatePaths] $paths) {
        return [AcmeDiskPersistedState]::new($paths, $false, $true);
    }

    
    AcmeStateBase() {
        if ($this.GetType() -eq [AcmeState]) {
            throw [System.InvalidOperationException]::new("This is intended to be abstract - inherit from it.");
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

    <# abstract #> [AcmeOrder] GetOrder([object] $params)      { throw [System.NotImplementedException]::new(); }
    <# abstract #> [AcmeOrder] FindOrder([string[]] $dnsNames) { throw [System.NotImplementedException]::new(); }
    <# abstract #> [void] AddOrder([object] $params)           { throw [System.NotImplementedException]::new(); }
    <# abstract #> [void] SetOrder([object] $params)           { throw [System.NotImplementedException]::new(); }


    [bool] DirectoryExists() {
        if ($null -eq $this.GetServiceDirectory()) {
            Write-Warning "State does not contain a service directory. Run Get-ACMEServiceDirectory to get one."
            return $false;
        }

        return $true;
    }

    [bool] NonceExists() {
        $exists = $this.DirectoryExists();

        if($null -eq $this.Nonce) {
            Write-Warning "State does not contain a nonce. Run New-ACMENonce to get one."
            return $false;
        }

        return $exists;
    }

    [bool] AccountKeyExists() {
        $exists = $this.NonceExists();

        if($null -eq $this.AccountKey) {
            Write-Warning "State does not contain an account key. Run New-ACMEAccountKey to create one."
            return $false;
        }

        return $exists;
    }

    [bool] AccountExists() {
        $exists = $this.AccountKeyExists();

        if($null -eq $this.Account) {
            Write-Warning "State does not contain an account. Register one by running New-ACMEAccount."
            return $false;
        }

        return $exists;
    }
}

class AcmeStatePaths {
    [string] $BasePath;
    
    [string] $ServiceDirectory;
    [string] $Nonce;
    [string] $AccountKey;
    [string] $Account;

    [string] $OrderList;
    hidden [string] $Order;

    AcmeStatePaths([string] $basePath) {
        $this.BasePath = Resolve-Path $basePath

        $this.ServiceDirectory = "$($this.BasePath)/ServiceDirectory.xml";
        $this.Nonce = "$($this.BasePath)/NextNonce.txt";
        $this.AccountKey = "$($this.BasePath)AccountKey.xml";
        $this.Account = "$($this.BasePath)Account.xml";

        $this.OrderList = "$($this.BasePath)Orders/OrderList.txt"
        $this.Order = "$($this.BasePath)Orders/Order-[hash].xml";
    }

    [string] GetOrderFileName([string] $orderHash) {
        return $this.Order.Replace("[hash]", $orderHash);
    }
}

class AcmeDiskPersistedState {
    hidden [AcmeStatePaths] $Filenames;

    AcmeDiskPersistedState([AcmeStatePaths] $paths, [bool] $createState, [bool] $allowLateInit) {
        $this.Filenames = $paths;

        if(-not (Test-Path $this.Filenames.BasePath)) {
            if ($createState) {
                New-Item $this.Filenames.BasePath -ItemType Directory -Force -ErrorAction 'Stop';    
            } else {
                throw "$($this.Filenames.BasePath) does not exist.";
            }
        }

        $flagFile = "$($this.Filenames.BasePath)/.acme-ps-state";
        if(-not (Test-Path $flagFile)) {
            if($allowLateInit -or $createState) {
                New-Item $flagFile -ItemType File
            } else {
                throw "Could not find $flagFile identifying the state directory. You can create an empty file, to fix this.";
            }
        } else {
            # Test, if the path seems writable.
            Set-Content -Path $flagFile -Value (Get-Date) -ErrorAction 'Stop';
        }
    }

    
    <# Getters #>
    [string] GetNonce() {
        $fileName = $this.Filenames.Nonce;
    
        if(Test-Path $fileName) {
            $result = Get-Content $fileName -Raw
            return $result;
        }

        Write-Verbose "Could not find saved nonce at $fileName";
        return $null;
    }

    [AcmeDirectory] GetServiceDirectory() {
        $fileName = $this.Filenames.ServiceDirectory;
        
        if(Test-Path $fileName) {
            if($fileName -like "*.json") {
                $result = [ACMEDirectory](Get-Content $Path | ConvertFrom-Json)
            } else {
                $result = [AcmeDirectory](Import-Clixml $Path)
            }

            return $result;
        }

        Write-Verbose "Could not find saved service directory at $fileName";
        return $null;
    }

    [IAccountKey] GetAccountKey() {
        $fileName = $this.Filenames.AccountKey;

        if(Test-Path $fileName) {
            $result = Import-AccountKEy -Path $fileName;
            return $result;
        }

        Write-Verbose "Could not find saved account key at $fileName."
        return $null;
    }

    [AcmeAccount] GetAccount() {
        $fileName = $this.Filenames.AccountKey;

        if(Test-Path $fileName) {
            $result = Import-AcmeObject -Path $fileName -TypeName "AcmeAccount";
            return $result;
        }

        Write-Verbose "Could not find saved account key at $fileName."
        return $null;
    }


    <# Setters #>
    [void] SetNonce([string] $value) {
        $fileName = $this.Filenames.Nonce;

        Write-Debug "Storing the nonce to $fileName"
        Set-Content $fileName -Value $value -NoNewLine;
    }

    [void] Set([AcmeDirectory] $value) {
        $fileName = $this.Filenames.ServiceDirectory;

        Write-Debug "Storing the service directory to $fileName";
        $value | Export-AcmeObject $fileName -Force;
    }
    
    [void] Set([IAccountKey] $value) {
        $fileName = $this.Filenames.AccountKey;

        Write-Debug "Storing the account key to $fileName";
        $value | Export-AccountKey $accountKeyPath -Force;
    }
    
    [void] Set([AcmeAccount] $value) {
        $fileName = $this.Filenames.Account;

        Write-Debug "Storing the account data to $fileName";
        $value | Export-AcmeObject $accountPath;
    }

    <# Orders #>
    [AcmeOrder] GetOrder([object] $params) {
        throw [System.NotImplementedException]::new();
    }
    
    [AcmeOrder] FindOrder([string[]] $dnsNames) {
        throw [System.NotImplementedException]::new();
    }

    [void] AddOrder([object] $params) {
        throw [System.NotImplementedException]::new();
    }

    [void] SetOrder([object] $params) {
        throw [System.NotImplementedException]::new();
    }
}

class AcmeEphemeralState {
    [ValidateNotNull()] hidden [AcmeDirectory] $ServiceDirectory;
    [ValidateNotNull()] hidden [string] $Nonce;
    [ValidateNotNull()] hidden [IAccountKey] $AccountKey;
    [ValidateNotNull()] hidden [AcmeAccount] $Account;

    hidden [hashtable] $Orders = @{};

    AcmeEphemeralState() {
        Write-Warning "Using an ephemeral state-object might lead to data loss."
    }

    [AcmeDirectory] GetServiceDirectory() { return $this.ServiceDirectory; }
    [string] GetNonce() { return $this.Nonce; }
    [IAccountKey] GetAccountKey() { return $this.AccountKey; }
    [AcmeAccount] GetAccount() { return $this.Account; }

    [void] SetNonce([string] $value)   { $this.Nonce = $value; }
    [void] Set([AcmeDirectory] $value) { $this.ServiceDirectory = $value; }
    [void] Set([IAccountKey] $value)   { $this.AccountKey = $value; }
    [void] Set([AcmeAccount] $value)   { $this.Account = $value; }

    [AcmeOrder] GetOrder([object] $params) { throw [System.NotImplementedException]::new(); }
    [AcmeOrder] FindOrder([string[]] $dnsNames) { throw [System.NotImplementedException]::new(); }
    [void] AddOrder([object] $params) { throw [System.NotImplementedException]::new(); }
    [void] SetOrder([object] $params) { throw [System.NotImplementedException]::new(); }
}
