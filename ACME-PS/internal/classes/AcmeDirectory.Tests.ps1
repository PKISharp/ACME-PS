BeforeAll {
    . $PSScriptRoot/AcmeDirectory.ps1
}
Describe "AcmeDirectory" {
    Context 'Creating an instance of AcmeDirectory from Json' {
        BeforeAll {
            $obj = ConvertFrom-Json -InputObject '{
                "newNonce": "https://example.com/acme/new-nonce",
                "newAccount": "https://example.com/acme/new-account",
                "newOrder": "https://example.com/acme/new-order",
                "newAuthz": "https://example.com/acme/new-authz",
                "revokeCert": "https://example.com/acme/revoke-cert",
                "keyChange": "https://example.com/acme/key-change",
                "meta": {
                    "termsOfService": "https://example.com/acme/terms/2017-5-30",
                    "website": "https://www.example.com/",
                    "caaIdentities": ["example.com"],
                    "externalAccountRequired": false
                }
            }'
        }

        It "should create an instance of AcmeDirectory" {
            $directory = [AcmeDirectory]::new($obj, "https://example.com/acme/")

            $directory.ResourceUrl | Should -Be "https://example.com/acme/"
            $directory.NewAccount | Should -Be "https://example.com/acme/new-account"
            $directory.NewAuthz | Should -Be "https://example.com/acme/new-authz"
            $directory.NewNonce | Should -Be "https://example.com/acme/new-nonce"
            $directory.NewOrder | Should -Be "https://example.com/acme/new-order"
            $directory.KeyChange | Should -Be "https://example.com/acme/key-change"
            $directory.RevokeCert | Should -Be "https://example.com/acme/revoke-cert"

            $directory.Meta.CaaIdentities | Should -Contain "example.com"
            $directory.Meta.TermsOfService | Should -Be "https://example.com/acme/terms/2017-5-30"
            $directory.Meta.Website | Should -Be "https://www.example.com/"
            $directory.Meta.ExternalAccountRequired | Should -Be $false
        }

        It 'should convert the directory back to json' {
            $directory = [AcmeDirectory]::new($obj, "https://example.com/acme/")
            $json = $directory.ToJson() | ConvertFrom-Json

            $json.resourceUrl | Should -Be "https://example.com/acme/"
            $json.newAccount | Should -Be "https://example.com/acme/new-account"
            $json.newAuthz | Should -Be "https://example.com/acme/new-authz"
            $json.newNonce | Should -Be "https://example.com/acme/new-nonce"
            $json.newOrder | Should -Be "https://example.com/acme/new-order"
            $json.keyChange | Should -Be "https://example.com/acme/key-change"
            $json.revokeCert | Should -Be "https://example.com/acme/revoke-cert"

            $json.meta.caaIdentities | Should -Contain "example.com"
            $json.meta.termsOfService | Should -Be "https://example.com/acme/terms/2017-5-30"
            $json.meta.website | Should -Be "https://www.example.com/"
            $json.meta.externalAccountRequired | Should -Be $false
        }
    }

    
}