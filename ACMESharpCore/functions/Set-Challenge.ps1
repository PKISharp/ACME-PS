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
        [ACMESharpCore.Crypto.JOSE.JwsAlgorithm] $AccountKey,

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
            $payload = @{};

            $requestBody = New-SignedMessage -Url $Url -JwsAlgorith $AccountKey -KeyId $KeyId -Nonce $Nonce -Payload $payload;
            $response = Invoke-AcmeWebRequest $Url $requestBody -Method POST;

            return $response;
        }
    }
}