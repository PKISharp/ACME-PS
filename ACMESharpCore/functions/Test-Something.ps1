function Test-Something {
    param(
        [string] $text = [datetime]::Now.ToString()
    )
    Write-Warning $text;

    https://acme-staging-v02.api.letsencrypt.org/acme/order/6601617/5540231
}