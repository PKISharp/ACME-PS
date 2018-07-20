function New-JwsAlgorithm {
    <#
        .SYNOPSIS
            Creates a JWS-Algorithm
        .DESCRIPTION
            Create a JWS-Algorithm by either its name.
            The Name is no JwsAlg Name, but is a name, which is parsable by the ACMESharpCore JwsAlgorithmFactory

        .EXAMPLE
            PS> New-JwsAlgorithm "ES256"
    #>
    [CmdletBinding()]
    param(
        # The name of the JWS Algorithm to create
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName="ByName")]
        [ValidateSet("ES256","ES374","ES512", "RS256-2048", "RS374-2048", "RS512-2048")]
        [string] 
        $JwsAlgorithmName
    )

    $factory = [ACMESharp.Crypto.JOSE.JwsAlgorithmFactory]::new();
    return $factory.Create($JwsAlgorithmName);
}