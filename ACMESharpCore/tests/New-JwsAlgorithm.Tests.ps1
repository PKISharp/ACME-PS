$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "UnitTesting $CommandName" -Tag "UnitTest" {
    It "Creates an Algorithm ES256" {
        New-AcmeJwsAlgorithm "ES256" | Should -Not -Be $null
    }
    It "Creates an Algorithm ES384" {
        New-AcmeJwsAlgorithm "ES384" | Should -Not -Be $null
    }
    It "Creates an Algorithm ES512" {
        New-AcmeJwsAlgorithm "ES512" | Should -Not -Be $null
    }
    It "Creates an Algorithm RS256-2048" {
        New-AcmeJwsAlgorithm -JwsAlgorithmName "RS256-2048" | Should -Not -Be $null
    }
    It "Creates an Algorithm RS384-2048" {
        New-AcmeJwsAlgorithm -JwsAlgorithmName "RS384-2048" | Should -Not -Be $null
    }
    It "Creates an Algorithm RS512-2048" {
        New-AcmeJwsAlgorithm -JwsAlgorithmName "RS512-2048" | Should -Not -Be $null
    }
}