function Show-Challenge {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNull()]
        [AcmeChallenge] $Challenge,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [JwsAlgorithm] $JwsAlgorithm
    )

    $content = $($Challenge.token)+"."+$(ConvertTo-UrlBase64 -InputBytes $JwsAlgorithm.JwsThumbprint)

    switch($Challenge.type) {
        "http-01" {
            $relativePath = "/.well-known/acme-challenges/$($Challenge.token)"

            @{
                "type" = "http-01";
                "token" = $Challenge.token;
                "relativePath" = $relativePath;
                "fqdn" = "$($Challenge.Identifier.value)$relativePath"
                "content" = $content;
            }
        }

        "dns-01" {
            @{
                "type" = "dns-01";
                "token" = $Challenge.token;
                "txtRecord" = "_acme-challenge.$($Challenge.Identifier.value)";
                "content" = $content;
            }
        }

        Default {
            Write-Error "Cannot show how to resolve challange"
        }
    }
}