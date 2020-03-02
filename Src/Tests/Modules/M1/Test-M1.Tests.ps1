& $PSScriptRoot\..\..\..\Modules\Import-M1.ps1
. $PSScriptRoot\..\..\Cmdlets-Helpers\Get-RandomValue.ps1

Describe -Tag @("M1","Module","InModuleScope") "InModuleScope M1" {
    InModuleScope M1 {
        It "Get-M1Private" {
            Get-M1Private| Should -BeExactly "M1 Private"
        }
        It "Get-M1" {
            Get-M1| Should -BeExactly "M1"
        }
    }
}

#<#
# Disabled until resolution of https://github.com/pester/Pester/issues/1461

Describe -Tag @("M1","Module","InModuleScope","MockPrivate","GH-1461") "InModuleScope M1 Mock private" {
    InModuleScope M1 {
        $mockedValue=Get-RandomValue -String
        Mock Get-M1Private {
            $mockedValue
        }
        It "Get-M1Private Mocked" {
            Get-M1Private| Should -BeExactly $mockedValue
        }
        It "Get-M1" {
            Get-M1| Should -BeExactly $mockedValue
        }
    }
}

#>


Describe -Tag @("M1","Module") "M1" {
    It "Get-M1Private throws" {
        {Get-M1Private} | Should -Throw
    }
    It "Get-M1" {
        Get-M1| Should -BeExactly "M1"
    }
}