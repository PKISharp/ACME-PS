<# abstract #>
class KeyBase
{
    [ValidateSet(256,384,512)]
    [int]
    hidden $HashSize;

    [System.Security.Cryptography.HashAlgorithmName]
    hidden $HashName;

    KeyBase([int] $hashSize)
    {
        if ($this.GetType() -eq [KeyBase]) {
            throw [System.InvalidOperationException]::new("Class must be inherited");
        }

        $this.HashSize = $hashSize;

        switch ($hashSize)
        {
            256 { $this.HashName = "SHA256";  }
            384 { $this.HashName = "SHA384";  }
            512 { $this.HashName = "SHA512";  }

            default {
                throw [System.ArgumentOutOfRangeException]::new("Cannot set hash size");
            }
        }
    }

    <# abstract #> [KeyExport] ExportKey() {
        throw [System.NotImplementedException]::new();
    }
}