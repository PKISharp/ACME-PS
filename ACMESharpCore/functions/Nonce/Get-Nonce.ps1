function Get-Nonce {
    param()

    if($script:AutoNonce) {
        Write-Warning ("If you use this nonce outside of the AcmeSharpCore-Module, "+
            "it might be neccessary to call New-Nonce to reinitialize the automatic nonce handling."+
            "calling any other module function, which contacts the acme-server will also suffice.");
    } else {
        Write-Error ("Using this function is only possible, if Get-ServiceDirectory was called with -EnableModuleNonceHandling, "+
            "if you need to access the nonce, refer to the AcmeHttpResponse-Object in the Result of your functions or call New-Nonce");
    }

    return $Script:Nonce;
}