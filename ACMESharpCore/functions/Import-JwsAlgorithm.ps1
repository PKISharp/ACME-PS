function Import-JwsAlgorithm {
    <#
        .SYNOPSIS
            Imports a JWS-Algorithm
        .DESCRIPTION
            Imports a JWS-Algorithm by an existing JwsAlgorithmExport from an object or an export-file created with Export-JwsAlgorithm.

        .EXAMPLE
            PS> Get-JwsAlgorithm -Path C:\Temp\JwsExport.xml
        .EXAMPLE
            PS> Get-JwsAlgorithm $exportedAlgo
    #>
    [CmdletBinding()]
    param(
        # Use this JwsAlgorithmExport to recreate the algorithm
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName="ByJWKExport")]
        [ACMESharp.Crypto.JOSE.JwsAlgorithmExport]
        $JwsExport,

        # Import the algorithm from this file in Clixml format.
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName="ByCliXml")]
        [string]
        $Path
    )

    process {
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
}