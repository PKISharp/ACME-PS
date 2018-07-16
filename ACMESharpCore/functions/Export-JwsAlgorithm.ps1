function Export-JwsAlgorithm {
    <#
        .SYNOPSIS
            Exports the JwsAlgorithm
        .DESCRIPTION
            Exports the JwsAlgorithm, so it can be stored somewhere

        .EXAMPLE
            PS> Export-JwsAlgorithm $myAlgorithm
    #>
    [CmdletBinding()]
    param(
        # The Algorithm to export
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [ACMESharp.Crypto.JOSE.JwsAlgorithm]
        $JwsAlgorithm,

        [Parameter(Position = 1)]
        [string]
        $Path
    )

    if($Path) {
        Write-Verbose "Exporting JwsAlgorithm to CliXML: $Filename";
        $JwsAlgortihm.Export() | Export-Clixml -Path $Path
        return Get-Item $Path;
    } else {
        return $JwsAlgorithm.Export();
    }
}