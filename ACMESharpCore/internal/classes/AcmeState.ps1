class AcmeState {
    [ValidateNotNull()] hidden [AcmeDirectory] $ServiceDirectory;
    [ValidateNotNull()] hidden [AcmeNonce] $Nonce;
    [ValidateNotNull()] hidden [IAccountKey] $AccountKey;
    [ValidateNotNull()] hidden [AcmeAccount] $Account;

    hidden [string] $SavePath;
    hidden [bool] $AutoSave;

    static hidden [hashtable] $Filenames = @{
        "ServiceDirectory"="ServiceDirectory.xml";
        "AcmeNonce"="NextNonce.txt";
        "AccountKey"="AccountKey.xml";
        "Account"="Account.xml";

        "Order"="Orders/Order-[i].xml";
    };

    AcmeState() { }

    AcmeState([string] $savePath, [bool]$autoSave) {
        $this.SavePath = Resolve-Path $savePath;
        $this.AutoSave = $autoSave;

        if(-not (Test-Path $this.SavePath)) {
            New-Item $this.SavePath -ItemType Directory;
        }

        # TODO: Initialize pre saved entries
    }


    [AcmeDirectory] GetServiceDirectory() { return $this.ServiceDirectory; }
    [AcmeNonce] GetNonce() { return $this.Nonce; }
    [IAccountKey] GetAccountKey() { return $this.AccountKey; }
    [AcmeAccount] GetAccount() { return $this.Account; }


    [void] Set([AcmeDirectory] $serviceDirectory) {
        $this.ServiceDirectory = $serviceDirectory;
        if($this.AutoSave) { 
            $directoryPath = "$($this.SavePath)/$([AcmeState]::Filenames["ServiceDirectory"])";
        
            [AcmeState]::Save($this.SavePath, $this.ServiceDirectory); 
        }
    }
    [void] Set([AcmeNonce] $nonce) {
        $this.Nonce = $nonce;
        if($this.AutoSave) {
            $noncePath = "$($this.SavePath)/$([AcmeState]::Filenames["Nonce"])";
            
            [AcmeState]::Save($this.SavePath, $this.Nonce); 
        }
    }
    [void] Set([IAccountKey] $accountKey) {
        $this.AccountKey = $accountKey;
        if($this.AutoSave) { 
            $accountKeyPath = "$($this.SavePath)/$([AcmeState]::Filenames["AccountKey"])"; 
        
            [AcmeState]::Save($this.SavePath, $this.AccountKey);
        } else {
            Write-Warning "The account key will not be exported."+
                "Make sure you save the account key or you might loose access to your ACME account.";
        }
    }
    [void] Set([AcmeAccount] $account) {
        $this.Account = $account;
        if($this.AutoSave) {
            $accountPath = "$($this.SavePath)/$([AcmeState]::Filenames["Account"])"; 
        
            [AcmeState]::Save($this.SavePath, $this.Account);
        }
    }

    [void] AddOrder([AcmeOrder] $order) {
        
    }
    [void] RemoveOrder([AcmeOrder] $order) {

    }

    [string] FindOrderUrl([string[]] $dnsNames) {
        return "";
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

        $directoryPath = "$Path/$([AcmeState]::Filenames["ServiceDirectory"])";
        $noncePath = "$Path/$([AcmeState]::Filenames["Nonce"])";
        $accountKeyPath = "$Path/$([AcmeState]::Filenames["AccountKey"])"; 
        $accountPath = "$Path/$([AcmeState]::Filenames["Account"])"; 
        
        if(Test-Path $directoryPath) {
            Get-ServiceDirectory $state -Path $directoryPath
        }
        if(Test-Path $noncePath) {
            $nonce = Get-Content $Path -Raw
            $state.Set([AcmeNonce]::new($nonce));
        }
        if(Test-Path $accountKeyPath) {
            Import-AccountKey $state -Path $accountKeyPath
        }
        if(Test-Path $accountPath) {
            $account = Import-AcmeObject -Path $accountPath -TypeName "AcmeAccount"
            $state.Set($account);
        }
        
        $state.AutoSave = $true;

        return $state
    }
}