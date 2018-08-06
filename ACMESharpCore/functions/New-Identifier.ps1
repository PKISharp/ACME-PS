function New-Identifier {
    <#
        .SYNOPSIS
            Creates a new identifier.

        .DESCRIPTION
            Creates a new identifier needed for orders and authorizations

        
        .PARAMETER Type
            The identifier type

        .PARAMETER Value
            The value of the identifer, e.g. the FQDN.

        
        .EXAMPLE
            PS> New-Identifier DNS www.example.com
    #>
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Type,

        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Value
    )

    process {
        return [AcmeIdentifier]::new($Type, $Value);
    }
}