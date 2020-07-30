InModuleScope ACME-PS {
    Describe "UnitTesting New-Order" -Tag "UnitTest" {
        Mock Invoke-AcmeWebRequest {
            $mockResult = [AcmeHttpResponse]::new();
            $mockResult.NextNonce = "NextNonce";
            return  $mockResult;
        } -Verifiable -ParameterFilter {
            $Url -eq $state.GetServiceDirectory().NewOrder -and
            $Method -eq "POST"
        }

        $simpleState = Get-State -Path "$PSScriptRoot\states\simple";
        $state = New-State -WarningAction 'SilentlyContinue';

        $state.Set($simpleState.GetServiceDirectory())
        $state.SetNonce($simpleState.GetNonce());
        $state.Set($simpleState.GetAccountKey());
        $state.Set($simpleState.GetAccount());

        $identifiers = @(
            New-Identifier "www.example2.com";
            New-Identifier "www.example1.com";
        )

        Context 'Mandatory parameters only' {
            $order = New-Order $state -Identifiers $identifiers;

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
            $order = New-Order $state -Identifiers $identifiers -CertDN "CN=MyTestDN"

            It 'used the certCN for the options' {
                $order.CSROptions.DistinguishedName | Should -Be "CN=MyTestDN";
            }
        }

        Context 'Exceptions' {
            It 'does not accept wrong CertDNs' {
               { New-Order $state -Identifiers $identifiers -CertDN "invalid" } | Should -Throw;
            }
        }
    }
}