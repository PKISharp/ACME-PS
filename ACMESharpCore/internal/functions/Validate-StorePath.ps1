function Validate-StorePath {
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $ACMEStorePath
    )

    process {
        if(Test-Path "$ACMEStorePath/.ACMESharpStore") {
            return;
        }

        throw "$ACMEStorePath is no ACMESharpStore (.ACMESharpStore file is missing).`n" +
            "Call Initialize-Store to create a store."
    }
}