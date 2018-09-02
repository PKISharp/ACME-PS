InModuleScope ACMESharpCore {
    Describe "UnitTesting Import-AccountKey and Export-AccountKey" -Tag "UnitTest" {
        Context "Roundtripping XML" {
            $tempFile = [System.IO.Path]::GetTempFileName() + ".xml";
            
            $accountKey = New-AccountKey;
            $accountKey | Export-AccountKey -Path $tempFile

            $importedKey = Import-AccountKey -Path $tempFile
            
            $orgiginalKeySignature = $accountKey.Sign("Test");
            $importedKeySignature = $importedKey.Sign("Test");
            
            $importedKeySignature | Should -be $orgiginalKeySignature;

            Remove-Item $tempFile;
        }

        Context "Roundtripping JSON" {
            $tempFile = [System.IO.Path]::GetTempFileName() + ".json";

            $accountKey = New-AccountKey;
            $accountKey | Export-AccountKey -Path $tempFile

            $importedKey = Import-AccountKey -Path $tempFile
            
            $orgiginalKeySignature = $accountKey.Sign("Test");
            $importedKeySignature = $importedKey.Sign("Test");
            
            $importedKeySignature | Should -be $orgiginalKeySignature;

            Remove-Item $tempFile;
        }
    }
}
