function Validate-StorePath {
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $ACMEStoreDir
    )

    process {
        if(Test-Path "$ACMEStoreDir/.ACMESharpStore") {
            return;
        }

        throw "$ACMEStoreDir is no ACMESharpStore (.ACMESharpStore file is missing).`n" +
            "Call Initialize-Store to create a store."
    }
}