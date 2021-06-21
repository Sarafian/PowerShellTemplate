BeforeAll {
    & $PSScriptRoot\..\..\..\Modules\Import-M2.ps1
    . $PSScriptRoot\..\..\Cmdlets-Helpers\Get-RandomValue.ps1
}

Describe -Tag @("M2","Module","InModuleScope") "InModuleScope M2" {
    It "Get-M2Private" {
        InModuleScope M2 {
            Get-M2Private| Should -BeExactly "M2 Private"
        }
    }
    It "Get-M2" {
        Get-M2| Should -BeExactly "M2"
    }
}

Describe -Tag @("M2","Module","InModuleScope","MockPrivate") "InModuleScope M2 Mock private" {
    BeforeEach {
        $mockedValue=Get-RandomValue -String
        Mock -ModuleName M2 Get-M2Private {
            $mockedValue
        }
        $inModuleScopeParameters = @{
            mockedValue = $mockedValue
        }

    }
    It "Get-M2Private Mocked" {
        InModuleScope M2 -Parameters $inModuleScopeParameters {
            param($mockedValue)
            Get-M2Private| Should -BeExactly $mockedValue
        }
    }
    It "Get-M2" {
        Get-M2| Should -BeExactly $mockedValue
    }
}

Describe -Tag @("M2","Module") "M2" {
    It "Get-M2Private throws" {
        {Get-M2Private} | Should -Throw
    }
    It "Get-M2" {
        Get-M2| Should -BeExactly "M2"
    }
}
AfterAll {
    Remove-Module -Name M2 -Force
}
