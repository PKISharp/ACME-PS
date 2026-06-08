BeforeAll {
    get-content $PSScriptRoot/../../internal/classes/Classes.txt | ForEach-Object { . "$PSScriptRoot/../../internal/classes/$_" }
    get-item $PSScriptRoot/../../internal/functions/*.ps1 | ForEach-Object { . $_.FullName }
    . $PSScriptRoot/Get-ServiceDirectory.ps1

    $env:ACME_PS_RUNTIME_DATA_PATH = [IO.Path]::Combine([IO.Path]::GetTempPath(), "ACME_PS_Runtime_Data");
}
AfterAll {
    Remove-Item -Path $env:ACME_PS_RUNTIME_DATA_PATH -Recurse -Force
    Remove-Item -Path env:ACME_PS_RUNTIME_DATA_PATH
}
Describe "Get-ServiceDirectory" {
    Context "Retrieving the service directory from a URL" {
        BeforeAll {
            # Mock the Invoke-WebRequest to return a predefined JSON response
            $jsonResponse = '{
                "newNonce": "https://example.com/acme/new-nonce",
                "newAccount": "https://example.com/acme/new-account",
                "newOrder": "https://example.com/acme/new-order",
                "newAuthz": "https://example.com/acme/new-authz",
                "revokeCert": "https://example.com/acme/revoke-cert",
                "keyChange": "https://example.com/acme/key-change",
                "meta": {
                    "termsOfService": "https://example.com/acme/terms/2017-5-30",
                    "website": "https://www.example.com/",
                    "caaIdentities": ["example.com"],
                    "externalAccountRequired": false
                }
            }'

            $mockResponse = [PSCustomObject]@{
                Content = $jsonResponse
            }
        }

        It "should retrieve the service directory and return an AcmeDirectory object" {
            Mock -CommandName Invoke-WebRequest -MockWith { return $mockResponse }

            $directoryUrl = "https://example.com/acme/directory"
            $result = Get-ServiceDirectory -DirectoryUrl $directoryUrl -InMemory

            Should -Invoke Invoke-WebRequest

            $result | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be "AcmeDirectory"
            $result.ResourceUrl | Should -Be $directoryUrl
            $result.NewAccount | Should -Be "https://example.com/acme/new-account"
        }

        It "should save the service directory to disk when not using -InMemory" {
            Mock -CommandName Invoke-WebRequest -MockWith { return $mockResponse } -Verifiable

            $directoryUrl = "https://example.com/acme/directory"
            $directoryPath = $env:ACME_PS_RUNTIME_DATA_PATH + "\_directory.json"

            Get-ServiceDirectory -DirectoryUrl $directoryUrl -FilePath $directoryPath

            Test-Path -Path $directoryPath | Should -BeTrue
            Should -Invoke Invoke-WebRequest
        }

        It "should load the service directory from disk when not using a path" {
            Mock -CommandName Invoke-WebRequest -MockWith { return $mockResponse } -Verifiable

            $directoryUrl = "https://example.com/acme/directory"
            $directoryPath = $env:ACME_PS_RUNTIME_DATA_PATH + "\_directory.json"

            $directoryObject = [AcmeDirectory]::new((ConvertFrom-Json $jsonResponse), $directoryUrl);
            $directoryObject.ToJson() > $directoryPath;

            $result = Get-ServiceDirectory 
            $result | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be "AcmeDirectory"
            $result.ResourceUrl | Should -Be $directoryUrl

            Should -not -Invoke Invoke-WebRequest
        }
    }
}