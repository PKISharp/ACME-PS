InModuleScope ACME-PS {
    Describe "UnitTesting Complete-Order" -Tag "UnitTest" {
        $Urls = @{
            ResourceUrl = "https://service.acme/Order1";
            AuthorizationUrl = "https://service.acme/Order1/AuthZ";
            FinalizeUrl = "https://service.acme/Order1/Finalize";
        };
        
        Mock Invoke-AcmeWebRequest {
            $mockResult = [AcmeHttpResponse]::new();
            $mockResult.NextNonce = "NextNonce";
            return  $mockResult;
        } -Verifiable -ParameterFilter {
            $Url -eq $Urls.FinalizeUrl -and
            $Method -eq "POST"
        }

        $simpleState = Get-State -Path "$PSScriptRoot\states\simple";
        $state = New-State -WarningAction 'SilentlyContinue';

        $state.Set($simpleState.GetServiceDirectory())
        $state.SetNonce($simpleState.GetNonce());
        $state.Set($simpleState.GetAccountKey());
        $state.Set($simpleState.GetAccount());

        $order = [AcmeOrder]::new([PSCustomObject]@{
            Status = "ready";
            Expires  = [DateTime]::Now.AddDays(1);

            Identifiers = @(
                New-Identifier "www.example2.com";
                New-Identifier "www.example1.com";
            )

            AuthorizationUrls = $Urls.AuthorizationUrl;
            FinalizeUrl = $Urls.FinalizeUrl;

            ResourceUrl = $Urls.ResourceUrl;
            CSROptions = [AcmeCsrOptions]::new([PSCustomObject]@{
                DistinguishedName = "CN=CommonName";
            });
        });
        
        $certificateKey = New-CertificateKey -RSA -SkipKeyExport -WarningAction 'SilentlyContinue';

        Context 'CustomKey parameter set' {
            Complete-Order -State $state -Order $order -CertificateKey $certificateKey;

            It 'called ACME service to finalize the order' {
                Assert-VerifiableMock
            }
        }
    }
}