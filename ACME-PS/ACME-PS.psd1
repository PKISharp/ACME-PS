@{
	RootModule = 'ACME-PS.psm1'
	ModuleVersion = '1.5.2'
	GUID = '2DBF7E3F-F830-403A-9300-78A11C7CD00C'

	CompatiblePSEditions = @("Core", "Desktop")
	PowershellVersion = "5.1"

	Author = 'https://github.com/PKISharp/ACME-PS/graphs/contributors'
	CompanyName = 'Thomas Glatzer via PKISharp (https://github.com/PKISharp)'
	Copyright = '(c) 2018-2020 Thomas Glatzer. All rights reserved. - Based on the originial work of Eugene Bekker (https://www.powershellgallery.com/packages/ACMESharp/0.9.1.326)'

	Description = "PowerShell client module for the ACME protocol Version 2, which can be used to interoperate with the Let's Encrypt(TM) projects certificate servers and any other RFC 8555 compliant server."

	NestedModules = @(
		"./Prerequisites.ps1"
	)

	RequiredAssemblies = @(
		'System.Net.Http'
	)

	DefaultCommandPrefix = 'ACME'
	FunctionsToExport = @(
		"Disable-Account",
		"Find-Account",
		"Get-Account",
		"New-Account",
		"Set-Account",

		"Export-AccountKey",
		"Import-AccountKey",
		"New-AccountKey",

		"Get-Authorization",
		"Get-AuthorizationError",

		"Export-Certificate",
		"Revoke-Certificate",

		"Export-CertificateKey",
		"Import-CertificateKey",
		"New-CertificateKey",

		"Complete-Challenge",
		"Get-Challenge",
		"Initialize-Challenge",

		"Get-Nonce",
		"New-Nonce",

		"Complete-Order",
		"Find-Order",
		"Get-Order",
		"New-Identifier",
		"New-Order",
		"Update-Order"

		"Get-ServiceDirectory",
		"Get-TermsOfService",

		"Get-State",
		"New-State",

		"Invoke-SignedWebRequest"
	)
	CmdletsToExport = @()
	VariablesToExport = @()
	AliasesToExport = @()
	DscResourcesToExport = @()

	# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		PSData = @{
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @('pki','ssl','tls','security','certificates','letsencrypt','acme','powershell','acmesharp')

			# License for this module.
			LicenseUri = 'https://github.com/PKISharp/ACME-PS/raw/master/LICENSE'

			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/PKISharp/ACME-PS'

			# An icon representing this module.
			IconUri = 'https://github.com/PKISharp/ACME-PS/raw/master/ACME-PS/ACME-PS.png'

			# ReleaseNotes of this module
			ReleaseNotes = 'Please see the release notes from the release distribution page: https://github.com/PKISharp/ACME-PS/releases'

			# Prerelase
			# Prerelease = 'beta'
		} # End of PSData hashtable

	} # End of PrivateData hashtable
}
