function ConverTo-NSJson {
    [OutputType("string")]
    param(
        [Parameter()]
        [ValidateNotNull()]
        $inputObject,

        [Parameter()]
        [switch]
        $Indented
    )
    
    if($Indented) {
        return [Newtonsoft.Json.JsonConvert]::SerializeObject($inputObject);
    } else {
        return [Newtonsoft.Json.JsonConvert]::SerializeObject($inputObject, [Newtonsoft.Json.Formatting]::None);
    }
}