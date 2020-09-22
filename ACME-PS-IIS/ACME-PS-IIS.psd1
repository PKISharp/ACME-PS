@{
	RootModule = 'ACME-PS-IIS.psm1'
	ModuleVersion = '1.3.1'
	GUID = 'DB2D9672-A0D7-4AE6-9C0A-C36DA59684AF'

	CompatiblePSEditions = @("Core", "Desktop")
	PowershellVersion = "5.1"

	Author = 'https://github.com/PKISharp/ACME-PS/graphs/contributors'
	CompanyName = 'Thomas Glatzer via PKISharp (https://github.com/PKISharp)'
	Copyright = '(c) 2018-2020 Thomas Glatzer. All rights reserved.'

	Description = "PowerShell module to automatically manage certificates on IIS, with the Let's Encrypt(TM) projects certificate servers and any other RFC 8555 compliant server."

    RequiredModules = @(
		'ACME-PS',
		'IIS-Administration'
	)

	DefaultCommandPrefix = 'ACMEIIS'
	FunctionsToExport = @(
	)

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
			IconUri = 'https://github.com/PKISharp/ACME-PS/raw/master/ACME-PS-IIS/ACME-PS-IIS.png'

			# ReleaseNotes of this module
			ReleaseNotes = 'Please see the release notes from the release distribution page: https://github.com/PKISharp/ACME-PS/releases'

			# Prerelase
			# Prerelease = 'beta4'
		} # End of PSData hashtable

	} # End of PrivateData hashtable
}
