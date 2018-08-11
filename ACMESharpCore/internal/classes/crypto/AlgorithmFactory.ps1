class Creator {
    [Type] $TargetType;
    [Type] $KeyType;
    [Func[[KeyExport], [KeyBase]]] $Create;

    Creator([Type] $targetType, [Type] $keyType, [Func[[KeyExport], [KeyBase]]] $creatorFunction)
    {
        $this.TargetType = $targetType;
        $this.KeyType = $keyType;
        $this.Create = $creatorFunction;
    }
}

class KeyFactory
{
    static [System.Collections.ArrayList] $Factories =
    @(
        [Creator]::new("IAccountKey", "RSAKeyExport", { param($k) return [RSAAccountKey]::Create($k) }),
        [Creator]::new("ICertificateKey", "RSAKeyExport", { param($k) return [RSACertificateKey]::Create($k) }),

        [Creator]::new("IAccountKey", "ECDsaKeyExport", { param($k) return [ECDsaAccountKey]::Create($k) }),
        [Creator]::new("ICertificateKey", "ECDsaKeyExport", { param($k) return [ECDsaCertificateKey]::Create($k) })
    );

    hidden static [KeyBase] Create([Type] $targetType, [KeyExport] $keyParameters)
    {
        $keyType = $keyParameters.GetType();
        $factory = [KeyFactory]::Factories | Where-Object { $_.TargetType -eq $targetType -and $_.KeyType -eq $keyType } | Select-Object -First 1
        
        if ($null -eq $factory) {
            throw [InvalidOperationException]::new("Unknown KeyParameters-Type.");
        }

        return $factory.Create.Invoke($keyParameters);
    }

    static [IAccountKey] CreateAccountKey([KeyExport] $keyParameters) {
        return [KeyFactory]::Create("IAccountKey", $keyParameters);
    }
    static [ICertificateKey] CreateCertificateKey([KeyExport] $keyParameters) {
        return [KeyFactory]::Create("ICertificateKey", $keyParameters);
    }   
}