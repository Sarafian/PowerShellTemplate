$public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Exclude @("*.Tests.ps1"))
$private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Exclude @("*.Tests.ps1") -ErrorAction SilentlyContinue)

Foreach($import in @($public + $private))
{
	. $import.FullName
}

Export-ModuleMember -Function $public.BaseName