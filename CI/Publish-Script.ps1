param(
    [Parameter(Mandatory=$false,ParameterSetName="Template")]
    [string]$NuGetApiKey=$null,
    [Parameter(Mandatory=$false,ParameterSetName="Template")]
    [string]$Repository="PSGallery",
    [Parameter(Mandatory=$true,ParameterSetName="MOCK:For internal testing")]
    [switch]$UseMock,
    [Parameter(Mandatory=$false,ParameterSetName="MOCK:For internal testing")]
    [switch]$WhatIf=$false
)

if($PSCmdlet.ParameterSetName.StartsWith("MOCK"))
{
    if(-not $WhatIf)
    {
        $NuGetApiKey="anything"
    }
    $Repository=& $PSScriptRoot\..\Mock\Get-MockRepositoryInfo.ps1 -OnlyName
}

if (-not ("Semver.SemVersion" -as [type]))
{
    Write-verbose "Adding Semver.SemVersion type"
    Add-Type -Path "$PSScriptRoot\CS\SemVersion.cs"
}

$sourceScriptItems=Get-ChildItem -Path "$PSScriptRoot\..\Src\Scripts" -File -Recurse

$sourceScriptItems |ForEach-Object {
    $sourceScriptItem=$_

    $scriptName=$sourceScriptItem.Name.Replace($sourceScriptItem.Extension,"")
    $scriptPath=$sourceScriptItem.FullName
#    $psm1Path=Join-Path $scriptPath "$scriptName.psm1"
#    $psd1Path=Join-Path $scriptPath "$scriptName.psd1"

    Write-Debug "scriptName=$scriptName"
    Write-Debug "scriptPath=$scriptPath"
#    Write-Debug "psm1Path=$psm1Path"
#    Write-Debug "psd1Path=$psd1Path"

#    Remove-Item -Path $psd1Path -Force -ErrorAction SilentlyContinue

    $progressSplat=@{
        Activity=$scriptName
    }
    
    try {
    
        $scriptSource=Get-Content -Path $scriptPath -Raw
        $versionRegEx="<\#PSScriptInfo[\r\n]+[\s\S]*\.VERSION (?<Major>([0-9]+))\.(?<Minor>([0-9]+))[\s\S]*\#>"
        if($scriptSource -notmatch $versionRegEx)
        {
            Write-Error "$scriptPath doesn't contain PSScriptInfo tag"
            return -1
        }
        $sourceMajor=[int]$Matches["Major"]
        $sourceMinor=[int]$Matches["Minor"]

        Write-Debug "sourceMajor=$sourceMajor"
        Write-Debug "sourceMinor=$sourceMinor"
    
        $publishedScript=Find-Script -Name $scriptName -Repository $Repository -ErrorAction SilentlyContinue
        Write-Verbose "Queried $scriptName on $Repository"
        $shouldTryPublish=$false
        if($publishedScript)
        {
            $publishedVersion=$publishedScript.Version
            
            # Implicitly check the version of powershell and PowerShellGet script
            if($publishedVersion -is [string])
            {
                $publishedVersion=[Semver.SemVersion]::Parse($publishedVersion)
                $sourceScriptVersion=[Semver.SemVersion]::new($sourceMajor,$sourceMinor,0,$null,$null)
            }
            else {
                $sourceScriptVersion=[System.Version]::Parse($scriptHash.ScriptVersion)
            }
            Write-Debug "publishedVersion=$publishedVersion"
            Write-Debug "sourceScriptVersion=$sourceScriptVersion"
    
            if($publishedVersion -lt $sourceScriptVersion)
            {
                Write-Host "Script $scriptName has source version $sourceScriptVersion that is higher than found published version $publishedVersion"
                $shouldTryPublish=$true
            }
            else
            {
                Write-Warning "Script $scriptName has source version $sourceScriptVersion that is not higher than found published version $publishedVersion. Will skip publishing"
            }
        }
        else
        {
            Write-Host "Script $scriptName is not yet published to the $Repository"
            $shouldTryPublish=$true
        }
    
        if($shouldTryPublish)
        {
            Write-Debug "Publishing  $scriptPath to $Repository"
            Write-Progress @progressSplat -Status "Publishing  $scriptPath to $Repository"
            if($NuGetApiKey)
            {
                Publish-Script -Repository $Repository -Path $scriptPath -NuGetApiKey $NuGetApiKey -Force
            }
            else
            {
                $mockKey="MockKey"
                Publish-Script -Repository $Repository -Path $scriptPath -NuGetApiKey $mockKey -WhatIf
            }
            Write-Host "Published $($sourceScriptItem.FullName)"
        }
    }
    finally{
        Write-Progress @progressSplat -Completed
    }
}