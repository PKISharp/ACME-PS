InModuleScope ACME-PS {
    Describe "UnitTesting New-ACMEOrder" -Tag "UnitTest" {
        Mock Invoke-AcmeWebRequest {
            $mockResult = [AcmeHttpResponse]::new();
            $mockResult.NextNonce = "NextNonce";
            return  $mockResult;
        } -Verifiable -ParameterFilter {
            $Url -eq $state.GetServiceDirectory().NewOrder -and
            $Method -eq "POST"
        }

        $simpleState = Get-ACMEState -Path "$PSScriptRoot\states\simple";
        $state = New-ACMEState -WarningAction 'SilentlyContinue';

        $state.Set($simpleState.GetServiceDirectory())
        $state.SetNonce($simpleState.GetNonce());
        $state.Set($simpleState.GetAccountKey());
        $state.Set($simpleState.GetAccount());

        $identifiers = @(
            New-ACMEIdentifier "www.example2.com";
            New-ACMEIdentifier "www.example1.com";
        )

        Context 'Mandatory parameters only' {
            $order = New-ACMEOrder $state -Identifiers $identifiers;

            It 'called the ACME service' {
                Assert-VerifiableMock
            }
            It 'sets the nonce in $state' {
                $state.GetNonce() | Should -Be "NextNonce";
            }

            It 'set the first identifier as CertDN' {
                $order.CSROptions.DistinguishedName | Should -Be "CN=www.example2.com";
            }
        }

        Context 'Mandatory parameters and CertDN' {
            $order = New-ACMEOrder $state -Identifiers $identifiers -CertDN "CN=MyTestDN"

            It 'used the certCN for the options' {
                $order.CSROptions.DistinguishedName | Should -Be "CN=MyTestDN";
            }
        }

        Context 'Exceptions' {
            It 'does not accept wrong CertDNs' {
               { New-ACMEOrder $state -Identifiers $identifiers -CertDN "invalid" } | Should -Throw;
            }
        }
    }
}