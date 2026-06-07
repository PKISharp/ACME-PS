BeforeAll {
    . $PSScriptRoot/AcmeAccount.ps1
}
Describe "AcmeAccount" {
    Context 'Creating an instance of AcmeAccount from Json' {
        It "should create an instance of AcmeAccount" {
            $obj = ConvertFrom-Json -InputObject '{
                "status": "valid",
                "contact": [
                    "mailto:cert-admin@example.org",
                    "mailto:admin@example.org"
                ],
                "termsOfServiceAgreed": true,
                "orders": "https://example.com/acme/orders/rzGoeA"
            }'

            $account = [AcmeAccount]::new($obj, "https://example.com/acme/account/12345")
            $account.ResourceUrl | Should -Be "https://example.com/acme/account/12345"
            $account.Status | Should -Be "valid"
            $account.Contact | Should -Contain "mailto:cert-admin@example.org"
            $account.TermsOfServiceAgreed | Should -Be $true
            $account.Orders | Should -Be "https://example.com/acme/orders/rzGoeA"
        }

        It "should create an instance of AcmeAccount with EAB" {
            $obj = ConvertFrom-Json -InputObject '{
                "status": "valid",
                "contact": [
                    "mailto:cert-admin@example.org",
                    "mailto:admin@example.org"
                ],
                "termsOfServiceAgreed": true,
                "externalAccountBinding": {
                    "kid": "https://example.com/acme/account/12345",
                    "hmacKey": "abcde12345"
                },
                "orders": "https://example.com/acme/orders/rzGoeA"
            }'

            $account = [AcmeAccount]::new($obj, "https://example.com/acme/account/12345")

            $account.ResourceUrl | Should -Be "https://example.com/acme/account/12345"
            $account.Status | Should -Be "valid"
            $account.Contact | Should -Contain "mailto:cert-admin@example.org"
            $account.ExternalAccountBinding | Should -Not -Be $null
        }
    }
}