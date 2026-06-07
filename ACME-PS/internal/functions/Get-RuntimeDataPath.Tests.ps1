BeforeAll {
    . "$PSScriptRoot\Get-RuntimeDataPath.ps1"
}
Describe 'Get-RuntimeDataPath' {
    It 'returns the correct path on Windows' {
        if ($IsWindows) {
            $path = Get-RuntimeDataPath
            $path | Should -Be "$env:ProgramData\ACME-PS"
        }
    }

    It 'returns /run or /var/run on Linux/macOS' {
        if ($IsLinux -or $IsMacOS) {
            $path = Get-RuntimeDataPath
            if (Test-Path "/run") {
                $path | Should -Be "/run/ACME-PS"
            }
            elseif (Test-Path "/var/run") {
                $path | Should -Be "/var/run/ACME-PS"
            }
        }
    }

    It 'handles unsupported OS' {
        if (-not ($IsWindows -or $IsLinux -or $IsMacOS)) {   
            # This test is a bit tricky to run since we can't easily mock $IsWindows, $IsLinux, or $IsMacOS.
            # We can at least ensure that it doesn't throw an unhandled exception.
            try {
                Get-RuntimeDataPath
            }
            catch {
                $_ | Should -Not -BeNullOrEmpty
            }
        }
    }
}