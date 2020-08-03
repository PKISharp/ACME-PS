function ConvertFrom-UrlBase64 {
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [string] $InputText
    )

    process {
        $base64 = $InputText.Replace('-','+');
        $base64 = $base64.Replace('_', '/');

        while($base64.Length % 4 -ne 0) {
            $base64 += '='
        }

        return [Convert]::FromBase64String($base64);
    }
}