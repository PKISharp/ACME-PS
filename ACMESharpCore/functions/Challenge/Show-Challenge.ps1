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
        [ACMESharpCore.Crypto.IAccountKey] $AccountKey
    )

    process {
        if($PSCmdlet.ParameterSetName -eq "ByAuthorization") {
            if($type) {
                return ($Authorization.challenges | Where-Object { $_.type -eq $type } | Show-Challenge $AccountKey);
            } else {
                return ($Authorization.challenges | Show-Challenge $AccountKey);
            }
        }

        $challengeData = @{
            
        }

        $content = $($Challenge.token)+"."+$(ConvertTo-UrlBase64 -InputBytes $AccountKey.JwsThumbprint)

        switch($Challenge.type) {
            "http-01" {
                Show-Http01Challenge $Challenge $AccountKey;
            }

            "dns-01" {
                Show-Dns01Challenge $Challenge $AccountKey;
                
            }

            "tls-alpn-1" {
                @{

                }
            }

            Default {
                Write-Error "Cannot show how to resolve challange of type $($Challenge.type)"
            }
        }
    }
}

function Show-Http01Challenge {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [AcmeChallenge] $Challenge,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [ACMESharpCore.Crypto.IAccountKey] $AccountKey
    )

    process {
        if($Challenge.Type -ne "http-01") {
            Write-Error "Method can only be used for http-01 challenges";
            return;
        }

        $fileName = $Challenge.Token;
        $relativePath = "/.well-known/acme-challenges/$fileName"
        $fqdn = "$($Challenge.Identifier.value)$relativePath"
        $content = [ACMESharpCore.Crypto.IAccountKeyExtensions]::ComputeKeyAuthorization($AccountKey, $Challenge.Token);

        return @{
            "Type" = $Challenge.type;
            "Token" = $Challenge.token;
            "Filename" = $fileName;
            "RelativePath" = $relativePath;
            "FullQualifiedDomainName" = $fqdn;
            "Content" = $content;
        }
    }
}

function Show-Dns01Challenge {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [AcmeChallenge] $Challenge,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [ACMESharpCore.Crypto.IAccountKey] $AccountKey
    )

    process {
        if($Challenge.Type -ne "dns-01") {
            Write-Error "Method can only be used for dns-01 challenges";
            return;
        }

        $txtRecordName = "_acme-challenge.$($Challenge.Identifier.value)";
        $content = [ACMESharpCore.Crypto.IAccountKeyExtensions]::ComputeKeyAuthorizationDigest($AccountKey, $Challenge.Token);

        return @{
            "Type" = "dns-01";
            "Token" = $Challenge.token;
            "TxtRecordName" = $txtRecordName;
            "Content" = $content;
        }
    }
}

function Show-TLSALPN01Challenge {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [AcmeChallenge] $Challenge,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [ACMESharpCore.Crypto.IAccountKey] $AccountKey
    )

    process {
        if($Challenge.Type -ne "tls-alpn-01") {
            Write-Error "Method can only be used for tls-alpn-01 challenges";
            return;
        }

        $relativePath = "/.well-known/acme-challenges/$($Challenge.token)"
        $fqdn = "$($Challenge.Identifier.value)$relativePath"
        $content = [ACMESharpCore.Crypto.IAccountKeyExtensions]::ComputeKeyAuthorization($AccountKey, $Challenge.Token);

        return @{
            "Type" = $Challenge.type;
            "Token" = $Challenge.token;
            "SubjectAlternativeName" = $Challenge.Identifier.value;
            "AcmeValidation-v1" = $content;
        }
    }
}