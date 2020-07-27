InModuleScope ACME-PS {
    Describe "UnitTesting New-ACMENonce" -Tag "UnitTest" {
        $simpleState = Get-ACMEState -Path "$PSScriptRoot\states\simple";
        $state = New-ACMEState -WarningAction 'SilentlyContinue';

        $state.Set($simpleState.GetServiceDirectory())

        Mock Invoke-AcmeWebRequest {
            $mockResult = [AcmeHttpResponse]::new();
            $mockResult.NextNonce = "MyNewNonce";
            return  $mockResult;
        } -Verifiable -ParameterFilter {
            $Url -eq $state.GetServiceDirectory().NewNonce -and
            $Method -eq "HEAD"
        }

        $nonce = New-ACMENonce -State $state -PassThru;

        It 'called the ACME service' {
            Assert-VerifiableMock
        }

        It 'passes through the nonce' {
            $nonce | Should -Be "MyNewNonce";
        }

        It 'sets the nonce in $state' {
            $state.GetNonce() | Should -Be "MyNewNonce";
        }
    }
}