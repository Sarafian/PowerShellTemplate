$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-M1Private" {
    It "Just invoke" {
        Get-M1Private|Should -BeExactly "M1 Private"
    }
}
