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
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter()]
        [string]
        $Path
    )

    process {
        if(-not $Path) {
            Write-Warning "You did not provide a persistency path. State will not be saved automatically."
            return [AcmeInMemoryState]::new()
        } else {
            if($PSCmdlet.ShouldProcess("State", "Create new state and save it to $Path")) {
                return [AcmeState]::FromPath($Path);
            }
        }
    }
}