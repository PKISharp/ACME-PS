BeforeAll {
    . "$PSScriptRoot\ConvertFrom-UrlBase64.ps1"
}

Describe 'ConvertFrom-UrlBase64' {
    It 'should convert a URL-safe Base64 to a byte array' {
        $inputString = 'SGVsbG8sIFdvcmxkIQ'
        $expectedOutput = [System.Text.Encoding]::UTF8.GetBytes('Hello, World!')
        $actualOutput = ConvertFrom-UrlBase64 -InputText $inputString
        $actualOutput | Should -Be $expectedOutput
    }

    It 'handles missing padding and - correctly' {
        $inputString = "-w"
        $expectedOutput = @(251)
        $actualOutput = ConvertFrom-UrlBase64 -InputText $inputString
        $actualOutput | Should -Be $expectedOutput
    }

    It 'handles missing padding and _ correctly' {
        $inputString = "_w"
        $expectedOutput = @(255)
        $actualOutput = ConvertFrom-UrlBase64 -InputText $inputString
        $actualOutput | Should -Be $expectedOutput
    }
}