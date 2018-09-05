class AcmeState {
    [ValidateNotNull()] hidden [AcmeDirectory] $ServiceDirectory;
    [ValidateNotNull()] hidden [string] $Nonce;
    [ValidateNotNull()] hidden [IAccountKey] $AccountKey;
    [ValidateNotNull()] hidden [AcmeAccount] $Account;

    hidden [string] $SavePath;
    hidden [bool] $AutoSave;
    hidden [bool] $IsInitializing;

    hidden [AcmeStatePaths] $Filenames;

    AcmeState() {
        $this.Filenames = [AcmeStatePaths]::new("");
    }

    AcmeState([string] $savePath, [bool]$autoSave) {
        $this.Filenames = [AcmeStatePaths]::new($savePath);

        if(-not (Test-Path $savePath)) {
            New-Item $savePath -ItemType Directory -Force;
        }

        $this.AutoSave = $autoSave;
        $this.SavePath = Resolve-Path $savePath;
    }


    [AcmeDirectory] GetServiceDirectory() { return $this.ServiceDirectory; }
    [string] GetNonce() { return $this.Nonce; }
    [IAccountKey] GetAccountKey() { return $this.AccountKey; }
    [AcmeAccount] GetAccount() { return $this.Account; }


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
            Write-Warning "If AutoSaving is off, this method does nothing."
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
            Write-Warning "If AutoSaving is off, this method does nothing."
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
        return $null -ne $this.ServiceDirectory -and
            $null -ne $this.Nonce -and
            $null -ne $this.AccountKey -and
            $null -ne $this.Account;
    }

    [bool] Validate([string] $field) {
        if($field -eq "ServiceDirectory") {
            return $null -ne $this.ServiceDirectory;
        }

        if($field -eq "Nonce") {
            return $null -ne $this.ServiceDirectory -and
                $null -ne $this.Nonce;
        }

        if($field -eq "AccountKey") {
            return $null -ne $this.ServiceDirectory -and
                $null -ne $this.Nonce -and
                $null -ne $this.AccountKey;
        }

        if($field -eq "Account") {
            return $this.Validate();
        }

        return false;
    }

    static [AcmeState] FromPath([string] $Path) {
        $state = [AcmeState]::new($Path, $false);
        $state.LoadFromPath();

        return $state;
    }
}

class AcmeStatePaths {
    [string] $ServiceDirectory;
    [string] $Nonce;
    [string] $AccountKey;
    [string] $Account;

    [string] $OrderList;
    [string] $Order;

    AcmeStatePaths([string] $basePath) {
        $this.ServiceDirectory = "$basePath/ServiceDirectory.xml";
        $this.Nonce = "$basePath/NextNonce.txt";
        $this.AccountKey = "$basePath/AccountKey.xml";
        $this.Account = "$basePath/Account.xml";

        $this.OrderList = "$basePath/Orders/OrderList.txt"
        $this.Order = "$basePath/Orders/Order-[hash].xml";
    }
}