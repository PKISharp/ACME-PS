function Export-JwsAlgorithm {
    <#
        .SYNOPSIS
            Exports the JwsAlgorithm
        .DESCRIPTION
            Exports the JwsAlgorithm, so it can be stored somewhere.
            If the Path parameter is present, Export-Clixml will be used to store the export with the given filename.

        .EXAMPLE
            PS> Export-JwsAlgorithm $myAlgorithm
        .EXAMPLE
            PS> Export-JwsAlgorithm $myAlgorithm -Path "C:\Temp\JwsExport.xml"
    #>
    [CmdletBinding()]
    param(
        # The Algorithm to export
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [ACMESharpCore.Crypto.JOSE.JwsAlgorithm]
        $JwsAlgorithm,

        # The path where the export should be saved. This will use Export-Clixml.
        [Parameter(Position = 1)]
        [string]
        $Path
    )

    process {
        if($Path) {
            Write-Verbose "Exporting JwsAlgorithm to CliXML: $Filename";
            $JwsAlgorithm.Export() | Export-Clixml -Path $Path
            return Get-Item $Path;
        } else {
            return $JwsAlgorithm.Export();
        }
    }
}