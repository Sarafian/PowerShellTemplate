BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    $dependsOnPrivateCmdlets=@(
        "Get-M2Private"
    )
    
    $dependsOnPrivateCmdlets|ForEach-Object {
        . "$PSScriptRoot\..\Private\$_.ps1"
    }    
}

Describe -Tag @("M1","Cmdlet","Public") "Get-M2" {
    It "Just invoke" {
        Get-M2|Should -BeExactly "M2"
    }
}
