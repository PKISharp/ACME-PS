class AcmeState {

    AcmeState([string] $savePath, [bool]$autoSave) {
        $this.Filenames = [AcmeStatePaths]::new($savePath);

        if(-not (Test-Path $savePath)) {
            New-Item $savePath -ItemType Directory -Force;
        }

        $this.AutoSave = $autoSave;
        $this.SavePath = Resolve-Path $savePath;
    }




    [void] Set([AcmeDirectory] $serviceDirectory) {
        $this.ServiceDirectory = $serviceDirectory;
        if($this.AutoSave) {
            $directoryPath = $this.Filenames.ServiceDirectory;

            Write-Debug "Storing the service directory to $directoryPath";
            $this.ServiceDirectory | Export-AcmeObject $directoryPath -Force;
        }
    }
    [void] SetNonce([string] $nonce) {
        $this.Nonce = $nonce;
        if($this.AutoSave) {
            $noncePath = $this.Filenames.Nonce;
            Set-Content $noncePath -Value $nonce -NoNewLine;
        }
    }
    [void] Set([IAccountKey] $accountKey) {
        $this.AccountKey = $accountKey;

        if($this.AutoSave) {
            $accountKeyPath = $this.Filenames.AccountKey;
            $this.AccountKey | Export-AccountKey $accountKeyPath -Force;
        } elseif(-not $this.IsInitializing) {
            Write-Warning "The account key will not be exported."
            Write-Information "Make sure you save the account key or you might loose access to your ACME account.";
        }
    }
    [void] Set([AcmeAccount] $account) {
        $this.Account = $account;
        if($this.AutoSave) {
            $accountPath = $this.Filenames.Account;
            $this.Account | Export-AcmeObject $accountPath;
        }
    }

    hidden [void] LoadFromPath()
    {
        $this.IsInitializing = $true;
        $this.AutoSave = $false;

        $directoryPath = $this.Filenames.ServiceDirectory;
        $noncePath = $this.Filenames.Nonce;
        $accountKeyPath = $this.Filenames.AccountKey;
        $accountPath = $this.Filenames.Account;

        if(Test-Path $directoryPath) {
            Get-ServiceDirectory $this -Path $directoryPath
        } else {
            Write-Verbose "Could not find saved service directory at $directoryPath";
        }

        if(Test-Path $noncePath) {
            $importedNonce = Get-Content $noncePath -Raw
            if($importedNonce) {
                $this.SetNonce($importedNonce);
            } else {
                New-Nonce $this;
            }
        } else {
            Write-Verbose "Could not find saved nonce at $noncePath";
        }

        if(Test-Path $accountKeyPath) {
            Import-AccountKey $this -Path $accountKeyPath
        } else {
            Write-Verbose "Could not find saved account key at $accountKeyPath";
        }

        if(Test-Path $accountPath) {
            $importedAccount = Import-AcmeObject -Path $accountPath -TypeName "AcmeAccount"
            $this.Set($importedAccount);
        } else {
            Write-Verbose "Could not find saved account at $accountPath";
        }

        $this.AutoSave = $true;
        $this.IsInitializing = $false
    }

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
    hidden [string] GetOrderFileName([string] $orderHash) {
        $fileName = $this.Filenames.Order.Replace("[hash]", $orderHash);
        return $fileName;
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

    [bool] Validate() {
        return $this.Validate("Account");
    }

    [bool] Validate([string] $field) {
        $isValid = $true;

        if($field -in @("ServiceDirectory", "Nonce", "AccountKey", "Account")) {
            if($null -eq $this.ServiceDirectory) {
                $isValid = $false;
                Write-Warning "State does not contain a service directory. Run Get-ACMEServiceDirectory to get one."
            }
        }

        if($field -in @("Nonce", "AccountKey", "Account")) {
            if($null -eq $this.Nonce) {
                $isValid = $false;
                Write-Warning "State does not contain a nonce. Run New-ACMENonce to get one."
            }
        }

        if($field -in @("AccountKey", "Account")) {
            if($null -eq $this.AccountKey) {
                $isValid = $false;
                Write-Warning "State does not contain an account key. Run New-ACMEAccountKey to create one."
            }
        }

        if($field -in @("Account")) {
            if($null -eq $this.Account) {
                $isValid = $false;
                Write-Warning "State does not contain an account. Register one by running New-ACMEAccount."
            }
        }

        return $isValid;
    }

    static [AcmeState] FromPath([string] $Path) {
        $state = [AcmeState]::new($Path, $false);
        $state.LoadFromPath();

        return $state;
    }
}

<# abstract #> class AcmeStateBase {
    AcmeStateBase() {
        if ($this.GetType() -eq [AcmeStateBase]) {
            throw [System.InvalidOperationException]::new("This is intended to be abstract - inherit from it.");
        }
    }

    static [AcmeStateBase] FromPath([string] $path) {
        return [AcmeStateBase]::FromPaths([AcmeStatePaths]::new($path));
    }

    static [AcmeStateBase] FromPaths([AcmeStatePaths] $paths) {
        return [AcmeDiskPersistedState]::new($paths);
    }

    <# abstract #> [string]        GetNonce()            { throw [System.NotImplementedException]::new(); }
    <# abstract #> [AcmeDirectory] GetServiceDirectory() { throw [System.NotImplementedException]::new(); }
    <# abstract #> [IAccountKey]   GetAccountKey()       { throw [System.NotImplementedException]::new(); }
    <# abstract #> [AcmeAccount]   GetAccount()          { throw [System.NotImplementedException]::new(); }

    <# abstract #> [void] SetNonce([string] $value)   { throw [System.NotImplementedException]::new(); }
    <# abstract #> [void] Set([AcmeDirectory] $value) { throw [System.NotImplementedException]::new(); }
    <# abstract #> [void] Set([IAccountKey] $value)   { throw [System.NotImplementedException]::new(); }
    <# abstract #> [void] Set([AcmeAccount] $value)   { throw [System.NotImplementedException]::new(); }

    <# abstract #> [AcmeOrder] GetOrder([object] $params)      { throw [System.NotImplementedException]::new(); }
    <# abstract #> [AcmeOrder] FindOrder([string[]] $dnsNames) { throw [System.NotImplementedException]::new(); }
    <# abstract #> [void] AddOrder([object] $params)           { throw [System.NotImplementedException]::new(); }
    <# abstract #> [void] SetOrder([object] $params)           { throw [System.NotImplementedException]::new(); }
}

class AcmeStatePaths {
    [string] $BasePath;
    
    [string] $ServiceDirectory;
    [string] $Nonce;
    [string] $AccountKey;
    [string] $Account;

    [string] $OrderList;
    [string] $Order;

    AcmeStatePaths([string] $basePath) {
        $this.BasePath = Resolve-Path $basePath

        $this.ServiceDirectory = "$($this.BasePath)/ServiceDirectory.xml";
        $this.Nonce = "$($this.BasePath)/NextNonce.txt";
        $this.AccountKey = "$($this.BasePath)AccountKey.xml";
        $this.Account = "$($this.BasePath)Account.xml";

        $this.OrderList = "$($this.BasePath)Orders/OrderList.txt"
        $this.Order = "$($this.BasePath)Orders/Order-[hash].xml";
    }
}

class AcmeDiskPersistedState {
    hidden [AcmeStatePaths] $Filenames;

    AcmeDiskPersistedState(AcmeStatePaths $paths) {
        $Filenames = $paths;

        #TODO: do a test, if we can write there.
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
