BeforeAll {
    & $PSScriptRoot\..\..\..\Modules\Import-M1.ps1
    . $PSScriptRoot\..\..\Cmdlets-Helpers\Get-RandomValue.ps1
}

Describe -Tag @("M1","Module","InModuleScope") "InModuleScope M1" {
    It "Get-M1Private" {
        InModuleScope M1 {
            Get-M1Private| Should -BeExactly "M1 Private"
        }
    }
    It "Get-M1" {
        Get-M1| Should -BeExactly "M1"
    }
}

Describe -Tag @("M1","Module","InModuleScope","MockPrivate") "InModuleScope M1 Mock private" {
    BeforeEach {
        $mockedValue=Get-RandomValue -String
        Mock -ModuleName M1 Get-M1Private {
            $mockedValue
        }
        $inModuleScopeParameters = @{
            mockedValue = $mockedValue
        }

    }
    It "Get-M1Private Mocked" {
        InModuleScope M1 -Parameters $inModuleScopeParameters {
            param($mockedValue)
            Get-M1Private| Should -BeExactly $mockedValue
        }
    }
    It "Get-M1" {
        Get-M1| Should -BeExactly $mockedValue
    }
}

Describe -Tag @("M1","Module") "M1" {
    It "Get-M1Private throws" {
        {Get-M1Private} | Should -Throw
    }
    It "Get-M1" {
        Get-M1| Should -BeExactly "M1"
    }
}
AfterAll {
    Remove-Module -Name M1 -Force
}
