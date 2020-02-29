<#
.Synopsis
    Synopsis
.DESCRIPTION
    Description
.EXAMPLE
   Example
#>
function Get-M2
{
    Param(
    )
    begin {

    }

    process {
        (Get-M2Private).Replace("Private","").Trim()
    }

    end {

    }
}