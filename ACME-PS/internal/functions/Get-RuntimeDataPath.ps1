<#
.SYNOPSIS
    Returns the content of $env:ACME_PS_RUNTIME_DATA_PATH if set, otherwise the OS-appropriate runtime data directory.
.DESCRIPTION
    - If $env:ACME_PS_RUNTIME_DATA_PATH is set, returns its value.
    - On Windows: returns $env:ProgramData
    - On Linux/macOS: returns /run if it exists, otherwise /var/run
#>
function Get-RuntimeDataPath {
    if ($env:ACME_PS_RUNTIME_DATA_PATH) {
        return $env:ACME_PS_RUNTIME_DATA_PATH
    }

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
