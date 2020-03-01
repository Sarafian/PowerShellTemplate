$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe -Tag @("M2","Cmdlet","Private") "Get-M2Private" {
    It "Just invoke" {
        Get-M2Private|Should -BeExactly "M2 Private"
    }
}
