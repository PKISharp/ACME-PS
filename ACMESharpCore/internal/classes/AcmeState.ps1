class AcmeState {
    [ValidateNotNull()] hidden [AcmeDirectory] $ServiceDirectory;
    [ValidateNotNull()] hidden [AcmeNonce] $Nonce;
    [ValidateNotNull()] hidden [IAccountKey] $AccountKey;
    [ValidateNotNull()] hidden [AcmeAccount] $Account;

    hidden [string] $SavePath;
    hidden [bool] $AutoSave;

    hidden [hashtable] $Filenames = @{
        "ServiceDirectory"="ServiceDirectory.xml";
        "AcmeNonce"="NextNonce.txt";
        "AccountKey"="AccountKey.xml";
        "Account"="Account.xml";

        "OrderList"="Orders/OrderList.txt"
        "Order"="Orders/Order-[hash].xml";
    };

    AcmeState() { }

    AcmeState([string] $savePath, [bool]$autoSave) {
        if(-not (Test-Path $savePath)) {
            New-Item $savePath -ItemType Directory -Force;
        }

        $this.AutoSave = $autoSave;
        $this.SavePath = Resolve-Path $savePath;
    }


    [AcmeDirectory] GetServiceDirectory() { return $this.ServiceDirectory; }
    [AcmeNonce] GetNonce() { return $this.Nonce; }
    [IAccountKey] GetAccountKey() { return $this.AccountKey; }
    [AcmeAccount] GetAccount() { return $this.Account; }


    [void] Set([AcmeDirectory] $serviceDirectory) {
        $this.ServiceDirectory = $serviceDirectory;
        if($this.AutoSave) { 
            $directoryPath = "$($this.SavePath)/$($this.Filenames["ServiceDirectory"])";
            $this.ServiceDirectory | Export-AcmeObject $directoryPath;
        }
    }
    [void] Set([AcmeNonce] $nonce) {
        $this.Nonce = $nonce;
        if($this.AutoSave) {
            $noncePath = "$($this.SavePath)/$($this.Filenames["Nonce"])";
            Set-Content $noncePath -Value $this.Nonce -NoNewLine;
        }
    }
    [void] Set([IAccountKey] $accountKey) {
        $this.AccountKey = $accountKey;
        
        if($this.AutoSave) { 
            $accountKeyPath = "$($this.SavePath)/$($this.Filenames["AccountKey"])";         
            $this.AccountKey | Export-AccountKey $accountKeyPath -Force;
        } else {
            # this warning should not show up during reinitialization ..
            Write-Warning "The account key will not be exported."+
                "Make sure you save the account key or you might loose access to your ACME account.";
        }
    }
    [void] Set([AcmeAccount] $account) {
        $this.Account = $account;
        if($this.AutoSave) {
            $accountPath = "$($this.SavePath)/$($this.Filenames["Account"])"; 
            $this.Account | Export-AcmeObject $this.SavePath;
        }
    }

    hidden [string] GetOrderHash([AcmeOrder] $order) {
        $orderIdentifiers = $order.Identifiers | Foreach-Object { $_.ToString() } | Sort-Object;
        $identifier = [string].Join('|', $order.Identifiers);

        $sha256 = [System.Security.Cryptography.SHA256]::Create();
        try {
            $identifierBytes = $sha256.CalculateHash($identifier);
            $result = ConvertTo-UrlBase64 -InputBytes $identifierBytes;

            return $result;
        } finally {
            $sha256.Dispose();
        }
    }
    hidden [string] GetOrderFileName([string] $orderHash) {
        $fileName = ($this.Filenames["Order"]).Replace("[hash]", $orderHash);
        return "$($this.SavePath)/$filename";
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
                $orderListFile = "$($this.SavePath)/$($this.Filenames["OrderList"])";
                
                foreach ($id in $order.Identifiers) {
                    if(-not (Test-Path $orderFileName)) {
                        New-Item $orderFileName -Force;
                    }

                    "$($id.ToString())=$orderHash" | Set-Content $orderFileName -Append;
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

            $orderListFile = "$($this.SavePath)/$($this.Filenames["OrderList"])";
            Set-Content -Path $orderListFile -Value (Get-Content -Path $orderListFile | Select-String -Pattern "=$orderHash" -NotMatch -SimpleMatch)
        } else {
            Write-Warning "If AutoSaving is off, this method does nothing."
        }
    }

    [AcmeOrder] FindOrder([string[]] $dnsNames) {
        $orderListFile = "$($this.SavePath)/$($this.Filenames["OrderList"])";

        $first = $true;
        $lastMatch = $null;
        foreach($dnsName in $dnsNames) {
            $match = Select-String -Path $orderListFile -Pattern "$dnsName=" -SimpleMatch | Select-Object -Last 1
            if($first) { $lastMatch = $match; }
            if($match -ne $lastMatch) { return $null; }

            $lastMatch = $match;
        }

        $orderHash = ($lastMatch -split "=", 2)[1];
        return LoadOrder($orderHash);
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

        $directoryPath = "$Path/$($state.Filenames["ServiceDirectory"])";
        $noncePath = "$Path/$($state.Filenames["Nonce"])";
        $accountKeyPath = "$Path/$($state.Filenames["AccountKey"])"; 
        $accountPath = "$Path/$($state.Filenames["Account"])"; 
        
        if(Test-Path $directoryPath) {
            Get-ServiceDirectory $state -Path $directoryPath
        }
        if(Test-Path $noncePath) {
            $importedNonce = Get-Content $Path -Raw
            if($importedNonce) {
                $state.Set([AcmeNonce]::new($importedNonce));
            } else {
                New-Nonce $state;
            }
        }
        if(Test-Path $accountKeyPath) {
            Import-AccountKey $state -Path $accountKeyPath
        }
        if(Test-Path $accountPath) {
            $importedAccount = Import-AcmeObject -Path $accountPath -TypeName "AcmeAccount"
            $state.Set($importedAccount);
        }
        
        $state.AutoSave = $true;

        return $state
    }
}