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

            Context "$($cmd.Name) documents all properties" {
                $cmdParameters = $cmd.Parameters.Keys | Where-Object { $_ -NotIn $defaultParameters }
                
                $cmdHelp = Get-Help $cmd;
                $cmdHelpParameters = $cmdHelp.Parameters.parameter | 
                    Where-Object { $_.description } | Select-Object -ExpandProperty name

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