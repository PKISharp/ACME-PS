function New-Identifier {
    param(
        # Parameter help description
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Type,

        # Parameter help description
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Value
    )

    return @{"type" = $Type; "value" = $Value};
}