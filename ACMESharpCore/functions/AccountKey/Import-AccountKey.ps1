function Import-AccountKey {
    <#
        .SYNOPSIS
            Imports an exported account key.
        
        .DESCRIPTION
            Imports an account key that has been exported with Export-AccountKey. If requested, the key is registered for automatic key handling.

        .PARAMETER Path
            The path where the key has been exported to.

        .PARAMETER AutomaticAccountKeyHandling
            If set, automatic handling of the account key will be enabled.
    #>
    param(
        # Specifies a path to one or more locations.
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $AutomaticAccountKeyHandling
    )

    process {
        $ErrorActionPreference = 'Stop'

        if($Path -like "*.json") {
            $imported = Get-Content $Path -Raw | ConvertFrom-Json | ConvertTo-OriginalType;
        } else {
            $imported = Import-Clixml $Path | ConvertTo-OriginalType;
        }

        $accountKey = [KeyFactory]::CreateAccountKey($imported);
        
        if($AutomaticAccountKeyHandling) {
            Enable-AccountKeyHandling $accountKey;
        }

        return $accountKey;
    }
}