<#
.SYNOPSIS
    Returns the OS-appropriate runtime data directory.
.DESCRIPTION
    - On Windows: returns $env:ProgramData
    - On Linux/macOS: returns /run if it exists, otherwise /var/run
#>
function Get-RuntimeDataPath {
    try {
        if ($IsWindows) {
            return "$env:ProgramData\ACME-PS"
        }
        elseif ($IsLinux -or $IsMacOS) {
            # Linux/macOS: Prefer /run, fallback to /var/run
            if (Test-Path "/run") {
                return "/run/ACME-PS"
            }
            elseif (Test-Path "/var/run") {
                return "/var/run/ACME-PS"
            }
            else {
                throw "No suitable runtime directory found."
            }
        }
        else {
            throw "Unsupported operating system."
        }
    }
    catch {
        Write-Error "Error determining runtime data path: $_"
        return $null
    }
}
