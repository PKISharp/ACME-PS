function Get-Nonce {
    param()

    Write-Warning "If you use this nonce outside of the AcmeSharpCore-Module, "+
        "it might be neccessary to call New-Nonce to reinitialize the automatic nonce handling."+
        "calling any other module function, which contacts the acme-server will also suffice."

    return $Script:Nonce;
}