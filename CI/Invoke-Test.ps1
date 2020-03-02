param(
    [Parameter(Mandatory=$true,ParameterSetName="AppVeyor")]
    [switch]$AppVeyor,
    [Parameter(Mandatory=$false,ParameterSetName="Console")]
    [switch]$EnableExit=$false,
    [Parameter(Mandatory=$false,ParameterSetName="Console")]
    [switch]$PassThru=$false
)
$srcPath=Resolve-Path -Path "$PSScriptRoot\..\Src"
<#
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
#>

$pesterSplats=@(
    @("M1","Cmdlet"),
    @("M1","Module"),
    @("M1","Script"),
    @("M2","Cmdlet"),
    @("M2","Module"),
    @("M2","Script")
)|ForEach-Object {
    $outputFile=[System.IO.Path]::GetTempFileName()+".xml"
    $codeCoveragePath=$outputFile.Replace(".xml",".codecoverage.xml")
    @{
        Script=$srcPath
        CodeCoverage=Get-ChildItem -Path $srcPath -Exclude @("*.Tests.ps1","*.NotReady.ps1") -Filter "*.ps1" -Recurse|Select-Object -ExpandProperty FullName
        CodeCoverageOutputFile=$codeCoveragePath
        PassThru=$true
        OutputFormat="NUnitXml"
        OutputFile=$outputFile
        PesterOption=New-PesterOption -TestSuiteName "$($_ -join ",") tags tests summary"
        ExcludeTag="GH-1461"
        Tag=$_
    }
}   

$pesterResults=$pesterSplats|ForEach-Object {
    $splat=$_
    $pesterResult=Invoke-Pester @splat
    $pesterResult | Add-Member -Name "TestResultPath" -Value $splat.OutputFile -MemberType NoteProperty
    $pesterResult | Add-Member -Name "CodeCoveragePath" -Value $splat.CodeCoverageOutputFile -MemberType NoteProperty
    $pesterResult
}

switch($PSCmdlet.ParameterSetName) {
    'AppVeyor' {
        $pesterResults|ForEach-Object {
            (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path -Path $_.TestResultPath))
        }
    }
    'Console' {
    }
}

$pesterResults | Select-Object TotalCount,PassedCount,FailedCount,SkippedCount,PendingCount,Time,@{
    Name="CommandsAnalyzed"
    Expression={$_.CodeCoverage.NumberOfCommandsAnalyzed}
},@{
    Name="FilesAnalyzed"
    Expression={$_.CodeCoverage.NumberOfFilesAnalyzed}
},@{
    Name="CommandsExecuted"
    Expression={$_.CodeCoverage.NumberOfCommandsExecuted}
},@{
    Name="CommandsMissed"
    Expression={$_.CodeCoverage.NumberOfCommandsMissed}
}|Format-Table
$totalFailedCount=$pesterResults | Measure-Object -Sum -Property FailedCount|Select-Object -ExpandProperty Sum
if ($totalFailedCount -gt 0) { 
    throw "$totalFailedCount tests failed."
}
