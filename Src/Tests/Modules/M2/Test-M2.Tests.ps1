& $PSScriptRoot\..\..\..\Modules\Import-M2.ps1
. $PSScriptRoot\..\..\Cmdlets-Helpers\Get-RandomValue.ps1

Describe -Tag @("M1","Module","InModuleScope") "InModuleScope M2" {
    InModuleScope M2 {
        It "Get-M2Private" {
            Get-M2Private| Should -BeExactly "M2 Private"
        }
        It "Get-M2" {
            Get-M2| Should -BeExactly "M2"
        }
    }
}

#<#
# Disabled until resolution of https://github.com/pester/Pester/issues/1461

Describe -Tag @("M2","Module","InModuleScope","MockPrivate","GH-1461") "InModuleScope M2 Mock private" {
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

#>

Describe -Tag @("M1","Module") "M2" {
    It "Get-M2Private throws" {
        {Get-M2Private} | Should -Throw
    }
    It "Get-M2" {
        Get-M2| Should -BeExactly "M2"
    }
}

Remove-Module -Name M2 -Force
