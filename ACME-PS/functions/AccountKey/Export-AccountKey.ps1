function Export-AccountKey {
    <#
        .SYNOPSIS
            Stores an account key to the given path.

        .DESCRIPTION
            Stores an account key to the given path. If the path already exists an error will be thrown and the key will not be saved.


        .PARAMETER Path
            The path where the key should be exported to. Uses json if path ends with .json. Will use clixml in other cases.

        .PARAMETER AccountKey
            The account key that will be exported to the Path. If AutomaticAccountKeyHandling is enabled it will export the registered account key.

        .PARAMETER Force
            Allow the command to override an existing account key.


        .EXAMPLE
            PS> Export-AccountKey -Path "C:\myExportPath.xml" -AccountKey $myAccountKey
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [IAccountKey]
        $AccountKey,

        [Parameter()]
        [switch]
        $Force
    )

    process {
        $ErrorActionPreference = 'Stop';

        $AccountKey.ExportKey() | Export-AcmeObject $Path -Force:$Force
    }
}