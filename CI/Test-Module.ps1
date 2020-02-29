param(
    [Parameter(Mandatory=$true,ParameterSetName="AppVeyor")]
    [switch]$AppVeyor,
    [Parameter(Mandatory=$false,ParameterSetName="Console")]
    [switch]$EnableExit=$false,
    [Parameter(Mandatory=$false,ParameterSetName="Console")]
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

switch($PSCmdlet.ParameterSetName) {
    'AppVeyor' {
        $res = Invoke-Pester -Script $pesterScript -OutputFormat NUnitXml -OutputFile TestsResults.xml -PassThru
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path .\TestsResults.xml))
        if ($res.FailedCount -gt 0) { throw "$($res.FailedCount) tests failed."}
    }
    'Console' {
        Invoke-Pester -Script $pesterScript @PSBoundParameters
    }
}


