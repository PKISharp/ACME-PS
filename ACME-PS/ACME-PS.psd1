@{
	RootModule = 'ACME-PS.psm1'
	ModuleVersion = '1.0.3'
	GUID = '2DBF7E3F-F830-403A-9300-78A11C7CD00C'

	CompatiblePSEditions = @("Core", "Desktop")
	PowershellVersion = "5.1"

	Author = 'https://github.com/PKISharp/ACMESharpCore-PowerShell/graphs/contributors'
	CompanyName = 'https://github.com/PKISharp'
	Copyright = '(c) 2018 Thomas Glatzer, Eugene Bekker. All rights reserved.'

	Description = "PowerShell client module for the ACME protocol Version 2"

	NestedModules = @(
		"./Prerequisites.ps1",
		"./TypeDefinitions.ps1"
	)

	RequiredAssemblies = @(
		'System.Net.Http'
	)

	DefaultCommandPrefix = 'ACME'
	FunctionsToExport = @(
		"Find-Account",
		"Get-Account",
		"New-Account",
		"Set-Account",

		"Export-AccountKey",
		"Import-AccountKey",
		"New-AccountKey",

		"Get-Authorization",

		"Export-Certificate",

		"Export-CertificateKey",
		"Import-CertificateKey",
		"New-CertificateKey",

		"Complete-Challenge",
		"Get-Challenge",
		"Initialize-Challenge",

		"Get-Nonce",
		"New-Nonce",

		"Complete-Order",
		"Get-Order",
		"New-Identifier",
		"New-Order",
		"Update-Order"

		"Get-ServiceDirectory",
		"Get-TermsOfService",

		"Get-State",
		"New-State"
	)

	# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		PSData = @{

			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @('pki','ssl','tls','security','certificates','letsencrypt','acme','powershell','acmesharp')

			# A URL to the license for this module.
			LicenseUri = 'https://raw.githubusercontent.com/PKISharp/ACMESharpCore-PowerShell/master/LICENSE'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/PKISharp/ACMESharpCore-PowerShell'

			# A URL to an icon representing this module.
			IconUri = 'https://raw.githubusercontent.com/PKISharp/ACMESharpCore/master/docs/acmesharp-logo-color.png'

			# ReleaseNotes of this module
			ReleaseNotes = 'Please see the release notes from the release distribution page: https://github.com/PKISharp/ACMESharpCore-PowerShell/releases'
		} # End of PSData hashtable

	} # End of PrivateData hashtable
}
