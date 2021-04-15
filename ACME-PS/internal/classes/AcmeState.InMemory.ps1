class AcmeInMemoryState : AcmeState {
    [ValidateNotNull()] hidden [AcmeDirectory] $ServiceDirectory;
    [ValidateNotNull()] hidden [string] $Nonce;
    [ValidateNotNull()] hidden [AcmePSKey] $AccountKey;
    [ValidateNotNull()] hidden [AcmeAccount] $Account;

    hidden [hashtable] $Orders = @{};
    hidden [hashtable] $CertKeys = @{}

    AcmeInMemoryState() {
    }

    [AcmeDirectory] GetServiceDirectory() { return $this.ServiceDirectory; }
    [string] GetNonce() { return $this.Nonce; }
    [AcmePSKey] GetAccountKey() { return $this.AccountKey; }
    [AcmeAccount] GetAccount() { return $this.Account; }

    [void] SetNonce([string] $value)   { $this.Nonce = $value; }
    [void] Set([AcmeDirectory] $value) { $this.ServiceDirectory = $value; }
    [void] Set([AcmePSKey] $value)   { $this.AccountKey = $value; }
    [void] Set([AcmeAccount] $value)   { $this.Account = $value; }


    [void] AddOrder([AcmeOrder] $order) {
        $this.SetOrder($order);
    }

    [void] SetOrder([AcmeOrder] $order) {
        $orderHash = $order.GetHashString();
        $this.Orders[$orderHash] = $order;
    }

    [void] RemoveOrder([AcmeOrder] $order) {
        $orderHash = $order.GetHashString();
        $this.Orders.Remove($orderHash);
    }

    [AcmePSKey] GetOrderCertificateKey([AcmeOrder] $order) {
        $orderHash = $order.GetHashString();
        if ($this.CertKeys.ContainsKey($orderHash)) {
            return $this.CertKeys[$orderHash];
        }

        return $null;
    }

    [void] SetOrderCertificateKey([AcmeOrder] $order, [AcmePSKey] $certificateKey) {
        $orderHash = $order.GetHashString();
        $this.CertKeys[$orderHash] = $certificateKey;
    }
}
