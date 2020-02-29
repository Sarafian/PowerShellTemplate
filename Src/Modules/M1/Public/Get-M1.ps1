<#
.Synopsis
    Synopsis
.DESCRIPTION
    Description
.EXAMPLE
   Example
#>
function Get-M1
{
    Param(
    )
    begin {

    }

    process {
        (Get-M1Private).Replace("Private","").Trim()
    }

    end {

    }
}