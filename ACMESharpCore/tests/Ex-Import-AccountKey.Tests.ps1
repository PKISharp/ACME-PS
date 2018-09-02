InModuleScope ACMESharpCore {
    Describe "UnitTesting Import-AccountKey and Export-AccountKey" -Tag "UnitTest" {
        Context "Roundtripping XML" {
            $tempFile = [System.IO.Path]::GetTempFileName() + ".xml";
            $state = New-State;
            
            $accountKey = New-AccountKey;
            $accountKey | Export-AccountKey -Path $tempFile

            $importedKey = Import-AccountKey -State $state -Path $tempFile
            
            $orgiginalKeySignature = $accountKey.Sign("Test");
            $importedKeySignature = $importedKey.Sign("Test");
            
            $importedKeySignature | Should -be $orgiginalKeySignature;

            Remove-Item $tempFile;
        }

        Context "Roundtripping JSON" {
            $tempFile = [System.IO.Path]::GetTempFileName() + ".json";
            $state = New-State;
            
            $accountKey = New-AccountKey;
            $accountKey | Export-AccountKey -Path $tempFile

            $importedKey = Import-AccountKey -State $state -Path $tempFile
            
            $orgiginalKeySignature = $accountKey.Sign("Test");
            $importedKeySignature = $importedKey.Sign("Test");
            
            $importedKeySignature | Should -be $orgiginalKeySignature;

            Remove-Item $tempFile;
        }
    }
}
