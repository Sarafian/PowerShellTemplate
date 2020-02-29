<#PSManifest

# This the hash to generate the module's manifest with New-ModuleManifest
@{
	# Required fields
	"RootModule"="M1.psm1"
	"Description"="PowerShell module for M1"
	"Guid"="7294dec7-a8db-4643-9695-78064a271def"
	"ModuleVersion"="0.1"

	# Optional fields
	"Author"="Author"
	"CompanyName" = "Company name"
	"Copyright"="Some Copyright"
	"LicenseUri"='https://github.com/Sarafian/PowerShellTemplate/blob/master/LICENSE'
	"ProjectUri"= 'https://github.com/Sarafian/PowerShellTemplate/'

	# Auto generated. Don't implement
}

#>

#requires -Version 4.0

$public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Exclude @("*.Tests.ps1"))
$private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Exclude @("*.Tests.ps1"))

Foreach($import in @($public + $private))
{
	. $import.FullName
}

Export-ModuleMember -Function $public.BaseName
