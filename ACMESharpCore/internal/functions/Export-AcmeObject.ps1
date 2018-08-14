function Export-AcmeObject {
    param(
        [Parameter(Mandatory=$true, Position = 0)]
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
        $ErrorActionPreference = 'Stop'
        
        if(Test-Path $Path -and -not $Force) {
            Write-Error "$Path already exists."
        }

        if($FileName -like "*.json") {
            $InputObject | ConvertTo-Json | Out-File -FilePath $FilePath -Encoding utf8 -Force:$Force;
        } else {
            Export-Clixml $FilePath -InputObject $InputObject -Force:$Force;
        }
    }
}