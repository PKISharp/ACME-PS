function Test-Something {
    param(
        [string] $text = [datetime]::Now.ToString()
    )
    Write-Warning $text;
}