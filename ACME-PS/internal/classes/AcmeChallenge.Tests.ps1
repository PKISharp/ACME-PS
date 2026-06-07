BeforeAll {
    . $PSScriptRoot/AcmeIdentifier.ps1
    . $PSScriptRoot/AcmeChallenge.ps1
}
Describe "AcmeChallenge" {
    Context 'Creating an instance of AcmeChallenge from Json' {
        BeforeAll {
            $obj = ConvertFrom-Json -InputObject '{
                "type": "http-01",
                "url": "https://example.com/acme/challenge/12345",
                "token": "abcde12345",
                "status": "pending",
                "error": null
            }'
        }

        It "should create an instance of AcmeChallenge" {
            $challenge = [AcmeChallenge]::new($obj)

            $challenge.Type | Should -Be "http-01"
            $challenge.Url | Should -Be "https://example.com/acme/challenge/12345"
            $challenge.Token | Should -Be "abcde12345"
            $challenge.Status | Should -Be "pending"
            $challenge.Error | Should -Be $null
        }
    }
}