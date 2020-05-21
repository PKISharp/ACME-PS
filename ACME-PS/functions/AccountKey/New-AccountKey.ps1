function New-AccountKey {
    <#
        .SYNOPSIS
            Creates a new account key, that will be used to sign ACME operations.
            Provide a path where to save the key, since being able to restore it is crucial.

        .DESCRIPTION
            Creates and stores a new account key, that can be used for ACME operations.
            The key will be added to the state.


        .PARAMETER RSA
            Used to select RSA key type. (default)

        .PARAMETER RSAHashSize
            The hash size used for the RSA algorithm.

        .PARAMETER RSAKeySize
            The key size of the RSA algorithm.


        .PARAMETER ECDsa
            Used to select ECDsa key type.

        .PARAMETER ECDsaHashSize
            The hash size used for the ECDsa algorithm.


        .PARAMETER Path
            The path where the keys will be stored.


        .PARAMETER State
            The state object, that is used in this module, to provide easy access to the ACME service directory,
            your account key, the associated account and the replay nonce.
            The account key will be stored into the state, if present.

        .PARAMETER PassThru
            Forces the new account key to be returned to the pipeline, even if state is set.

        .PARAMETER Force
            If there's already a key present in the state, you need to provide the force switch to override the
            existing account key.

        .EXAMPLE
            PS> New-AccountKey -State $myState

        .EXAMPLE
            PS> New-AccountKey -State $myState -RSA -HashSize 512

        .EXAMPLE
            PS> New-AccountKey -ECDsa -HashSize 384
    #>
    [CmdletBinding(DefaultParameterSetName="RSA", SupportsShouldProcess=$true)]
    [OutputType("IAccountKey")]
    param(
        [Parameter(ParameterSetName="RSA")]
        [switch]
        $RSA,

        [Parameter(ParameterSetName="RSA")]
        [ValidateSet(256, 384, 512)]
        [int]
        $RSAHashSize = 256,

        [Parameter(ParameterSetName="RSA")]
        [ValidateSet(2048)]
        [int]
        $RSAKeySize = 2048,


        [Parameter(ParameterSetName="ECDsa")]
        [switch]
        $ECDsa,

        [Parameter(ParameterSetName="ECDsa")]
        [ValidateSet(256, 384, 512)]
        [int]
        $ECDsaHashSize = 256,

        [Parameter(Position = 0)]
        [ValidateNotNull()]
        [AcmeState]
        $State,

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter()]
        [switch]
        $Force
    )

    if($PSCmdlet.ParameterSetName -eq "ECDsa") {
        $accountKey = [IAccountKey]([ECDsaAccountKey]::new($ECDsaHashSize));
        Write-Verbose "Created new ECDsa account key with hash size $ECDsaHashSize";
    } else {
        $accountKey = [IAccountKey]([RSAAccountKey]::new($RSAHashSize, $RSAKeySize));
        Write-Verbose "Created new RSA account key with hash size $RSAHashSize and key size $RSAKeySize";
    }

    if($State -and $PSCmdlet.ShouldProcess("AccountKey", "Add created account key to state.",
        "The created account key will now be added to the state object."))
    {
        if($null -eq $State.GetAccountKey() -or $Force -or
            $PSCmdlet.ShouldContinue("The existing account key will be overriden. Do you want to continue?", "Replace account key"))
        {
            $State.Set($accountKey);
        }
    }

    if($PassThru -or -not $State) {
        return $accountKey;
    }
}
