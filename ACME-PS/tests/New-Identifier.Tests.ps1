InModuleScope ACME-PS {
    Describe "UnitTesting New-Identifier" -Tag "UnitTest" {
        It "Creates an Identifier (Parameter by Name)" {
            $identifier = New-Identifier -Type "Type" -Value "Value";

            $identifier.Type | Should -Be "Type";
            $identifier.Value | Should -Be "Value";
        }

        It "Creates an Identifier (Parameter by Position)" {
            $identifier = New-Identifier "Value" "Type";

            $identifier.Type | Should -Be "Type";
            $identifier.Value | Should -Be "Value";
        }

        It "Creates an Identifier (Parameter From Pipeline)" {
            $tmp = New-Identifier "Value" "Type";
            $identifier = $tmp | New-Identifier;

            $identifier.Type | Should -Be "Type";
            $identifier.Value | Should -Be "Value";
        }
    }
}