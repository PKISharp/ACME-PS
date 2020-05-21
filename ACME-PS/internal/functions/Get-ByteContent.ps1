function Get-ByteContent {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )

    if(Test-Path $Path) {
        if($PSVersionTable.PSVersion -ge "6.0") {
            return Get-Content -Path $Path -AsByteStream;
        } else {
            return Get-Content -Path $Path -Encoding Byte;
        }
    }

    return $null;
}
