<#PSManifest

# This the hash to generate the module's manifest with New-ModuleManifest
@{
	# Required fields
	"RootModule"="M2.psm1"
	"Description"="PowerShell module for M2"
	"Guid"="3f3cfac7-517b-4b92-b0eb-ba5b61df6e87"
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
