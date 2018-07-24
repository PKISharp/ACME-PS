function New-Identifier {
    param(
        # Parameter help description
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Type,

        # Parameter help description
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Value
    )

    process {
        return [AcmeIdentifier]::new($Type, $Value);
    }
}