InModuleScope ACME-PS {
    Describe 'Checking Documentation for Completeness' {
        $module = Get-Module "ACME-PS";
        
        $defaultParameters = @("Verbose","Debug",
            "ErrorAction","WarningAction","InformationAction",
            "ErrorVariable","WarningVariable","InformationVariable",
            "OutVariable","OutBuffer","PipelineVariable",
            "WhatIf","Confirm");

        foreach($cmdName in $module.ExportedCommands.Keys) {
            $cmd = $module.ExportedCommands[$cmdName];

            Context "$($cmd.Name) documentation should be complete" {
                $cmdParameters = $cmd.Parameters.Keys | Where-Object { $_ -NotIn $defaultParameters }
                
                $cmdHelp = Get-Help $cmd;
                $cmdHelpParameters = $cmdHelp.Parameters.parameter | 
                    Where-Object { $_.description } | Select-Object -ExpandProperty name

                It 'has synopsis' {
                    $cmdHelp.Synopsis | Should -Be $true
                }
                It 'has description' {
                    $cmdHelp.Description | Should -Be $true
                }
                It 'has examples' {
                    $cmdHelp.Examples.Example.Count | Should -Not -Be 0
                }

                It 'property and help counts are equal' {
                    $cmdHelpParameters.Count | Should -Be $cmdParameters.Count
                }

                foreach($p in $cmdParameters) {
                    It "-$p documentation exists" {
                        $cmdHelpParameters | Should -Contain $p
                    }
                }
            }
            
        } 
    }
}