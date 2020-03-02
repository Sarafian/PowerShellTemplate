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
        Path="$PSScriptRoot\..\Src"
    }
)

switch($PSCmdlet.ParameterSetName) {
    'AppVeyor' {
        $res1 = Invoke-Pester -Script $pesterScript -OutputFormat NUnitXml -OutputFile TestsResults1.xml -PassThru -ExcludeTag "GH-1461" -Tag "M1"
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path .\TestsResults1.xml))
        $res2 = Invoke-Pester -Script $pesterScript -OutputFormat NUnitXml -OutputFile TestsResults2.xml -PassThru -ExcludeTag "GH-1461" -Tag "M2"
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path .\TestsResults2.xml))
        if (($res1.FailedCount -gt 0) -or ($res2.FailedCount -gt 0)) { throw "$($res1.FailedCount+$res2.FailedCount) tests failed."}
    }
    'Console' {
        Invoke-Pester -Script $pesterScript @PSBoundParameters -ExcludeTag "GH-1461" -
    }
}


