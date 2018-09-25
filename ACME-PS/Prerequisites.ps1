if($PSEdition -eq "Desktop") {
    <# Check if .NET v 4.7.2 is available #>
    $isGeqNET472 = @(Get-ChildItem "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" | Get-ItemPropertyValue -Name Release | ForEach-Object { $_ -ge 461808 })
    if(-not ($isGeqNET472 -contains $true)) {
        throw "This module needs at least .NET 4.7.2 to work correctly!"
    }
}