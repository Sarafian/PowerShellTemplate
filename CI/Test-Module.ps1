param(
    [switch]$EnableExit=$false,
    [switch]$PassThru=$false
)
$pesterScript=@(
    @{
        Path="$PSScriptRoot\..\Src\Modules"
    }
    @{
        Path="$PSScriptRoot\..\Src\Tests\Modules"
    }
)
Invoke-Pester -Script $pesterScript @PSBoundParameters