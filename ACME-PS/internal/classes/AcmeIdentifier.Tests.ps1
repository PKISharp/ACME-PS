BeforeAll {
    . $PSScriptRoot/AcmeIdentifier.ps1
}

Describe "AcmeIdentifier" {
    It "should create an instance of AcmeIdentifier with type and value" {
        $identifier = [AcmeIdentifier]::new("ip", "127.0.0.1")

        $identifier.Type | Should -Be "ip"
        $identifier.Value | Should -Be "127.0.0.1"
    }

    It "should create an instance of AcmeIdentifier with value only" {
        $identifier = [AcmeIdentifier]::new("example.com")

        $identifier.Type | Should -Be "dns"
        $identifier.Value | Should -Be "example.com"
    }

    It "should parse a text value into an AcmeIdentifier" {
        $identifier = [AcmeIdentifier]::Parse("dns:example.com")

        $identifier.Type | Should -Be "dns"
        $identifier.Value | Should -Be "example.com"
    }

    It "should return a string representation of the identifier" {
        $identifier = [AcmeIdentifier]::new("dns", "example.com")

        $identifier.ToString() | Should -Be "dns:example.com"
    }

    It "should convert the identifier to json" {
        $identifier = [AcmeIdentifier]::new("dns", "example.com")

        $json = $identifier.ToJson() | ConvertFrom-Json

        $json.Type | Should -Be "dns"
        $json.Value | Should -Be "example.com"
    }
}