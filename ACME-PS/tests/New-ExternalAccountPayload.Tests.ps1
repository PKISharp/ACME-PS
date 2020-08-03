InModuleScope "ACME-PS" {
    Describe "UnitTesting New-ExternalAccountPayload" -Tag "UnitTest" {
        $simpleState = Get-State -Path "$PSScriptRoot\states\simple";
        $state = New-State -WarningAction 'SilentlyContinue';

        $state.Set($simpleState.GetServiceDirectory())
        $state.SetNonce($simpleState.GetNonce());
        $state.Set($simpleState.GetAccountKey());

        $result = New-ExternalAccountPayload -State $State `
            -ExternalAccountKID "myKID" -ExternalAccountAlgorithm "HS256" `
            -ExternalAccountMACKey "SLrdl4skg66W0NxZMwwAKPSvDtin-41SCweDRDBxMSSyh5AyoL1mNva6IMhFP13uyOQv5RI40WnnvzyXGlp77w"
        It 'Returns an Object' {
            $result | Should -Not -BeNullOrEmpty;
        }
        It 'Contains protected' {
            $result.ContainsKey("protected") | Should -BeTrue;
        }
        It 'Contains payload' {
            $result.ContainsKey("payload") | Should -BeTrue;
        }
        It 'Contains signature' {
            $result.ContainsKey("signature") | Should -BeTrue;
        }
    }
}