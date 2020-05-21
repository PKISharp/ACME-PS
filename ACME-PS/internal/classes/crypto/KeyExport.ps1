<# abstract #>
class KeyExport {
    KeyExport () {
        if ($this.GetType() -eq [KeyExport]) {
            throw [System.InvalidOperationException]::new("Class must be inherited");
        }
    }

    <# abstract #> [string] TypeName() {
        throw [System.NotImplementedException]::new();
    }
}

class RSAKeyExport : KeyExport {
    hidden [string] $TypeName = "RSAKeyExport";

    [int] $HashSize;

    [byte[]] $Modulus;
    [byte[]] $Exponent;
    [byte[]] $P;
    [byte[]] $Q;
    [byte[]] $DP;
    [byte[]] $DQ;
    [byte[]] $InverseQ;
    [byte[]] $D;
}

class ECDsaKeyExport : KeyExport {
    hidden [string] $TypeName = "ECDsaKeyExport";

    [int] $HashSize;

    [byte[]] $D;
    [byte[]] $X;
    [byte[]] $Y;
}
