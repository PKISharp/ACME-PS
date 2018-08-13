function Export-AcmeObject {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FilePath,

        [Parameter(Mandatory=$true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        $InputObject,

        [Parameter()]
        [switch]
        $Force
    )

    process {
        if($FileName -like "*.json") {
            $InputObject | ConvertTo-Json | Out-File -FilePath $FilePath -Encoding utf8 -Force:$Force;
        } else {
            Export-Clixml $Path -InputObject $InputObject -Force:$Force;
        }
    }
}