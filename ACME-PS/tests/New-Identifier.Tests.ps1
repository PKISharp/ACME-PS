InModuleScope ACME-PS {
    Describe "UnitTesting New-ACMEIdentifier" -Tag "UnitTest" {
        It "Creates an Identifier (Parameter by Name)" {
            $identifier = New-ACMEIdentifier -Type "Type" -Value "Value";

            $identifier.Type | Should -Be "Type";
            $identifier.Value | Should -Be "Value";
        }

        It "Creates an Identifier (Parameter by Position)" {
            $identifier = New-ACMEIdentifier "Value" "Type";

            $identifier.Type | Should -Be "Type";
            $identifier.Value | Should -Be "Value";
        }

        It "Creates an Identifier (Parameter From Pipeline)" {
            $tmp = New-ACMEIdentifier "Value" "Type";
            $identifier = $tmp | New-ACMEIdentifier;

            $identifier.Type | Should -Be "Type";
            $identifier.Value | Should -Be "Value";
        }
    }
}