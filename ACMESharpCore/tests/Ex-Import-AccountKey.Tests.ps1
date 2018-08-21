InModuleScope ACMESharpCore {
    Describe "UnitTesting Import-AccountKey and Export-AccountKey" -Tag "UnitTest" {
        Context "Roundtripping XML" {
            $tempFile = [System.IO.Path]::GetTempFileName() + ".xml";
            $state = New-State;
            
            $accountKey = New-AccountKey;
            $accountKey | Export-AccountKey -Path $tempFile

            $importedKey = Import-AccountKey -State $state -Path $tempFile
         
        }
    }
}
