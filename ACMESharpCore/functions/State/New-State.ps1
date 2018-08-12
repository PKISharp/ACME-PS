function New-State {
    <#
        .SYNOPSIS
            Initializes a new state object.

        .DESCRIPTION
            Initializes a new state object, that will be used by other functions 
            to access the service directory, nonce, account and account key.

        .EXAMPLE
            PS> New-State
    #>
    param(

    )

    process {
        return [AcmeState]::new()
    }
}