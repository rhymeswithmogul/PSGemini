@{

# Script module or binary module file associated with this manifest.
RootModule = 'src/PSGemini.psm1'

# Version number of this module.
ModuleVersion = '1.0.3'

# Supported PSEditions
CompatiblePSEditions = @('Core', 'Desktop')

# ID used to uniquely identify this module
GUID = '5df7d4a1-ac51-457d-bc4c-6b923428be0e'

# Author of this module
Author = 'Colin Cogle'

# Copyright statement for this module
Copyright = '(c) 2022 Colin Cogle. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Fetches resources via the Gemini protocol.'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '7.1'

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# ClrVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
	'Invoke-GeminiRequest',
	'Add-PSGeminiKnownCertificate',
	'Get-PSGeminiKnownCertificate',
	'Remove-PSGeminiKnownCertificate'
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = ''

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @(
	'Get-PSGeminiKnownCertificates',
	'igemr',
	'Invoke-GemRequest'
)

# DSC resources to export from this module
DscResourcesToExport = @()

# List of all modules packaged with this module
ModuleList = @()

# List of all files packaged with this module
FileList = @(
	'en-US/about_PSGemini.help.txt',
	'en-US/PSGemini-help.xml',
	'src/PSGemini.psm1',
	'AUTHORS',
	'CHANGELOG.md',
	'INSTALL',
	'LICENSE',
	'NEWS'
	'PSGemini.psd1',
	'README.md'
)

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

	PSData = @{

		# Tags applied to this module. These help with module discovery in online galleries.
		Tags = @('Gemini', 'Gemtext', 'Gemlog', 'GeminiProtocol', 'TLS', 'circumlunar', 'space')

		# A URL to the license for this module.
		LicenseUri = 'https://www.gnu.org/licenses/agpl-3.0.html'

		# A URL to the main website for this project.
		ProjectUri = 'https://github.com/rhymeswithmogul/PSGemini/'

		# A URL to an icon representing this module.
		# IconUri = ''

		# ReleaseNotes of this module
		ReleaseNotes = 'Tiny bug fix.'

		# Prerelease string of this module
		#Prerelease = ''

		# Flag to indicate whether the module requires explicit user acceptance for install/update/save
		RequireLicenseAcceptance = $false

		# External dependent modules of this module
		ExternalModuleDependencies = @()

	} # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

