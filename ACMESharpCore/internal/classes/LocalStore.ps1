class LocalStore
{
    static [LocalStore] Load($acmeStateDirectory) {
        return [LocalStore]::new($acmeStateDirectory);
    }

    hidden LocalStore([string] $acmeStateDirectory) {
        Validate-StorePath $acmeStateDirectory;

        $this.StateDirectory = $acmeStateDirectory;
        $this.Directory = Get-ServiceDirectory -ACMEStatePath $acmeStateDirectory;
    }

    hidden [string] $StateDirectory

    [ACMEServiceDirectory] $Directory
}