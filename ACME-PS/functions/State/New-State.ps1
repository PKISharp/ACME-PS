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
    [CmdletBinding(SupportsShouldProcess=$true, DefaultParameterSetName="FileStored")]
    param(
        [Parameter(ParameterSetName="FileStored")]
        [ValidateNotNullOrEmpty()]
        [IO.DirectoryInfo]
        $Path = (Get-RuntimeDataPath),

        [Parameter(ParameterSetName="InMemory")]
        [switch]
        $InMemory
    )

    process {
        if ($InMemory.IsPresent) 
        {
            Write-Warning "In-memory state will not be persisted to disk. Account keys and similar will not be saved automatically."
            return [AcmeInMemoryState]::new()
        } 
        else
        {
            if($PSCmdlet.ShouldProcess("State", "Create new state and save it to $Path")) {
                $paths = [AcmeStatePaths]::new($Path);
                return [AcmeDiskPersistedState]::new($paths, $true, $true);
            }
        }
    }
}
