function Import-CertificateKey {
    <#
        .SYNOPSIS
            Imports an exported certificate key.
        
        .DESCRIPTION
            Imports an certificate key that has been exported with Export-CertificateKey. If requested, the key is registered for automatic key handling.

        .PARAMETER Path
            The path where the key has been exported to.
    #>
    param(
        # Specifies a path to one or more locations.
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )

    $ErrorActionPreference = 'Stop'

    if($Path -like "*.json") {
        $imported = Get-Content $Path -Raw | ConvertFrom-Json | ConvertFrom-Import;
    } else {
        $imported = Import-Clixml $Path | ConvertFrom-Import
    }

    $certificateKey = [AcmeSharpCore.Crypto.ICertificateKey][AcmeSharpCore.Crypto.AlgorithmFactory]::CreateCertificateKey($imported);
    return $certificateKey;
}