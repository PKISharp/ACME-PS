BeforeAll {
    . "$PSScriptRoot\ConvertTo-UrlBase64.ps1"
}

Describe 'ConvertTo-UrlBase64' {
    Context 'FromString' {
        It 'should convert a string to URL-safe Base64' {
            $inputString = 'Hello, World!'
            $expectedOutput = 'SGVsbG8sIFdvcmxkIQ'
            $actualOutput = ConvertTo-UrlBase64 -InputText $inputString
            $actualOutput | Should -Be $expectedOutput
        }
    }

    Context 'FromByteArray' {
        It 'should convert a byte array to URL-safe Base64' {
            $inputBytes = [System.Text.Encoding]::UTF8.GetBytes('Hello, World!')
            $expectedOutput = 'SGVsbG8sIFdvcmxkIQ'
            $actualOutput = ConvertTo-UrlBase64 -InputBytes $inputBytes
            $actualOutput | Should -Be $expectedOutput
        }

        It 'replaces + with -' {
            $inputBytes = @(251)
            $expectedOutput = '-w'
            $actualOutput = ConvertTo-UrlBase64 -InputBytes $inputBytes
            $actualOutput | Should -Be $expectedOutput
        }

        It 'replaces / with _' {
            $inputBytes = @(255)
            $expectedOutput = '_w'
            $actualOutput = ConvertTo-UrlBase64 -InputBytes $inputBytes
            $actualOutput | Should -Be $expectedOutput
        }
    }
}