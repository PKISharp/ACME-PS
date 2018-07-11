function Export-JwsAlgorithm {
    <#
        .SYNOPSIS
            Exports the JwsAlgorithm
        .DESCRIPTION
            Exports the JwsAlgorithm, so it can be stored somewhere

        .EXAMPLE
            PS> Export-JwsAlgorithm $myAlgorithm
    #>
    param(
        # The Algorithm to export
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName="ByJWK")]
        [ValidateNotNull]
        [ACMESharp.Crypto.JOSE.JwsAlgorithm]
        $JwsAlgorithm
    )

    return $JwsAlgorithm.Export();
}