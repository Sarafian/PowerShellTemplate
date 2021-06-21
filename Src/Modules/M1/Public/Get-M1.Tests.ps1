BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    $dependsOnPrivateCmdlets=@(
        "Get-M1Private"
    )
    
    $dependsOnPrivateCmdlets|ForEach-Object {
        . "$PSScriptRoot\..\Private\$_.ps1"
    }    
}


Describe  -Tag @("M1","Cmdlet","Public") "Get-M1" {
    It "Just invoke" {
        Get-M1|Should -BeExactly "M1"
    }
}
