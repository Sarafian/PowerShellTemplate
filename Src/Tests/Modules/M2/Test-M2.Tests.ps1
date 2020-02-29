& $PSScriptRoot\..\..\..\Modules\Import-M2.ps1
. $PSScriptRoot\..\..\Cmdlets-Helpers\Get-RandomValue.ps1

Describe "InModuleScope M2" {
    InModuleScope M2 {
        It "Get-M2Private" {
            Get-M2Private| Should -BeExactly "M2 Private"
        }
        It "Get-M2" {
            Get-M2| Should -BeExactly "M2"
        }
    }
}

Describe "InModuleScope M2 Mock private" {
    InModuleScope M2 {
        $mockedValue=Get-RandomValue -String
        Mock Get-M2Private {
            $mockedValue
        }
        It "Get-M2Private Mocked" {
            Get-M2Private| Should -BeExactly $mockedValue
        }
        It "Get-M2" {
            Get-M2| Should -BeExactly $mockedValue
        }
    }
}


Describe "M2" {
    It "Get-M2Private throws" {
        {Get-M2Private} | Should -Throw
    }
    It "Get-M2" {
        Get-M2| Should -BeExactly "M2"
    }
}