InModuleScope ACMESharpCore {
    Describe "UnitTesting New-Nonce" -Tag "UnitTest" {
        Mock Invoke-AcmeWebRequest { 
            $mockResult = [AcmeHttpResponse]::new();
            $mockResult.NextNonce = "MyNewNonce";
            return  $mockResult;
        } -Verifiable -ParameterFilter { 
            $Url -eq $state.GetServiceDirectory().NewNonce -and 
            $Method -eq "HEAD"
        }
        
        $state = Get-State -Path $PSScriptRoot\states\simple
        $state.AutoSave = $false;   

        $nonce = New-Nonce $state -PassThru;

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