function Get-Challenge {
    <#
        .SYNOPSIS
            Gets the challange from the ACME service.

        .DESCRIPTION
            Gets the challange of the specified type from the specified authorization and prepares it with
            data needed to complete the challange

        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER Authorization
            The authorization for which the challange will be fetched.

        .PARAMETER Type
            The challange type to fetch. One of http-01,dns-01,tls-alpn-01


        .EXAMPLE
            PS> $myAuthorization | Get-Challange -State $myState -Type "http-01"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountExists()})]
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
        if(-not $challange) {
            throw "Cannot find challange of type $Type";
        }

        if(-not $challange.Data) {
            $challange | Initialize-Challenge $State
        }

        return $challange;
    }
}
