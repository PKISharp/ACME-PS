function New-State {
    <#
        .SYNOPSIS
            Initializes a new state object.

        .DESCRIPTION
            Initializes a new state object, that will be used by other functions
            to access the service directory, nonce, account and account key.


        .PARAMETER Path
            Directory where the state will be persisted.

        .EXAMPLE
            PS> New-State
    #>
    param(
        [Parameter()]
        [string]
        $Path
    )

    process {
        if(-not $Path) {
            Write-Warning "You did not provide a persistency path. State will not be saved automatically."
            return [AcmeState]::new()
        } else {
            return [AcmeState]::new($Path, $true);
        }
    }
}