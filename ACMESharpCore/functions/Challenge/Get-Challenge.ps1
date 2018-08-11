function Get-Challenge {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNull()]
        [AcmeAuthorization] $Authorization,

        [Parameter(Mandatory = $true, Position = 1)]
        [string] $Type
    )

    process {
        return $Authorization.Challenges | Where-Object { $_.Type -eq $Type } | Select-Object -First 1
    }
}
