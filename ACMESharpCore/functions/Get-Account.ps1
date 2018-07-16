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
        [string] $KeyId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Nonce
    )

    $requestBody = New-SignedMessage -Url $Url -Payload @{} -JwsAlgorithm $JwsAlgorithm -KeyId $KeyId -Nonce $Nonce

    $response = Invoke-AcmeWebRequest $Url -Method POST -JsonBody $requestBody
    return [ACMEResponse]::new($response);
}