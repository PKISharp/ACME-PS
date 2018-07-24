function New-JwsAlgorithm {
    <#
        .SYNOPSIS
            Creates a JWS-Algorithm
        .DESCRIPTION
            Create a JWS-Algorithm by its name.
            The name is no JwsAlg name, but one which is used by the ACMESharpCore JwsAlgorithmFactory

        .EXAMPLE
            PS> New-JwsAlgorithm "ES256"
        .EXAMPLE
            PS> New-JwsAlgorithm "RS256-2048"
    #>
    [CmdletBinding()]
    param(
        # The name of the JWS Algorithm to create
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet("ES256","ES384","ES512", "RS256-2048", "RS256-3072", "RS256-4096")]
        [string] 
        $JwsAlgorithmName
    )

    $factory = [ACMESharp.Crypto.JOSE.JwsAlgorithmFactory]::new();
    return $factory.Create($JwsAlgorithmName);
}