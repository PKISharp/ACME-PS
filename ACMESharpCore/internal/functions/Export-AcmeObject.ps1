function Export-AcmeObject {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FilePath,

        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        $InputObject
    )

    if($FileName -like "*.json") {
        $InputObject | ConvertTo-Json | Out-File -FilePath $FilePath -Encoding utf8;
    } else {
        Export-Clixml $Path -InputObject $InputObject;
    }
}