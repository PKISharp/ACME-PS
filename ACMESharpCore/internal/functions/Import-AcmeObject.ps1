function Import-AcmeObject {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_})]
        [string]
        $Path,

        [Parameter()]
        [string]
        $TypeName
    )

    process {
        $ErrorActionPreference = 'Stop'

        if($Path -like "*.json") {
            $imported = Get-Content $Path -Raw | ConvertFrom-Json;
        } else {
            $imported = Import-Clixml $Path;
        }

        if($TypeName) {
            $result = $imported | ConvertTo-OriginalType -TypeName $TypeName
        } else {
            $result = $imported | ConvertTo-OriginalType
        }

        return $result;
    }
}