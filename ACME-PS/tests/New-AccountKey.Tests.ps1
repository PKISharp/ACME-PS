InModuleScope ACME-PS {
    Describe "UnitTesting New-AccountKey" -Tag "UnitTest" {
        Context "Key-Creation" {
            It "Creates RSA Keys" {
                $key = New-ACMEAccountKey
                $key.JwsAlgorithmName() | Should -Be "RS256"
            }

            It "Creates RSA Keys (with non default size)" {
                $key = New-ACMEAccountKey -RSA -RSAHashSize 512
                $key.JwsAlgorithmName() | Should -Be "RS512"
            }

            It "Creates ECDsa Keys" {
                $key = New-ACMEAccountKey -ECDsa
                $key.JwsAlgorithmName() | Should -Be "ES256"
            }

            It "Creates ECDsa Keys (with non default size)" {
                $key = New-ACMEAccountKey -ECDsa -ECDsaHashSize "512"
                $key.JwsAlgorithmName() | Should -Be "ES512"
            }
        }

        Context "Key-Creation with state" {
            $state = Get-State -Path $PSScriptRoot\states\simple
            $state.AutoSave = $false;

            It "Creates and stores Key the key to state" {
                $key = New-ACMEAccountKey -State $state -PassThru -WarningAction 'SilentlyContinue'

                $key | Should -not -Be $null
                $key | Should -Be $state.GetAccountKey()
            }
        }
    }
}