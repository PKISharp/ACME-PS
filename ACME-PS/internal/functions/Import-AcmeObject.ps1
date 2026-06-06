# TODO: Typename is not mandatory, but if it's not provided, the downstream convert function _will_ fail.
# Also this function can be replaced by ctors in the ACMEOrder and ACMEAccount classes.
function Import-AcmeObject {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_})]
        [string]
        $Path,

        [Parameter()]
        [string]
        $TypeName,

        [Parameter()]
        [switch]
        $AsPSCustomObject
    )

    process {
        $ErrorActionPreference = 'Stop'

        if($Path -like "*.json") {
            Write-Verbose "Importing object from JSON file $Path"
            $imported = Get-Content $Path -Raw | ConvertFrom-Json;
        } else {
            Write-Verbose "Importing object from CLIXML file $Path"
            $imported = Import-Clixml $Path;
        }

        if($AsPSCustomObject.IsPresent) {
            return $imported;
        }

        if($TypeName) {
            $result = $imported -as ([type]$TypeName)
        } else {
            # TODO: Typename is mandatory, so this can probably be removed.
            $result = $imported | ConvertTo-OriginalType
        }

        return $result;
    }
}
