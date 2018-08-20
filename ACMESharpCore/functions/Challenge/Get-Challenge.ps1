function Get-Challenge {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateNotNull()]
        [AcmeAuthorization] $Authorization,

        [Parameter(Mandatory = $true, Position = 2)]
        [string] $Type
    )

    process {
        $challange = $Authorization.Challenges | Where-Object { $_.Type -eq $Type } | Select-Object -First 1
        if(-not $challange.Data) {
            $challange | Initialize-Challange $State 
        }

        return $challange;
    }
}
