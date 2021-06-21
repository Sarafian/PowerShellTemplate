BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe -Tag @("M2","Cmdlet","Private") "Get-M2Private" {
    It "Just invoke" {
        Get-M2Private|Should -BeExactly "M2 Private"
    }
}
