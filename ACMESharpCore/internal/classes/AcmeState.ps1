class AcmeState {
    [ValidateNotNull()]
    [AcmeDirectory] $ServiceDirectory;
    
    [ValidateNotNull()]    
    [IAccountKey] $AccountKey;
    
    [ValidateNotNull()]    
    [AcmeAccount] $Account;
    
    [ValidateNotNull()]    
    [AcmeNonce] $Nonce;
}