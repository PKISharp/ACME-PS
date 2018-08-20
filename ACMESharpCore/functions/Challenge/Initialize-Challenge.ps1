function Initialize-Challenge {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.Validate()})]
        [AcmeState]
        $State,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName="ByAuthorization")]
        [ValidateNotNull()]
        [AcmeAuthorization] $Authorization,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName="ByChallenge")]
        [ValidateNotNull()]
        [AcmeChallenge] $Challenge,

        [Parameter()]
        [switch]
        $PassThrough
    )

    process {
        if($PSCmdlet.ParameterSetName -eq "ByAuthorization") {
            return ($Authorization.challenges | Initialize-Challenge $State -PassThrough:$PassThrough);
        }

        $accountKey = $State.GetAccountKey();

        switch($Challenge.Type) {
            "http-01" { 
                $fileName = $Challenge.Token;
                $relativePath = "/.well-known/acme-challenges/$fileName"
                $fqdn = "$($Challenge.Identifier.Value)$relativePath"
                $content = [KeyAuthorization]::Compute($AccountKey, $Challenge.Token);

                $Challenge.Data = [PSCustomObject]@{
                    "Type" = $Challenge.Type;
                    "Token" = $Challenge.Token;
                    "Filename" = $fileName;
                    "RelativeUrl" = $relativePath;
                    "AbsoluteUrl" = $fqdn;
                    "Content" = $content;
                }
            }

            "dns-01" {
                $txtRecordName = "_acme-challenge.$($Challenge.Identifier.Value)";
                $content = [KeyAuthorization]::ComputeDigest($AccountKey, $Challenge.Token);

                $Challenge.Data =  [PSCustomObject]@{
                    "Type" = "dns-01";
                    "Token" = $Challenge.Token;
                    "TxtRecordName" = $txtRecordName;
                    "Content" = $content;
                }
            }

            "tls-alpn-01" {
                $content = [KeyAuthorization]::Compute($AccountKey, $Challenge.Token);

                $Challenge.Data =  [PSCustomObject]@{
                    "Type" = $Challenge.Type;
                    "Token" = $Challenge.Token;
                    "SubjectAlternativeName" = $Challenge.Identifier.Value;
                    "AcmeValidation-v1" = $content;
                }
            }

            Default {
                Write-Error "Cannot show how to resolve challange of unknown type $($Challenge.Type)"
            }
        }

        if($PassThrough) {
            return $Challenge;
        }
    }
}