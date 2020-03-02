. $PSScriptRoot\..\..\Cmdlets-Helpers\Get-RandomValue.ps1
$scriptPath=Resolve-Path -Path "$PSScriptRoot\..\..\..\Scripts\M1\Get-M1.ps1"
$scriptName=Split-Path -Path $scriptPath -Leaf

Describe -Tag @("M1","Script") $scriptName {
    It "Invoke" {
        $result=& $scriptPath
        & $scriptPath | Should -BeExactly "M1"
    }
}