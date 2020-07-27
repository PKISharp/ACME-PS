function New-ACMECertificateKey {
    <#
        .SYNOPSIS
            Creates a new certificate key, that can will used to sign ACME operations.
            Provide a path where to save the key, since being able to restore it is crucial.

        .DESCRIPTION
            Creates and stores a new certificate key, that can be used for ACME operations.
            The key will first be created, than exported and imported again to make sure, it has been saved.
            You can skip the export by providing the SkipExport switch.


        .PARAMETER RSA
            Used to select RSA key type. (default)

        .PARAMETER RSAHashSize
            The hash size used for the RSA algorithm.

        .PARAMETER RSAKeySize
            The key size of the RSA algorithm.


        .PARAMETER ECDsa
            Used to select ECDsa key type.

        .PARAMETER ECDsaHashSize
            The hash size used for the ECDsa algorithm.


        .PARAMETER Path
            The path where the keys will be stored.

        .PARAMETER SkipKeyExport
            Allows you to suppress the export of the certificate key.


        .EXAMPLE
            PS> New-ACMECertificateKey -Path C:\myKeyExport.xml -AutomaticCertificateKeyHandling

        .EXAMPLE
            PS> New-ACMECertificateKey -Path C:\myKeyExport.json -RSA -HashSize 512

        .EXAMPLE
            PS> New-ACMECertificateKey -ECDsa -HashSize 384 -SkipKeyExport
    #>
    [CmdletBinding(DefaultParameterSetName="RSA", SupportsShouldProcess=$true)]
    [OutputType("ICertificateKey")]
    param(
        [Parameter(ParameterSetName="RSA")]
        [switch]
        $RSA,

        [Parameter(ParameterSetName="RSA")]
        [ValidateSet(256, 384, 512)]
        [int]
        $RSAHashSize = 256,

        [Parameter(ParameterSetName="RSA")]
        [int]
        $RSAKeySize = 2048,


        [Parameter(ParameterSetName="ECDsa")]
        [switch]
        $ECDsa,

        [Parameter(ParameterSetName="ECDsa")]
        [ValidateSet(256, 384, 512)]
        [int]
        $ECDsaHashSize = 256,


        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $SkipKeyExport
    )

    if(-not $SkipKeyExport) {
        if(-not $Path) {
            throw "Path was null or empty. Provide a path for the key to be exported or specify SkipKeyExport";
        }
    }

    if($ECDsa.IsPresent -or $PSCmdlet.ParameterSetName -eq "ECDsa") {
        $certificateKey = [ICertificateKey]([ECDsaCertificateKey]::new($ECDsaHashSize));
        Write-Verbose "Created new ECDsa certificate key with hash size $ECDsaHashSize";
    } elseif ($RSA.IsPresent -or $PSCmdlet.ParameterSetName -eq "RSA") {
        if($RSAKeySize -lt 2048 -or $RSAKeySize -gt 4096 -or ($RSAKeySize%8) -ne 0) {
            throw "The RSAKeySize must be between 2048 and 4096 and must be divisible by 8";
        }

        $certificateKey = [ICertificateKey]([RSACertificateKey]::new($RSAHashSize, $RSAKeySize));
        Write-Verbose "Created new RSA certificate key with hash size $RSAHashSize and key size $RSAKeySize";
    }

    if($SkipKeyExport) {
        Write-Warning "The certificate key will not be exported. Make sure you save the certificate key!.";
        return $certificateKey;
    }

    if($PSCmdlet.ShouldProcess("CertificateKey", "Store created key to $Path and reload it from there")) {
        Export-ACMECertificateKey -CertificateKey $certificateKey -Path $Path -ErrorAction 'Stop' | Out-Null
        return Import-ACMECertificateKey -Path $Path -ErrorAction 'Stop'
    }
}
