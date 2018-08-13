function Import-AccountKey {
    <#
        .SYNOPSIS
            Imports an exported account key.

        .DESCRIPTION
            Imports an account key that has been exported with Export-AccountKey. If requested, the key is registered for automatic key handling.

        .PARAMETER Path
            The path where the key has been exported to.

        .PARAMETER State
            The account key will be written into the provided state instance.

        .PARAMETER PassThrough
            If set, the account key will be returned to the pipeline.
    #>
    param(
        # Specifies a path to one or more locations.
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [AcmeState]
        $State,

        [Parameter()]
        [switch]
        $PassThrough
    )

    process {
        $ErrorActionPreference = 'Stop'

        if($Path -like "*.json") {
            $imported = Get-Content $Path -Raw | ConvertFrom-Json | ConvertTo-OriginalType;
        } else {
            $imported = Import-Clixml $Path | ConvertTo-OriginalType;
        }

        $accountKey = [KeyFactory]::CreateAccountKey($imported);
        $state.AccountKey = $accountKey;

        if($PassThrough) {
            return $accountKey;
        }
    }
}