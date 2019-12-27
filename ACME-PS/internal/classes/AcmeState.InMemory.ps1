class AcmeInMemoryState : AcmeState {
    [ValidateNotNull()] hidden [AcmeDirectory] $ServiceDirectory;
    [ValidateNotNull()] hidden [string] $Nonce;
    [ValidateNotNull()] hidden [IAccountKey] $AccountKey;
    [ValidateNotNull()] hidden [AcmeAccount] $Account;

    hidden [hashtable] $Orders = @{};

    AcmeInMemoryState() {
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


    [AcmeOrder] FindOrder([string[]] $dnsNames) {
        throw [System.NotImplementedException]::new();
    }

    [void] AddOrder([AcmeOrder] $order) {
        $this.Orders.Add($order);
    }

    [void] SetOrder([AcmeOrder] $order) {
         if(-not $this.Orders.Contains($order)) {
            $this.Orders.Add($order);
         }
    }

    [void] RemoveOrder([AcmeOrder] $order) {
        $this.Orders.Remove($order);
    }
}
