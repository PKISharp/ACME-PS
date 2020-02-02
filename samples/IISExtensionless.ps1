<# -- Script -- #>

# Ensure IIS Static Files
Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent;

# Enable IIS extensionless file serving
Import-Module WebAdministration 
<# TODO: look up commands to allow file serving #>