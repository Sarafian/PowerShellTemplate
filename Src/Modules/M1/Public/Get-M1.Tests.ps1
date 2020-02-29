$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$dependsOnPrivateCmdlets=@(
    "Get-M1Private"
)

$dependsOnPrivateCmdlets|ForEach-Object {
    . "$here\..\Private\$_.ps1"
}

Describe "Get-M1" {
    It "Just invoke" {
        Get-M1|Should -BeExactly "M1"
    }
}
