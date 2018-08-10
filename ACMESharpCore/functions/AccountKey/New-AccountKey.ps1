function New-AccountKey {
    <#
        .SYNOPSIS
            Creates a new account key, that can will used to sign ACME operations. 
            Provide a path where to save the key, since being able to restore it is crucial.
        
        .DESCRIPTION
            Creates and stores a new account key, that can be used for ACME operations.
            The key will first be created, than exported and imported again to make sure, it has been saved.
            You can skip the export by providing the SkipExport switch.


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

        .PARAMETER ExportType
            Choose if you want to export CLIXML (default) or JSON.

        .PARAMETER AutomaticAccountKeyHandling
            If set, the module will be initialized to automatically provide the account key, where neccessary.

        
        .EXAMPLE
            PS> New-AccountKey -Path C:\myKeyExport.xml -AutomaticAccountKeyHandling

        .EXAMPLE
            PS> New-AccountKey -Path C:\myKeyExport.json -RSA -HashSize 512

        .EXAMPLE
            PS> New-AccountKey -ECDsa -HashSize 384 -SkipExport
    #>
    [CmdletBinding(DefaultParameterSetName="RSA")]
    [OutputType("ACMESharpCore.Crypto.IAccountKey")]
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


        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $AutomaticAccountKeyHandling,

        [Parameter()]
        [switch]
        $SkipKeyExport
    )

    if(-not $SkipKeyExport) {
        if(-not $Path) {
            Write-Error "Path was null or empty. Provide a path for the key to be exported or specify SkipKeyExport";
            return;
        }
    }

    if($PSCmdlet.ParameterSetName -eq "ECDsa") {
        $accountKey = [IAccountKey]([ECDsaAccountKey]::new($ECDsaHashSize));
        Write-Verbose "Created new ECDsa account key with hash size $ECDsaHashSize";
    } else {
        $accountKey = [IAccountKey]([RSAAccountKey]::new($RSAHashSize, $RSAKeySize));
        Write-Verbose "Created new RSA account key with hash size $RSAHashSize and key size $RSAKeySize";
    }

    if($SkipKeyExport) {
        Write-Warning "The account key will not be exported. Make sure you save the account key or you might loose access to your ACME account.";
        
        if($AutomaticAccountKeyHandling) {
            Enable-AccountKeyHandling $accountKey;            
        }

        return $accountKey;
    }

    Export-AccountKey -AccountKey $accountKey -Path $Path -ErrorAction 'Stop' | Out-Null
    return Import-AccountKey -Path $Path -AutomaticAccountKeyHandling:$AutomaticAccountKeyHandling -ErrorAction 'Stop'
}