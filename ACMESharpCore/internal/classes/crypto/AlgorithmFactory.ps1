class Creator {
    [Type] $KeyType
    [Func[[KeyExport], [KeyBase]]] $Create

    Creator([Type] $keyType, [Func[[KeyExport], [KeyBase]]] $creatorFunction)
    {
        $this.KeyType = $keyType;
        $this.Create = $creatorFunction;
    }
}

class KeyFactory
{
    static [System.Collections.ArrayList] $Factories =
    @(
        [Creator]::new("RSAKeyExport", { param($k) return [RSAKeyBase]::Create($k) }),
        [Creator]::new("ECDsaKeyExport", { param($k) return [ECDsaKeyBase]::Create($k) })
    );

    hidden static [KeyBase] Create([KeyExport] $keyParameters)
    {
        $keyType = $keyParameters.GetType();
        $factory = [KeyFactory]::Factories | Where-Object { $_.KeyType -eq $keyType } | Select-Object -First 1
        
        if ($null -eq $factory) {
            throw [InvalidOperationException]::new("Unknown KeyParameters-Type.");
        }

        return $factory.Create.Invoke($keyParameters);
    }

    static [IAccountKey] CreateAccountKey([KeyExport] $keyParameters) {
        return [KeyFactory]::Create($keyParameters);
    }
    static [ICertificateKey] CreateCertificateKey([KeyExport] $keyParameters) {
        return [KeyFactory]::Create($keyParameters);
    }   
}