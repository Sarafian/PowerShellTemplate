$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$dependsOnPrivateCmdlets=@(
    "Get-M2Private"
)

$dependsOnPrivateCmdlets|ForEach-Object {
    . "$here\..\Private\$_.ps1"
}

Describe "Get-M2" {
    It "Just invoke" {
        Get-M2|Should -BeExactly "M2"
    }
}
