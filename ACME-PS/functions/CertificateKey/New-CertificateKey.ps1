function New-CertificateKey {
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
            PS> New-CertificateKey -Path C:\myKeyExport.xml -AutomaticCertificateKeyHandling

        .EXAMPLE
            PS> New-CertificateKey -Path C:\myKeyExport.json -RSA -HashSize 512

        .EXAMPLE
            PS> New-CertificateKey -ECDsa -HashSize 384 -SkipKeyExport
    #>
    [CmdletBinding(DefaultParameterSetName="RSA", SupportsShouldProcess=$true)]
    [OutputType("AcmePSKey")]
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

    if ($ECDsa.IsPresent -or $PSCmdlet.ParameterSetName -eq "ECDsa") {
        $certificateKey = New-AcmePSKey -ECDsa -ECDsaHashSize $ECDsaHashSize;
    }
    elseif ($RSA.IsPresent -or $PSCmdlet.ParameterSetName -eq "RSA") {
        $certificateKey = New-AcmePSKey -RSA -RSAHashSize $RSAHashSize -RSAKeySize $RSAKeySize;
    }

    if($SkipKeyExport) {
        Write-Warning "The certificate key will not be exported. Make sure you save the certificate key!.";
        return $certificateKey;
    }

    if($PSCmdlet.ShouldProcess("CertificateKey", "Store created key to $Path and reload it from there")) {
        Export-CertificateKey -CertificateKey $certificateKey -Path $Path -ErrorAction 'Stop' | Out-Null
        return Import-CertificateKey -Path $Path -ErrorAction 'Stop'
    }
}
