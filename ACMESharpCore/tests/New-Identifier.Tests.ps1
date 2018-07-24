$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")

Describe "UnitTesting $CommandName" -Tag "UnitTest" {
    It "Creates an Identifier (Parameter by Name)" {
        $identifier = New-AcmeIdentifier -Type "Type" -Value "Value";

        $identifier.Type | Should -Be "Type";
        $identifier.Value | Should -Be "Value";
    }

    It "Creates an Identifier (Parameter by Position)" {
        $identifier = New-AcmeIdentifier "Type" "Value";

        $identifier.Type | Should -Be "Type";
        $identifier.Value | Should -Be "Value";
    }

    It "Creates an Identifier (Parameter From Pipeline)" {
        $tmp = New-AcmeIdentifier "Type" "Value";
        $identifier = $tmp | New-AcmeIdentifier;

        $identifier.Type | Should -Be "Type";
        $identifier.Value | Should -Be "Value";
    }
}