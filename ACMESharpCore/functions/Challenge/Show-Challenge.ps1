function Show-Challenge {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName="ByAuthorization")]
        [ValidateNotNull()]
        [AcmeAuthorization] $Authorization,

        [Parameter(ParameterSetName="ByAuthorization")]
        [string] $type,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName="ByChallenge")]
        [ValidateNotNull()]
        [AcmeChallenge] $Challenge,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [ACMESharpCore.Crypto.JOSE.JwsAlgorithm] $AccountKey
    )

    process {
        if($PSCmdlet.ParameterSetName -eq "ByAuthorization") {
            if($type) {
                return ($Authorization.challenges | Where-Object { $_.type -eq $type } | Show-Challenge $AccountKey);
            } else {
                return ($Authorization.challenges | Show-Challenge $AccountKey);
            }
        }

        $content = $($Challenge.token)+"."+$(ConvertTo-UrlBase64 -InputBytes $AccountKey.JwsThumbprint)

        switch($Challenge.type) {
            "http-01" {
                $relativePath = "/.well-known/acme-challenges/$($Challenge.token)"

                @{
                    "Type" = "http-01";
                    "Token" = $Challenge.token;
                    "RelativePath" = $relativePath;
                    "FullQualifiedDomainName" = "$($Challenge.Identifier.value)$relativePath"
                    "Content" = $content;
                }
            }

            "dns-01" {
                @{
                    "Type" = "dns-01";
                    "Token" = $Challenge.token;
                    "TxtRecordName" = "_acme-challenge.$($Challenge.Identifier.value)";
                    "Content" = $content;
                }
            }

            "sni-anmc-01" {
                @{}
            }

            Default {
                Write-Error "Cannot show how to resolve challange of type $($Challenge.type)"
            }
        }
    }
}