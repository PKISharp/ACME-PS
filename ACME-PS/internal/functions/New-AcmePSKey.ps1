function New-AcmePSKey {
    [CmdletBinding(SupportsShouldProcess=$false)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseShouldProcessForStateChangingFunctions", "", Scope="Function", Target="*")]
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
        $ECDsaHashSize = 256
    )

    if($ECDsa.IsPresent -or $PSCmdlet.ParameterSetName -eq "ECDsa") {
        $ecdsaKey = [Security.Cryptography.ECDsa]::Create([AcmePSKey]::GetECDsaCurve($ECDsaHashSize));
        $acmepsKey = [AcmePSKey]::new($ecdsaKey, $ECDsaHashSize);
        Write-Verbose "Created new ECDsa certificate key with hash size $ECDsaHashSize";
    }
    elseif ($RSA.IsPresent -or $PSCmdlet.ParameterSetName -eq "RSA") {
        if($RSAKeySize -lt 2048 -or $RSAKeySize -gt 4096 -or ($RSAKeySize % 8) -ne 0) {
            throw "The RSAKeySize must be between 2048 and 4096 and must be divisible by 8";
        }

        $rsaKey = [Security.Cryptography.RSA]::Create($RSAKeySize);
        $acmepsKey = [AcmePSKey]::new($rsaKey, $RSAHashSize);
        Write-Verbose "Created new RSA certificate key with hash size $RSAHashSize and key size $RSAKeySize";
    }

    return $acmepsKey;
}