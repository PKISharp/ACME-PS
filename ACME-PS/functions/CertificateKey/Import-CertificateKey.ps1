function Import-CertificateKey {
    <#
        .SYNOPSIS
            Imports an exported certificate key.

        .DESCRIPTION
            Imports an certificate key that has been exported with Export-CertificateKey. If requested, the key is registered for automatic key handling.


        .PARAMETER Path
            The path where the key has been exported to.


        .EXAMPLE
            PS> Import-CertificateKey -Path C:\AcmeCertKeys\example.key.xml;
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
        $imported = Get-Content $Path -Raw | ConvertFrom-Json;
    } else {
        $imported = Import-Clixml $Path;
    }

    $certificateKey = [AcmePSKey]::new($imported);
    return $certificateKey;
}
