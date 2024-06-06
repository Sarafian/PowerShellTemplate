<#PSScriptInfo

.VERSION 1.0

.LASTUPDATE 20240606

#>

#Requires -Modules @{ ModuleName="SemVerPS"; ModuleVersion="1.0" }

param(
    [Parameter(Mandatory=$false)]
    [string]$NuGetApiKey=$null,
    [Parameter(Mandatory=$false)]
    [string]$Repository="PSGallery",
    [Parameter(Mandatory=$false)]
    [switch]$Mock=$false,
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf=$false
)

#region To be removed when copying to other repository. Supporting mock publishing functionality
if($Mock)
{
    if(-not $WhatIf)
    {
        $NuGetApiKey="anything"
    }
    $Repository=& $PSScriptRoot\..\Mock\Get-MockRepositoryInfo.ps1 -OnlyName
    & $MyInvocation.MyCommand.Path -NuGetApiKey $NuGetApiKey -Repository $Repository
    return 
}
#endregion

$sourceScriptItems=Get-ChildItem -Path "$PSScriptRoot\..\Src\Scripts" -File -Recurse

$sourceScriptItems |ForEach-Object {
    $sourceScriptItem=$_

    $scriptName=$sourceScriptItem.Name.Replace($sourceScriptItem.Extension,"")
    $scriptPath=$sourceScriptItem.FullName

    Write-Debug "scriptName=$scriptName"
    Write-Debug "scriptPath=$scriptPath"

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
                $publishedVersion=ConvertTo-SemVer -Version $publishedVersion
                $sourceScriptVersion=ConvertTo-SemVer -Version "$sourceMajor,$sourceMinor"
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
            Write-Host "Published $scriptPath"
        }
    }
    finally{
        Write-Progress @progressSplat -Completed
    }
}