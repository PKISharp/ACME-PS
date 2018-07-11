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
    param(
        # The name of the JWS Algorithm to create
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName="ByName")]
        [ValidateSet("ES256","ES374","ES512", "RS256", "RS374", "RS512")]
        [string] 
        $JwsAlgorithmName,

        # Use the JwsAlgorithmExport to recreate the algorithm
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName="ByJWK")]
        [ACMESharp.Crypto.JOSE.JwsAlgorithmExport]
        $JwsExport
    )

    if($PSCmdlet.ParameterSetName -eq "ByJWK") {
        return [ACMESharp.Crypto.JOSE.JwsAlgorithm]::new($JwsExport);
    }

    if($PSCmdlet.ParameterSetName -eq "ByName") {
        return [ACMESharp.Crypto.JOSE.JwsAlgorithm]::new($JwsAlgorithmName);
    } 
}