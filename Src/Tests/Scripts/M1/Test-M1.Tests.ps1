BeforeAll {
    . $PSScriptRoot\..\..\Cmdlets-Helpers\Get-RandomValue.ps1
    $scriptPath=Resolve-Path -Path "$PSScriptRoot\..\..\..\Scripts\M1\Get-M1.ps1"
}

Describe -Tag @("M1","Script") "M1\Get-M1.ps1" {
    It "Invoke" {
        $result=& $scriptPath
        & $scriptPath | Should -BeExactly "M1"
    }
}