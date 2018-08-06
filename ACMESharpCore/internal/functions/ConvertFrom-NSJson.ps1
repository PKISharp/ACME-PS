function ConvertFrom-NSJson {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [string]
        $inputString,

        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNull()]
        [Type]
        $TargetType
    )

    process {
        [Newtonsoft.Json.JsonConvert]::DeserializeObject($inputString, $targetType);
    }
}

