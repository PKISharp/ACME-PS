function Get-JwsAlgorithm {
    <#
        .SYNOPSIS
            Creates a JWS-Algorithm
        .DESCRIPTION
            Create a JWS-Algorithm by either its name or by an existing JwsAlgorithmExport

        .EXAMPLE
            PS> Get-JwsAlgorithm "ES256"
        .EXAMPLE
            PS> Get-JwsAlgorithm $myAlgoExport
    #>
    [CmdletBinding()]
    param(
        # Use the JwsAlgorithmExport to recreate the algorithm
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName="ByJWKExport")]
        [ACMESharp.Crypto.JOSE.JwsAlgorithmExport]
        $JwsExport,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName="ByCliXml")]
        [string]
        $LiteralPath
    )

    $factory = [ACMESharp.Crypto.JOSE.JwsAlgorithmFactory]::new();

    switch ($PSCmdlet.ParameterSetName) {
        "ByCliXml" {
            $export = [ACMESharp.Crypto.JOSE.JwsAlgorithmExport](Import-Clixml $LiteralPath);
            return $factory.Create($export);
        }

        "ByJWKExport" { 
            return $factory.Create($JwsExport);
        }
    }
}