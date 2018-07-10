class LocalStore
{
    [LocalStore] Create([string] $acmeStateDirectory, [ACMESharp.Protocol.Resources.ServiceDirectory] $directory, [string] $jwsAlgorithm)
    {
        if(Test-Path "$acmeStateDirectory/*") {
            throw "Initializing the store can only be done on a non exitent or empty directory.";
        }

        if(!(Test-Path $acmeStateDirectory)) {
            Write-Verbose "$acmeStateDirectory did not exist. It will be created now.";
            New-Item "$acmeStateDirectory" -ItemType Directory;
        }
        
        $directory.Directory | Out-File "$acmeStateDirectory/.ACMESharpStore" -Encoding ASCII;
        Export-Clixml "$acmeStateDirectory/ServiceDirectory.xml" -InputObject $directory;

        $jwsTool = [ACMESharp.Crypto.JOSE.JwsTool]::new($jwsAlgorithm);
        Export-Clixml "$acmeStateDirectory/AccountKey.xml" -InputObject ($jwsTool.Export());

        return [LocalStore]::new($acmeStateDirectory);
    }

    static [LocalStore] Load([string] $acmeStateDirectory) 
    {
        return [LocalStore]::new($acmeStateDirectory);
    }

    hidden LocalStore([string] $acmeStateDirectory) 
    {
        Test-Store $acmeStateDirectory;

        $this.Path = $acmeStateDirectory;

        this.DirectoryUri = Get-Content "$($this.Path)/.ACMESharpStore";

        $this.Directory = Import-Clixml -Path "$($this.Path)/ServiceDirectory.xml";
        $this.AccountKey = Import-Clixml -Path "$($this.Path)/AccountKey.xml";
    }

    hidden [string] $Path;

    [ACMESharp.Protocol.Resources.ServiceDirectory] $Directory;
    [ACMESharp.Crypto.JOSE.JwsExport] $AccountKey;
    [ACMESharp.Protocol.Resources]
}