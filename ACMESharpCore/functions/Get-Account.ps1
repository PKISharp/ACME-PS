function Get-Account {
    <#
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [uri] $Url, 

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ACMESharp.Crypto.JOSE.JwsAlgorithm] $JwsAlgorithm,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [int] $KeyId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Nonce
    )

    $requestBody = New-SignedMessage -Url $Url -Payload @{} -JwsAlgorithm $JwsAlgorithm -KeyId $KeyId -Nonce $Nonce

    $response = Invoke-WebRequest $Url -Method POST -Body $requestBody -ContentType "application/jose+json"
    return [ACMEResponse]::new($response);
}