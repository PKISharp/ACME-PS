function Initialize-Challenge {
    <#
        .SYNOPSIS
            Prepares a challange with the data explaining how to complete it.

        .DESCRIPTION
            Provides the data how to resolve the challange into the challanges data property.

        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER Authorization
            The authorization of which all challanges will be initialized.

        .PARAMETER Challenge
            The challenge which should be initialized.

        .PARAMETER PassThru
            Forces the command to return the data to the pipeline.


        .EXAMPLE
            PS> Initialize-Challange $myState -Challange $challange
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateScript({$_.AccountExists()})]
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
        $PassThru
    )

    process {
        if($PSCmdlet.ParameterSetName -eq "ByAuthorization") {
            return ($Authorization.challenges | Initialize-Challenge $State -PassThru:$PassThru);
        }

        $accountKey = $State.GetAccountKey();

        switch($Challenge.Type) {
            "http-01" {
                $fileName = $Challenge.Token;
                $relativePath = "/.well-known/acme-challenge/$fileName"
                $fqdn = "$($Challenge.Identifier.Value)$relativePath"
                $content = $AccountKey.GetKeyAuthorization($Challenge.Token);

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
                $content = $AccountKey.GetKeyAuthorizationDigest($Challenge.Token);

                $Challenge.Data =  [PSCustomObject]@{
                    "Type" = $Challenge.Type;
                    "Token" = $Challenge.Token;
                    "TxtRecordName" = $txtRecordName;
                    "Content" = $content;
                }
            }

            "dns-persist-01" {
                $validationDomainName = "_validation-persist.$($Challenge.Identifier.Value)";
                $accountUri = $Challenge.RawChallenge.accountUri;
                $issuerDomainNames = $Challenge.RawChallenge.issuerDomainNames;

                $expectedContent = @($issuerDomainNames | ForEach-Object { "$_;accountUri=$accountUri" });

                $Challenge.Data =  [PSCustomObject]@{
                    "Type" = $Challenge.Type;
                    "ValidationDomainName" = $validationDomainName;
                    "ExpectedContent" = $expectedContent;
                }
            }

            "tls-alpn-01" {
                $content = $AccountKey.GetKeyAuthorization($Challenge.Token);

                $Challenge.Data =  [PSCustomObject]@{
                    "Type" = $Challenge.Type;
                    "Token" = $Challenge.Token;
                    "SubjectAlternativeName" = $Challenge.Identifier.Value;
                    "AcmeValidation-v1" = $content;
                }
            }

            
            Default {
                Write-Warning "Challenge type '$($Challenge.Type)' is not supported by this module. No data has been initialized for this challenge. But you can still use the data from the raw challenge to complete it manually.";
            }
        }

        if($PassThru) {
            return $Challenge;
        }
    }
}
