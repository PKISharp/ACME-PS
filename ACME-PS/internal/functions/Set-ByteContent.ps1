function Set-ByteContent {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [byte[]]
        $Content
    )

    if(Test-Path $Path) {
        Clear-Content $Path;
    }

    if($PSVersionTable.PSVersion -ge "6.0") {
        $Content | Set-Content $Path -AsByteStream;
    } else {
        $Content | Set-Content $Path -Encoding Byte;
    }
}
