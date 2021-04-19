function Export-CertificateKey {
    <#
        .SYNOPSIS
            Stores an certificate key to the given path.

        .DESCRIPTION
            Stores an certificate key to the given path. If the path already exists an error will be thrown and the key will not be saved.


        .PARAMETER Path
            The path where the key should be exported to. Uses json if path ends with .json. Will use clixml in other cases.

        .PARAMETER CertificateKey
            The certificate key that will be exported to the Path.


        .EXAMPLE
            PS> Export-CertificateKey -Path "C:\myExportPath.xml" -CertificateKey $myCertificateKey
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [AcmePSKey]
        $CertificateKey
    )

    process {
        if(Test-Path $Path) {
            throw "$Path already exists. This method will not override existing files"
        }

        if($Path -like "*.json") {
            $CertificateKey.ExportKey() | ConvertTo-Json -Compress | Out-File $Path -Encoding utf8
            Write-Verbose "Exported certificate key as JSON to $Path";
        } else {
            $CertificateKey.ExportKey() | Export-Clixml -Path $Path
            Write-Verbose "Exported certificate key as CLIXML to $Path";
        }
    }
}
