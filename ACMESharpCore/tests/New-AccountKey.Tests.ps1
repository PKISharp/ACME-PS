$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "UnitTesting $CommandName" -Tag "UnitTest" {
    Context "Key-Creation (without export)" {
        It "Creates RSA Keys" {
            $key = New-ACMEAccountKey -SkipKeyExport -WarningAction 'SilentlyContinue'

            $key.JwsAlgorithmName | Should -Be "RS256"
        }

        It "Creates RSA Keys (with non default size)" {
            $key = New-ACMEAccountKey -RSA -RSAHashSize 512 -SkipKeyExport -WarningAction 'SilentlyContinue'

            $key.JwsAlgorithmName | Should -Be "RS512"
        }

        It "Creates ECDsa Keys" {
            $key = New-ACMEAccountKey -ECDsa -SkipKeyExport -WarningAction 'SilentlyContinue'

            $key.JwsAlgorithmName | Should -Be "ES256"
        }

        It "Creates ECDsa Keys (with non default size)" {
            $key = New-ACMEAccountKey -ECDsa -ECDsaHashSize "512" -SkipKeyExport -WarningAction 'SilentlyContinue'

            $key.JwsAlgorithmName | Should -Be "ES512"
        }
    }

    Context "Key-Creation with export" {
        $tempFile = [System.IO.Path]::GetTempFileName();

        AfterEach {
            Remove-Item "$tempFile.*" -Force
        }

        It "Creates and stores Keys (json)" {
            $key = New-ACMEAccountKey -Path "$tempFile.json"

            $key | Should -not -Be $null
            Test-Path "$tempFile.json" | Should -Be $true
        }

        It "Creates and stores Keys (clixml)" {
            $key = New-ACMEAccountKey -Path "$tempFile.xml"

            $key | Should -not -Be $null
            Test-Path "$tempFile.xml" | Should -Be $true
        }
    }
}