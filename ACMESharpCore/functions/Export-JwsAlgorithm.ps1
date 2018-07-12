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
        $JwsAlgorithm
    )

    Write-Verbose "Exporting JwsAlgorithm $($JwsAlgorithm.JwsAlg) including it's private key parameters."
    return $JwsAlgorithm.Export();
}