$name=& $PSScriptRoot\Get-MockRepositoryInfo.ps1 -OnlyName
Unregister-PSRepository -Name $name
