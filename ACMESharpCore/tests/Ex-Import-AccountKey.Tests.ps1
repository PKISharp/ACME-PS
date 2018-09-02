InModuleScope ACMESharpCore {
    Describe "UnitTesting Import-AccountKey and Export-AccountKey" -Tag "UnitTest" {
        Context "Roundtripping XML" {
            $tempFile = [System.IO.Path]::GetTempFileName() + ".xml";
            
            $accountKey = New-AccountKey;
            $accountKey | Export-AccountKey -Path $tempFile

            It 'Created the export file' {
                Test-Path $tempFile | Should -Be $true
            }

            $importedKey = Import-AccountKey -Path $tempFile
            
            It 'Imported the key from the export' {
                $importedKey | Should -not -be $null
            }

            $orgiginalKeySignature = $accountKey.Sign("Test");
            $importedKeySignature = $importedKey.Sign("Test");
            
            It 'signed a test word with the same result.' {
                $importedKeySignature | Should -be $orgiginalKeySignature;
            }
            
            Remove-Item $tempFile;
        }

        Context "Roundtripping JSON" {
            $tempFile = [System.IO.Path]::GetTempFileName() + ".json";

            $accountKey = New-AccountKey;
            $accountKey | Export-AccountKey -Path $tempFile

            It 'Created the export file' {
                Test-Path $tempFile | Should -Be $true
            }

            $importedKey = Import-AccountKey -Path $tempFile
            
            It 'Imported the key from the export' {
                $importedKey | Should -not -be $null
            }

            $orgiginalKeySignature = $accountKey.Sign("Test");
            $importedKeySignature = $importedKey.Sign("Test");
            
            It 'signed a test word with the same result.' {
                $importedKeySignature | Should -be $orgiginalKeySignature;
            }

            Remove-Item $tempFile;
        }
    }
}
