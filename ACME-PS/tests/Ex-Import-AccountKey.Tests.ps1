InModuleScope ACME-PS {
    Describe "UnitTesting Import-ACMEAccountKey and Export-ACMEAccountKey" -Tag "UnitTest" {
        Context "Roundtripping XML" {
            $tempFile = [System.IO.Path]::GetTempFileName() + ".xml";

            $accountKey = New-ACMEAccountKey;
            $accountKey | Export-ACMEAccountKey -Path $tempFile

            It 'Created the export file' {
                Test-Path $tempFile | Should -Be $true
            }

            $importedKey = Import-ACMEAccountKey -Path $tempFile

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

            $accountKey = New-ACMEAccountKey;
            $accountKey | Export-ACMEAccountKey -Path $tempFile

            It 'Created the export file' {
                Test-Path $tempFile | Should -Be $true
            }

            $importedKey = Import-ACMEAccountKey -Path $tempFile

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
