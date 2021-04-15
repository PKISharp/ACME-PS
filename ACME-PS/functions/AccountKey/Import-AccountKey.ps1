function Import-AccountKey {
    <#
        .SYNOPSIS
            Imports an exported account key.

        .DESCRIPTION
            Imports an account key that has been exported with Export-AccountKey. If requested, the key is registered for automatic key handling.


        .PARAMETER Path
            The path where the key has been exported to.

        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.

        .PARAMETER PassThru
            If set, the account key will be returned to the pipeline.


        .EXAMPLE
            PS> Import-AccountKey -State $myState -Path C:\AcmeTemp\AccountKey.xml
    #>
    param(
        # Specifies a path to one or more locations.
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(Position = 0)]
        [ValidateNotNull()]
        [AcmeState]
        $State,

        [Parameter()]
        [switch]
        $PassThru
    )

    process {
        $ErrorActionPreference = 'Stop';

        $imported = Import-AcmeObject $Path -AsPSCustomObject;

        $accountKey = [AcmePSKey]::new($imported);
        if($State) {
            $State.Set($accountKey);
        }

        if($PassThru -or -not $State) {
            return $accountKey;
        }
    }
}
