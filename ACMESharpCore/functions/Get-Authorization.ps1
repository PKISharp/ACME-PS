function Get-Authorization {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ParameterSetName="FromOrder")]
        [ValidateNotNull()]
        [AcmeOrder] $Order,

        # Parameter help description
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName="FromUrl")]
        [ValidateNotNullOrEmpty()]
        [uri] $Url
    )

    switch ($PSCmdlet.ParameterSetName) {
        "FromOrder" {
            $Order.AuthorizationUrls | Get-Authorization -Url $_
        }
        Default {
            $response = Invoke-AcmeWebRequest -Url $Url -Method GET;
            return [AcmeAuthorization]::new($response);
        }
    }
}