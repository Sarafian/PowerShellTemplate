BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}
Describe -Tag @("M1","Cmdlet","Private")  "Get-M1Private" {
    It "Just invoke" {
        Get-M1Private|Should -BeExactly "M1 Private"
    }
}
