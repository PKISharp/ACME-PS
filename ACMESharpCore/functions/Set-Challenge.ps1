function Set-Challenge {
    <#
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [uri] $Url,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [ACMESharp.Crypto.JOSE.JwsAlgorithm] $JwsAlgorithm,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string] $KeyId,

        [Parameter(Position = 4)]
        [ValidateNotNullOrEmpty()]
        [string] $Nonce = $Script:Nonce,

        # Parameter help description
        [Parameter(ParameterSetName = "CompleteChallenge")]
        [Switch] $CompleteChallenge
    )

    process {
        if($PSCmdlet.ParameterSetName -eq "CompleteChallenge" -and $CompleteChallenge) {
            $requestBody = New-SignedMessage -Url $Url -JwsAlgorith $JwsAlgorithm -KeyId $KeyId -Nonce $Nonce -Payload $payload;
            $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST;

            return $response;
        }
    }
}