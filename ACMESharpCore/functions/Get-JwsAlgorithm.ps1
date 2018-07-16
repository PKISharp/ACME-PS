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
        # The name of the JWS Algorithm to create
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName="ByName")]
        [ValidateSet("ES256","ES374","ES512", "RS256-2048", "RS374-2048", "RS512-2048")]
        [string] 
        $JwsAlgorithmName,

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

        "ByName" {
            return $factory.Create($JwsAlgorithmName);
        }
    }
}