function Show-Challenge {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName="ByAuthorization")]
        [ValidateNotNull()]
        [AcmeAuthorization] $Authorization,

        [Parameter(ParameterSetName="ByAuthorization")]
        [string] $Type,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName="ByChallenge")]
        [ValidateNotNull()]
        [AcmeChallenge] $Challenge,

        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [IAccountKey] $AccountKey = $Script:AccountKey
    )

    process {
        if($PSCmdlet.ParameterSetName -eq "ByAuthorization") {
            if($Type) {
                return ($Authorization.challenges | Where-Object { $_.Type -eq $Type } | Show-Challenge -AccountKey $AccountKey);
            } else {
                return ($Authorization.challenges | Show-Challenge -AccountKey $AccountKey);
            }
        }

        switch($Challenge.Type) {
            "http-01" { Show-Http01Challenge $Challenge $AccountKey; }
            "dns-01" { Show-Dns01Challenge $Challenge $AccountKey; }
            "tls-alpn-01" { Show-TLSALPN01Challenge $Challenge $AccountKey; }

            Default {
                Write-Error "Cannot show how to resolve challange of type $($Challenge.Type)"
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
        [IAccountKey] $AccountKey
    )

    process {
        if($Challenge.Type -ne "http-01") {
            Write-Error "Method can only be used for http-01 challenges";
            return;
        }

        $fileName = $Challenge.Token;
        $relativePath = "/.well-known/acme-challenges/$fileName"
        $fqdn = "$($Challenge.Identifier.Value)$relativePath"
        $content = [IAccountKeyExtensions]::ComputeKeyAuthorization($AccountKey, $Challenge.Token);

        return @{
            "Type" = $Challenge.Type;
            "Token" = $Challenge.Token;
            "Filename" = $fileName;
            "RelativeUrl" = $relativePath;
            "AbsoluteUrl" = $fqdn;
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
        [IAccountKey] $AccountKey
    )

    process {
        if($Challenge.Type -ne "dns-01") {
            Write-Error "Method can only be used for dns-01 challenges";
            return;
        }

        $txtRecordName = "_acme-challenge.$($Challenge.Identifier.Value)";
        $content = [IAccountKeyExtensions]::ComputeKeyAuthorizationDigest($AccountKey, $Challenge.Token);

        return @{
            "Type" = "dns-01";
            "Token" = $Challenge.Token;
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
        [IAccountKey] $AccountKey
    )

    process {
        if($Challenge.Type -ne "tls-alpn-01") {
            Write-Error "Method can only be used for tls-alpn-01 challenges";
            return;
        }

        $relativePath = "/.well-known/acme-challenges/$($Challenge.Token)"
        $fqdn = "$($Challenge.Identifier.Value)$relativePath"
        $content = [IAccountKeyExtensions]::ComputeKeyAuthorization($AccountKey, $Challenge.Token);

        return @{
            "Type" = $Challenge.Type;
            "Token" = $Challenge.Token;
            "SubjectAlternativeName" = $Challenge.Identifier.Value;
            "AcmeValidation-v1" = $content;
        }
    }
}