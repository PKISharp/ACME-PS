function Show-Challenge {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName="ByAuthorization")]
        [ValidateNotNull()]
        [AcmeAuthorization] $Authorization,

        [Parameter(Mandatory = $true, Position=1, ParameterSetName="ByAuthorization")]
        [ValidateSet("http-01", "dns-01", "tls-alpn-01")]
        [string] $Type,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName="ByChallenge")]
        [ValidateNotNull()]
        [AcmeChallenge] $Challenge,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate()})]
        [AcmeState]
        $State
    )

    process {
        if($PSCmdlet.ParameterSetName -eq "ByAuthorization") {
            return ($Authorization.challenges | Where-Object { $_.Type -eq $Type } |
                Select-Object -First 1 | Show-Challenge -AccountKey $AccountKey);
        }

        $accountKey = $State.GetAccountKey();

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
        $content = [KeyAuthorization]::Compute($AccountKey, $Challenge.Token);

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
        $content = [KeyAuthorization]::ComputeDigest($AccountKey, $Challenge.Token);

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

        $content = [IAccountKeyExtensions]::Compute($AccountKey, $Challenge.Token);

        return @{
            "Type" = $Challenge.Type;
            "Token" = $Challenge.Token;
            "SubjectAlternativeName" = $Challenge.Identifier.Value;
            "AcmeValidation-v1" = $content;
        }
    }
}