InModuleScope ACMESharpCore {
    Describe "UnitTesting Import-AccountKey and Export-AccountKey" -Tag "UnitTest" {
        It "Roundtripped XML File will correctly sign data" {
            $tempFile = [System.IO.Path]::GetTempFileName() + ".xml";
            
            $accountKey = New-AccountKey;
            $accountKey | Export-AccountKey -Path $tempFile

            $importedKey = Import-AccountKey -Path $tempFile
            
            $orgiginalKeySignature = $accountKey.Sign("Test");
            $importedKeySignature = $importedKey.Sign("Test");
            
            $importedKeySignature | Should -be $orgiginalKeySignature;
            
            Remove-Item $tempFile;
        }

        It "Roundtripped JSON File will correctly sign data" {
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
