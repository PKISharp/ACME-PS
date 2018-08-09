class Creator {
    [Type] $KeyType
    [Func[[AcmeSharpCore.Crypto.AlgorithmKey], [AcmeSharpCore.Crypto.AlgorithmBase]]] $Create

    Creator([Type] $keyType, [Func[[AcmeSharpCore.Crypto.AlgorithmKey], [AcmeSharpCore.Crypto.AlgorithmBase]]] $creatorFunction)
    {
        $this.KeyType = $keyType;
        $this.Create = $creatorFunction;
    }
}

class AlgorithmFactory
{
    static [System.Collections.ArrayList] $Factories =
    @(
        [Creator]::new("AcmeSharpCore.Crypto.RSAKey", { param($k) return [AcmeSharpCore.Crypto.RSAAdapter]::Create($k) }),
        [Creator]::new("AcmeSharpCore.Crypto.ECDsaKey", { param($k) return [AcmeSharpCore.Crypto.ECDsaAdapter]::Create($k) })
    );

    hidden static [AcmeSharpCore.Crypto.AlgorithmKey] Create() {
        return [AcmeSharpCore.Crypto.RSAAdapter]::new(256, 2048);
    }

    hidden static [AcmeSharpCore.Crypto.AlgorithmBase] Create([AcmeSharpCore.Crypto.AlgorithmKey] $keyParameters)
    {
        $keyType = $keyParameters.GetType();
        $factory = [AlgorithmFactory]::Factories | Where-Object { $_.KeyType -eq $keyType } | Select-Object -First 1
        
        if ($null -eq $factory) {
            throw [InvalidOperationException]::new("Unknown KeyParameters-Type.");
        }

        return $factory.Create.Invoke($keyParameters);
    }

    static [AcmeSharpCore.Crypto.IAccountKey] CreateAccountKey([AcmeSharpCore.Crypto.AlgorithmKey] $keyParameters) {
        return [AlgorithmFactory]::Create($keyParameters);
    }
    static [AcmeSharpCore.Crypto.ICertificateKey] CreateCertificateKey([AcmeSharpCore.Crypto.AlgorithmKey] $keyParameters) {
        return [AlgorithmFactory]::Create($keyParameters);
    }   
}